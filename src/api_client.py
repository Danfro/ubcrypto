import requests
import socket
import ssl
import json
import logging
import urllib3
from logger import setup_logger

# --- Configuration and Setup ---
# Disable urllib3 warnings (e.g., for InsecureRequestWarning if verify=False is used)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
log = setup_logger()


# CoinGecko API Base URL
COINGECKO_BASE = "https://api.coingecko.com"

# --- IPv4 Only Monkey Patch for requests/urllib3 ---
# Store the original getaddrinfo
_orig_getaddrinfo = socket.getaddrinfo

def _ipv4_only_getaddrinfo(host, port, family=0, socktype=0, proto=0, flags=0):
    """
    Custom getaddrinfo that forces AF_INET (IPv4) resolution.
    This will affect all network requests using Python's socket module,
    including those made by 'requests'.
    """
    # Call the original getaddrinfo, allowing it to resolve both IPv4 and IPv6 initially
    res = _orig_getaddrinfo(host, port, family, socktype, proto, flags)

    # Filter the results to only include IPv4 addresses
    ipv4_results = [r for r in res if r[0] == socket.AF_INET]

    if not ipv4_results and res:
        log.warning(f"No IPv4 addresses found for {host} by _ipv4_only_getaddrinfo. Returning original results (may include IPv6).")
        return res # Fallback, though if IPv6 is an issue, this might still lead to problems
    elif not ipv4_results and not res:
        raise socket.gaierror(-2, f"Name or service not known (no IPv4 address found for {host})")

    return ipv4_results

# Apply the monkey patch
socket.getaddrinfo = _ipv4_only_getaddrinfo

# --- CoinGecko API Interaction Functions ---

# We don't need a separate get_via_ipv4 function anymore,
# as the monkey patch ensures all requests to hostnames are IPv4-only.
# We'll use requests.Session for efficiency and connection pooling.
session = requests.Session()

def test_coingecko_ping():
    """
    Tests the CoinGecko /ping endpoint using the configured requests session.
    This is good for verifying basic connectivity.
    """
    url = f"{COINGECKO_BASE}/api/v3/ping"
    log.debug(f"Testing CoinGecko ping: {url}")
    try:
        response = session.get(url, timeout=10)
        response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
        log.debug(f"Status Code: {response.status_code}")
        log.debug(f"Response: {response.json()}")
        return response.json()
    except requests.exceptions.RequestException as e:
        log.error(f"Error testing CoinGecko ping: {e}")
        return None

def get_coins(limit=1000):
    """
    Fetches cryptocurrency market data from CoinGecko, paginating as needed,
    and ensuring IPv4 connectivity via the monkey patch.
    """
    per_page = 250
    pages = (limit + per_page - 1) // per_page
    results = []

    # Rate-limiting / retry config
    max_retries = 3
    min_wait_on_429 = 60           # wait at least 60s when a 429 is received
    calls_per_minute = 10          # target pacing inside the allowed limit of 5 - 15 calls per minute
    min_interval = 60.0 / calls_per_minute

    last_request_time = 0.0

    for page in range(1, pages + 1):
        # Construct the URL for the current page
        url = f"{COINGECKO_BASE}/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page={per_page}&page={page}&sparkline=false&price_change_percentage=1h,24h,7d,30d,90d"

        retries = 0
        while retries <= max_retries:
            # pace requests to respect target rate
            elapsed = time.time() - last_request_time
            if elapsed < min_interval:
                time.sleep(min_interval - elapsed)

            try:
                # Use the requests session for the API call
                response = session.get(url, timeout=30)  # Increased timeout for data fetches
                last_request_time = time.time()

                # Explicit handling for rate limiting (429)
                if response.status_code == 429:
                    retry_after = response.headers.get("Retry-After")
                    if retry_after is not None:
                        try:
                            wait = max(min_wait_on_429, int(retry_after))
                        except ValueError:
                            wait = min_wait_on_429
                    else:
                        wait = min_wait_on_429

                    log.warning(f"[Rate Limit] Page {page} 429 received. Waiting {wait}s before retry #{retries+1}.")
                    time.sleep(wait)
                    retries += 1
                    continue

                response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)

                raw_data = response.content  # Get raw bytes
                data = json.loads(raw_data.decode("utf-8"))

                if not isinstance(data, list):
                    log.error(f"[Error] Unexpected data format for page {page}: {data}")
                    break  # skip this page and continue with next

                for coin in data:
                    results.append({
                        "id": coin.get("id"),
                        "name": coin.get("name"),
                        "symbol": coin.get("symbol", "").upper(),
                        "price": coin.get("current_price"),
                        "change24h": coin.get("price_change_percentage_24h"),
                        "image": coin.get("image"),
                        "json": coin,  # Keep the full JSON for debugging or future use
                    })
                break  # success -> exit retry loop

            except requests.exceptions.HTTPError as e:
                status = e.response.status_code if e.response is not None else None
                if status == 429:
                    retry_after = e.response.headers.get("Retry-After") if e.response is not None else None
                    try:
                        wait = max(min_wait_on_429, int(retry_after)) if retry_after else min_wait_on_429
                    except ValueError:
                        wait = min_wait_on_429
                    log.warning(f"[HTTPError 429] Page {page}: waiting {wait}s before retry #{retries+1}.")
                    time.sleep(wait)
                    retries += 1
                    continue

                log.error(f"[HTTP Error] Page {page} failed with status {status}: {e.response.text if e.response is not None else e}")
                break

            except requests.exceptions.ConnectionError as e:
                log.error(f"[Connection Error] Page {page} failed: {e}. Check network and DNS resolution.")
                break

            except requests.exceptions.Timeout as e:
                log.error(f"[Timeout Error] Page {page} timed out: {e}")
                break

            except json.JSONDecodeError as e:
                log.error(f"[JSON Decode Error] Page {page} failed to parse JSON: {e}")
                break

            except Exception as e:
                log.error(f"[Unexpected Error] Page {page} failed: {e}", exc_info=True)  # exc_info to get traceback
                break

        else:
            # executed if while loop exhausted without break (i.e., retries exceeded)
            log.error(f"[Rate Limit] Page {page} exhausted retries ({max_retries}). Skipping page.")

    # Return only up to the specified limit
    return results[:limit]

"""
# --- Main execution block ---
if __name__ == "__main__":
    log.info("Starting CoinGecko data fetching script.")

    # First, test the ping to ensure basic connectivity
    ping_result = test_coingecko_ping()
    if ping_result:
        log.info(f"CoinGecko ping successful: {ping_result}")
    else:
        log.error("CoinGecko ping failed. Aborting data fetch.")
        exit(1) # Exit if ping fails

    # Then, fetch the coins
    num_coins_to_fetch = 100 # You can adjust this for testing
    all_coins = get_coins(limit=num_coins_to_fetch)

    log.info(f"Fetched {len(all_coins)} coins.")

    if all_coins:
        log.info("Example of fetched coins:")
        for i, coin in enumerate(all_coins[:5]): # Print details for first 5 coins
            log.info(f"  {i+1}. {coin['name']} ({coin['symbol']}) - Price: ${coin['price']:.4f} - 24h Change: {coin['change24h']:.2f}%")
    else:
        log.warning("No coins were fetched.")

    log.info("Script finished.")
    session.close() # Close the session when done

"""
