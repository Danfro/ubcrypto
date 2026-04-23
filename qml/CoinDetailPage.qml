// qml/CoinDetailPage.qml
import QtQuick 2.7
import Lomiri.Components 1.3

Page {
    id: coinDetailPage
    header: PageHeader {
        title: coinName + " (" + coinSymbol + ")"
    }

    property string coinName: "Bitcoin"
    property string coinSymbol: "BTC"
    property string price: "$67,500"

    Column {
        anchors.margins: units.gu(2)
        spacing: units.gu(2)

        Text {
            text: i18n.tr("Current Price: ") + price
            font.pixelSize: units.gu(3)
        }

        Rectangle {
            id: chartBox
            width: parent.width
            height: units.gu(20)
            color: "#e6e6e6"
            radius: 8

            Text {
                anchors.centerIn: parent
                text: i18n.tr("Chart Placeholder")
                color: "#666"
            }
        }

        Row {
            spacing: units.gu(2)

            Button {
                text: i18n.tr("Add to Watchlist")
                onClicked: {
                    console.log("Added to Watchlist");
                    // Save to local DB later
                }
            }

            Button {
                text: i18n.tr("Add to Portfolio")
                onClicked: {
                    console.log("Added to Portfolio");
                    // Save to local DB later
                }
            }
        }
    }
}
