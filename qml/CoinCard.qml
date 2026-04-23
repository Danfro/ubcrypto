import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3 // Import for RowLayout and Layout.fillWidth
import "theme.js" as AppTheme


ListItem {
    id: coinCard
    anchors.margins: units.gu(0.5) // Margin around the whole card

    // Properties... (keep all your properties as they are)
    property string coinName: ""
    property string coinSymbol: ""
    property real currentPrice: 0
    property real change24h: 0
    property real change7d: 0
    property int marketCapRank: -1
    property real totalVolume: 0
    property url coinImage: ""

    property real price_change_percentage_1h: 0
    property real price_change_percentage_24h: 0
    property real price_change_percentage_7d: 0
    property real price_change_percentage_30d: 0

    property string formattedTotalVolume: coinCard.formatLargeNumber(totalVolume) // New property

    // Use Layout.implicitHeight for contentRow wrapped by RowLayout
    implicitHeight: contentLayout.implicitHeight + units.gu(2) // Adding padding for top/bottom

    function formatLargeNumber(num) {
        if (Math.abs(num) >= 1000000000) { // Billions
            return (num / 1000000000).toFixed(1) + 'B';
        }
        if (Math.abs(num) >= 1000000) { // Millions
            return (num / 1000000).toFixed(1) + 'M';
        }
        if (Math.abs(num) >= 1000) { // Thousands
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toFixed(0); // For numbers less than 1000, just show as is (no decimals for whole numbers)
    }

    // Use RowLayout for the main horizontal arrangement
    RowLayout { // Replaced the outer Row with RowLayout
        id: contentLayout // Renamed from contentRow for clarity with Layouts
        width: parent.width // Fills the width of coinCard
        anchors.margins: units.gu(1) // Padding inside the card

        // ─── Coin Icon ───
        Rectangle {
            width: units.gu(6)
            height: units.gu(6)
            Layout.preferredWidth: width // Tell Layout to use this width
            Layout.preferredHeight: height // Tell Layout to use this height
            color: "transparent"
            Image {
                anchors.centerIn: parent
                source: coinImage
                width: parent.width * 0.8
                height: parent.height * 0.8
                fillMode: Image.PreserveAspectFit
                smooth: true
                cache:true
            }
        }

        // ─── Coin Name + Symbol (This will take up remaining space) ───
        Column {
            Layout.fillWidth: true // This column will take all available horizontal space
            Layout.alignment: Qt.AlignVCenter // Vertically center within the row
            spacing: 0

            Text {
                text: coinName
                width:parent.width
                font.pixelSize: units.gu(2.5)
                //font.bold: true
                color: AppTheme.getThemeColors(theme.name).textColorPrimary
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                // elide: Text.ElideRight // Consider elide if name can be very long
                // No explicit width, Layout.fillWidth on parent Column handles it
            }

            Text {
                text: coinSymbol.toUpperCase() + " #" + marketCapRank
                font.pixelSize: units.gu(1.6)
                color: AppTheme.getThemeColors(theme.name).textColorPrimary
            }

            Text {
                text: i18n.tr("Volume: ") + formattedTotalVolume
                font.pixelSize: units.gu(1.6)
                color: AppTheme.getThemeColors(theme.name).textColorPrimary
            }
        }

        // ─── Price + Change Stats ───
        Column {
            // Option 1: Fixed width for the price column (e.g., 50% of the main card's width)
            // This is often easier for responsive design than trying to target "screen width" directly.
            width: coinCard.width * 0.45 // Example: Make it 45% of the CoinCard's width
            Layout.preferredWidth: width // Tell Layout to use this width
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter // Align to right and center vertically
            spacing: units.gu(0.5) // Reduced spacing for better vertical compactness

            // Option 2: If you REALLY want 50% of the *screen* width, and coinCard is full width,
            // then `width: coinCard.width * 0.5` is correct. If `coinCard` is not full width,
            // you'd need to access `Screen.width` or `ApplicationWindow.width` and calculate.
            // For now, `coinCard.width * 0.45` is robust as `coinCard` is `width: parent.width`.


            PriceWidget {
                value: currentPrice
                font.pixelSize: units.gu(2)
                font.bold: false
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                horizontalAlignment: Text.AlignHCenter // Align text right
            }

            ChangeStats {
                width: parent.width // Takes full width of this column
                change1h: price_change_percentage_1h
                change24h: price_change_percentage_24h
                change7d: price_change_percentage_7d
                change30d: price_change_percentage_30d
            }
        }
    }

    // Stylish Bottom Separator
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: AppTheme.getThemeColors(theme.name).separatorColor
    }
}
