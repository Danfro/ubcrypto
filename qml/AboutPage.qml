// qml/AboutPage.qml
import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2 // For potential Heading or more styled Text
import Qt.labs.platform 1.0 as Platform // For opening external links (if available on UT)
import "theme.js" as AppTheme


Page {
    id: aboutPage
    header: PageHeader {
        title: "About UBCrypto"
    }

    Flickable {
        anchors.fill: parent
        // Use Flickable's internal anchors for padding, not contentCol's anchors.margins
        anchors.margins: units.gu(2) // Margins for the entire scrollable area
        contentHeight: contentCol.implicitHeight // Use implicitHeight for robust sizing
        clip: true // Ensure content doesn't draw outside bounds

        Column {
            id: contentCol
            width: parent.width // Column fills the Flickable's width
            spacing: units.gu(2) // Increased spacing between major sections for better visual separation

            // --- Section: About UBCrypto ---
            Text {
                text: i18n.tr("UBCrypto")
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                font.pixelSize: units.gu(3) // Larger font for app name
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Text {
                text: i18n.tr("Your essential lightweight cryptocurrency tracking app for Ubuntu Touch. Stay informed with live market data, manage your personal portfolio, and enjoy a clean, intuitive user interface designed for mobile.")
                font.pixelSize: units.gu(1.8)
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle { width: parent.width; height: 1; color: "#e0e0e0";  } // Subtle separator


            // --- Section: Key Features ---
            Text {
                text: i18n.tr("Key Features")
                font.pixelSize: units.gu(2.2) // Heading size
                font.bold: true
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                width: parent.width
                horizontalAlignment: Text.AlignLeft // Align left
            }

            // Using HTML list for features
            Text {
                textFormat: Text.RichText // Enable HTML rendering
                font.pixelSize: units.gu(1.8)
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                width: parent.width
                wrapMode: Text.WordWrap
                text: "<ul>" + // Unordered list
                      "<li>Beta Release, Will provide more features such as Portfolio Management in the next releases</li>" +
                      "<li>Real-time Price Tracking and Market Data</li>" +
                      "<li>Personalized Portfolio Management (Coming Soon / Future Feature)</li>" +
                      "<li>Offline Support for Cached Data</li>" +
                      "<li>Clean &amp; Intuitive User Interface</li>" + // &amp; for '&'
                      "<li>Built with Python &amp; Qt/QML for a Native Experience</li>" +
                      "</ul>"
            }

            Rectangle { width: parent.width; height: 1; color: "#e0e0e0"; } // Subtle separator

            // --- Section: Links ---
            Text {
                text: i18n.tr("Links")
                font.pixelSize: units.gu(2)
                font.bold: true
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                width: parent.width
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: i18n.tr("Source Code :") + "https://github.com/karthagokul/ubcrypto"
                font.pixelSize: units.gu(1.6)
                color:AppTheme.getThemeColors(theme.name).textColorPrimary
                textFormat: Text.RichText
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Qt.openUrlExternally("https://github.com/karthagokul/ubcrypto");
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color:AppTheme.getThemeColors(theme.name).separatorColor; } // Subtle separator

        }
    }
}
