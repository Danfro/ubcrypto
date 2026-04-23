import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import io.thp.pyotherside 1.4
import "datastore.js" as DB
import QtQuick.Layouts 1.3 // Ensure this is imported if you're using Layouts elsewhere
import "theme.js" as AppTheme

Page {
    id: dashboardPage

  /*  header: PageHeader {
        title: "Market Overview"
    }*/

    ListModel {
        id: coinModel
    }
    property string currentFilter: "all"

    Component.onCompleted: {
        var coins = DB.getAllCoins();
        //console.log("Loaded coins:", JSON.stringify(coins));
        loadCoins(coins);
    }

    function loadCoins(dataArray) {
        coinModel.clear();

        for (var i = 0; i < dataArray.length; i++) {
            var item = dataArray[i];

            // Append only QML-safe properties
            coinModel.append({
                                 name: item.name || "Unknown",
                                 symbol: item.symbol || "",
                                 current_price: item.current_price || 0,
                                 price_change_percentage_1h: item.price_change_percentage_1h || 0,
                                 price_change_percentage_24h: item.price_change_percentage_24h || 0,
                                 price_change_percentage_7d: item.price_change_percentage_7d || 0,
                                 price_change_percentage_30d: item.price_change_percentage_30d || 0,
                                 market_cap_rank: item.market_cap_rank || -1,
                                 total_volume: item.total_volume || 0,
                                 image_url: item.image_url || ""
                             });
        }
    }

    function applyFilter(filter) {
        currentFilter = filter;
        var result = [];

        if (filter === "all") {
            result = DB.getAllCoins();
        } else if (filter === "gainers") {
            result = DB.getTopGainers();
        } else if (filter === "losers") {
            result = DB.getTopLosers();
        }

        loadCoins(result);
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../src/"));
            importModule("cli", function () {});
        }

        onError: function (errorName, errorMessage, traceback) {
            console.log("Python Error:", errorName, errorMessage, traceback);
        }
    }

    function filterList(query) {
        if (!query || query.trim() === "") {
            // If the search box is empty, reload current filter
            applyFilter(currentFilter);
            return;
        }

        // Normalize search query
        var lowerQuery = query.toLowerCase();

        var filtered = [];

        var allCoins = DB.getAllCoins(); // You could also cache this to avoid repeated DB calls

        for (var i = 0; i < allCoins.length; i++) {
            var item = allCoins[i];
            var name = item.name.toLowerCase();
            var symbol = item.symbol.toLowerCase();

            if (name.indexOf(lowerQuery) !== -1 || symbol.indexOf(lowerQuery) !== -1) {
                filtered.push(item);
            }
        }

        loadCoins(filtered);
    }


    // === Main Layout Column ===
    Column {
        anchors.fill: parent
        spacing: units.gu(1)
        anchors.margins: units.gu(1) // Padding around the content of the Page

        // ─── Filter NavBar ───
        Rectangle {
            id: navBar
            height: units.gu(8)
            width: parent.width
            color: "#1c1c1e"
            border.color: "#333"
            radius: 6

            property int selectedMenuItem: 0

            Row { // This Row lays out filter buttons horizontally
                anchors.centerIn: parent
                spacing: units.gu(3)

                Repeater {
                    model: [
                        { name: i18n.tr("All") },
                        { name: i18n.tr("Top Gainers") },
                        { name: i18n.tr("Top Losers") }
                    ]
                    delegate: MouseArea {
                        width: units.gu(12)
                        height: navBar.height
                        onClicked: {
                            navBar.selectedMenuItem = index;
                            if (index === 0) {
                                applyFilter("all");
                            } else if (index === 1) {
                                applyFilter("gainers");
                            } else {
                                applyFilter("losers");
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            Text {
                                text: modelData.name
                                anchors.centerIn: parent
                                font.pixelSize: units.gu(2.2)
                                color: navBar.selectedMenuItem === index ? LomiriColors.orange : "#f0f0f0"
                            }
                        }
                    }
                }
            }
        }
        Item {
            width: parent.width
            height: units.gu(5)


            TextField {
                id: searchBox
                placeholderText: i18n.tr("Search coins...")
                anchors.fill: parent
                font.pixelSize: units.gu(2)
                onTextChanged: {
                    console.log("DEBUG: TextField onTextChanged fired. Current text:", searchBox.text);
                    filterList(searchBox.text);
                }

                inputMethodHints: Qt.ImhNoPredictiveText
                rightPadding: clearButton.visible ? units.gu(4) : 0
            }

            MouseArea {
                id: clearButtonArea
                visible: searchBox.text.length > 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: units.gu(4)
                height: parent.height
                onClicked: {
                    searchBox.text = ""
                }

                Label {
                    id: clearButton
                    text:"X"
                    font.bold: true
                    anchors.centerIn: parent
                    width: units.gu(2)
                    height: units.gu(2)
                    visible: searchBox.text.length > 0
                }
            }
        }



        // ─── List of Coins ───
        LomiriListView {
            id: coinListView
            width: parent.width // This makes it fill the horizontal space of the Column.
            height: parent.height - navBar.height - spacing * 2 // Calculate remaining height.
            visible: coinModel.count > 0 // This should be correct. It will show if count > 0.
            spacing: units.gu(1) // Spacing between delegates
            clip: true

            model: coinModel

            delegate: CoinCard {
                coinName: model.name || "N/A"
                coinSymbol: model.symbol || ""
                currentPrice: model.current_price !== undefined ? model.current_price : 0
                price_change_percentage_1h: model.price_change_percentage_1h !== undefined ? model.price_change_percentage_1h : 0
                price_change_percentage_24h: model.price_change_percentage_24h !== undefined ? model.price_change_percentage_24h : 0
                price_change_percentage_7d: model.price_change_percentage_7d !== undefined ? model.price_change_percentage_7d : 0
                price_change_percentage_30d: model.price_change_percentage_30d !== undefined ? model.price_change_percentage_30d : 0
                marketCapRank: model.market_cap_rank !== undefined ? model.market_cap_rank : -1
                totalVolume: model.total_volume !== undefined ? model.total_volume : 0
                coinImage: model.image_url || ""
            }
        }

        // ─── Empty State ───
        Item {
            id: emptyState
            width: parent.width
            height: parent.height - navBar.height - spacing * 2 // Occupy the same vertical space as coinListView
            visible: (coinModel.count === 0) // Correct condition
            Column {
                anchors.centerIn: parent // Center content within the emptyState Item
                spacing: units.gu(1)
                width: parent.width // Make Column take full width of emptyState

                Label {
                    text: i18n.tr("No data available.")
                    font.pixelSize: units.gu(2.2)
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width // Make Label fill its parent Column horizontally
                }

                Button {
                    text: i18n.tr("Refresh")
                    anchors.horizontalCenter: parent.horizontalCenter // Keep centering for the Button
                    onClicked: {
                        var coins = DB.getAllCoins();
                        //console.log("Loaded coins:", JSON.stringify(coins));
                        loadCoins(coins);
                    }
                }
            }
        }
    }
}
