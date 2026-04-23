import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3 // For better layout management
import Qt.labs.platform 1.0 // For Qt.openUrlExternally (if available and needed)
import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import io.thp.pyotherside 1.4
import "theme.js" as AppTheme


Page {
    header: PageHeader {
        title: "Latest News"
        ActionBar {
            numberOfSlots: 2
            anchors.right: parent.right
            actions: [
                Action {
                    iconName: "view-refresh"
                    text: i18n.tr("Refresh")
                    onTriggered: loadAllFeeds()
                }
            ]
        }
    }

    // Optional: Define some colors for better aesthetics
    property color backgroundColor: "#f0f2f5"
    property color cardBackgroundColor: "#ffffff"
    property color textColorPrimary: "#333333"
    property color textColorSecondary: "#666666"
    property color linkColor: "#007bff"
    property color separatorColor: "#e0e0e0"

    // 1. List of RSS feed URLs
    property var rssFeedUrls: [
        "https://www.coindesk.com/feed", // Might still give 403, consider alternative or backend
        "https://cointelegraph.com/rss",
        "https://crypto.news/feed",
        "https://cryptonews.com/feed/"
        // Add more cryptocurrency RSS feed URLs here.
    ]

    // 2. Main ListModel to hold combined and sorted news items
    ListModel {
        id: unifiedNewsModel
    }

    // Function to load all RSS feeds
    function loadAllFeeds() {
        console.log("Loading all RSS feeds...");
        unifiedNewsModel.clear(); // Clear previous data

        var totalFeedsToLoad = rssFeedUrls.length;
        var feedsLoaded = 0;

        // Iterate through each feed URL
        rssFeedUrls.forEach(function(url) {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        console.log("Successfully fetched:", url);

                        // 3. Dynamically create a temporary XmlListModel for parsing this specific feed
                        var tempXmlModel = Qt.createQmlObject(`
                                                              import QtQuick 2.0 // Basic QML types
                                                              import QtQuick.XmlListModel 2.0 // <--- THIS IS CRUCIAL for XmlListModel and XmlRole

                                                              XmlListModel {
                                                              query: "/rss/channel/item"
                                                              // If specific feeds need namespaces (e.g., media:content), add them here on a single line:
                                                              // namespaceDeclarations: "declare namespace media='http://search.yahoo.com/mrss/'; declare namespace content='http://purl.org/rss/1.0/modules/content/';"

                                                              XmlRole { name: "title"; query: "title/string()" }
                                                              XmlRole { name: "link"; query: "link/string()" }
                                                              XmlRole { name: "pubDate"; query: "pubDate/string()" }
                                                              XmlRole { name: "description"; query: "description/string()" }
                                                              }
                                                              `, parent, "tempXmlModel_" + Math.random().toString(36).substring(7)); // Unique filename for debugging

                        // Set the XML content
                        tempXmlModel.xml = xhr.responseText;

                        // Connect to countChanged to know when parsing is complete
                        var connection = tempXmlModel.countChanged.connect(function() {
                            // 4. Populate the unifiedNewsModel
                            for (var i = 0; i < tempXmlModel.count; ++i) {
                                var item = tempXmlModel.get(i);
                                // Add the raw pubDate and a parsed Date object for sorting
                                item.parsedDate = new Date(item.pubDate);
                                unifiedNewsModel.append(item);
                            }
                            tempXmlModel.destroy(); // Clean up the temporary model
                            connection.disconnect(); // Disconnect to avoid issues if model somehow reloads

                            feedsLoaded++;
                            if (feedsLoaded === totalFeedsToLoad) {
                                // All feeds processed, now sort the combined model
                                sortUnifiedNewsModel();
                                console.log("All feeds processed and sorted.");
                            }
                        });

                    } else {
                        console.warn("Failed to load RSS feed from:", url, "Status:", xhr.status);
                        feedsLoaded++; // Still count to ensure sorting is triggered even if a feed fails
                        if (feedsLoaded === totalFeedsToLoad) {
                            sortUnifiedNewsModel();
                            console.log("All feeds processed, some might have failed, but trying to sort.");
                        }
                    }
                }
            };
            xhr.open("GET", url);
            xhr.send();
        });
    }

    // Function to sort the unifiedNewsModel by date (latest first)
    function sortUnifiedNewsModel() {
        // Convert ListModel to a JavaScript array for sorting
        var newsArray = [];
        for (var i = 0; i < unifiedNewsModel.count; ++i) {
            newsArray.push(unifiedNewsModel.get(i));
        }

        // Sort the array by parsedDate in descending order (latest news first)
        newsArray.sort(function(a, b) {
            // Ensure parsedDate is a valid Date object before comparing
            var dateA = a.parsedDate instanceof Date && !isNaN(a.parsedDate) ? a.parsedDate.getTime() : 0;
            var dateB = b.parsedDate instanceof Date && !isNaN(b.parsedDate) ? b.parsedDate.getTime() : 0;
            return dateB - dateA;
        });

        // Clear the existing ListModel and repopulate with the sorted data
        unifiedNewsModel.clear();
        for (var i = 0; i < newsArray.length; ++i) {
            unifiedNewsModel.append(newsArray[i]);
        }
        console.log("News model sorted. Total items:", unifiedNewsModel.count);
    }

    // Trigger loading when the component is ready
    Component.onCompleted: {
        loadAllFeeds();
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor // Background color for the page
    }

    // UI for displaying news
    ListView {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: parent.bottom
        spacing: 8
        model: unifiedNewsModel

        delegate: Item {
            width: parent.width
            // Use implicitHeight for the delegate's root Item,
            // which will correctly be picked up by the ListView.
            // Adding a fixed value (10) for extra spacing/margin around the card.
            implicitHeight: newsCard.implicitHeight + 10

            Rectangle {
                id: newsCard
                width: parent.width - 24
                x: 12
                color: cardBackgroundColor
                radius: 8
                // The implicitHeight of newsCard is correctly derived from its ColumnLayout
                implicitHeight: newsContentColumn.implicitHeight +  units.gu(8)  // Padding for the card content


                ColumnLayout {
                    id: newsContentColumn
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: title
                        Layout.fillWidth: true
                        font.family: "Sans-serif"
                        font.pixelSize:  units.gu(2)
                        font.bold: true
                        color: textColorPrimary
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }

                    Text {
                        text: Qt.formatDateTime(parsedDate, "MMM d,yyyy 'at' hh:mm")
                        Layout.fillWidth: true
                        font.pixelSize:  units.gu(1.5)
                        color: textColorSecondary
                    }

                    Text {
                        id: descriptionText
                        text: description ? description.replace(/<[^>]*>?/gm, '').trim() : ""
                        Layout.fillWidth: true
                        font.pixelSize:  units.gu(1.5)
                        color: textColorPrimary
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: descriptionText.text.length > 0
                    }

                    Text {
                        text: i18n.tr("Read More")
                        Layout.fillWidth: true
                        font.pixelSize:  units.gu(1.5)
                        color: linkColor
                        font.underline: true
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (link) {
                                    Qt.openUrlExternally(link);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
