import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3 // IMPORTANT: Need this for RowLayout and GridLayout properties
import "theme.js" as AppTheme

Item {
    id: changeBox
    property real change1h: 0
    property real change24h: 0
    property real change7d: 0
    property real change30d: 0

    width: parent.width // Component takes the full width available from its parent
    implicitHeight: statGrid.implicitHeight + anchors.margins * 2

    GridLayout {
        id: statGrid
        columns: 2 // We have 2 main columns for the layout (e.g., 1h block and 24h block)
        columnSpacing: units.gu(1) // Spacing between stat blocks (e.g., 1h and 24h)
        rowSpacing: units.gu(0.8)   // Spacing between rows of stat blocks (e.g., 1st row vs 2nd row)
        anchors.fill: parent // Makes the grid fill the entire changeBox item
        anchors.margins: units.gu(0.5)

        // --- First Row ---

        // Container for 1h stat (occupies first cell in first row)
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: i18n.tr("1h:")
                color: AppTheme.getThemeColors(theme.name).textColorPrimary
                font.pixelSize: units.gu(1.8)
            }

            Rectangle {
                color: change1h >= 0 ? "#28a745" : "#dc3545"
                radius: units.gu(0.5)
                Layout.alignment: Qt.AlignVCenter
                // Optional: add margin/padding around text using anchors
                // Alternatively, use left/right padding rectangles inside

                // Auto-size to text
                width: labelText.implicitWidth + units.gu(1.5)
                height: labelText.implicitHeight + units.gu(0.5)

                Text {
                    id: labelText
                    text: (change1h >= 0 ? "+" : "") + change1h.toFixed(1) + "%"
                    color: "white"
                    font.bold: true
                    font.pixelSize: units.gu(1.6)
                    anchors.centerIn: parent
                }
            }
        }


        // Container for 24h stat (occupies second cell in first row)
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: i18n.tr("24h:")
                color:  AppTheme.getThemeColors(theme.name).textColorPrimary
                font.pixelSize: units.gu(1.8)
            }

            Rectangle {
                color: change24h >= 0 ? "#28a745" : "#dc3545"  // Soft green or red
                radius: units.gu(0.5)
                Layout.alignment: Qt.AlignVCenter
                width: labelText24.implicitWidth + units.gu(1.5)
                height: labelText24.implicitHeight + units.gu(0.5)

                Text {
                    id: labelText24
                    text: (change24h >= 0 ? "+" : "") + change24h.toFixed(1) + "%"
                    color: "white"
                    font.bold: true
                    font.pixelSize: units.gu(1.6)
                    anchors.centerIn: parent
                }
            }
        }


        // --- Second Row ---
/*
        // Container for 7d stat (occupies first cell in second row)
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: i18n.tr("7d:")
                color: "#AAA"
                font.pixelSize: units.gu(1.5)
            }
            Text {
                text: (change7d >= 0 ? "+" : "") + change7d.toFixed(2) + "%"
                color: change7d >= 0 ? "green" : "red"
                font.pixelSize: units.gu(1.5)
               // font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }

        // Container for 30d stat (occupies second cell in second row)
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: i18n.tr("30d:")
                color: "#AAA"
                font.pixelSize: units.gu(1.5)
            }
            Text {
                text: (change30d >= 0 ? "+" : "") + change30d.toFixed(2) + "%"
                color: change30d >= 0 ? "green" : "red"
                font.pixelSize: units.gu(1.5)
               //  font.bold: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }*/
    }
}
