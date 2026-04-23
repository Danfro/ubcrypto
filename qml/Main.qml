// qml/Main.qml
import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4
import "db_core.js" as DBCore
import "theme.js" as AppTheme


MainView {
    id: mainView
    applicationName: "ubcrypto"
    property int selectedTab: 0

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("../src/"));
            importModule("cli", function () {
                python.call("cli.start_background_sync",  function (result) {
                    console.log("Started")
                });
            });
        }

        onError: function (errorName, errorMessage, traceback) {
            console.log("Python Error:", errorName, errorMessage, traceback);
        }
    }

    // Loader section (main content)
    Loader {
        id: pageLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: navBar.top
        sourceComponent: getPage(selectedTab)
    }

    // Bottom nav bar (no overlap)
    Rectangle {
        id: navBar
        anchors.left: parent.left
        //anchors.leftMargin: units.gu(1)
        //anchors.rightMargin: units.gu(1)
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: units.gu(7)
        color: "#1c1c1e" // Deep charcoal black (used in macOS/iOS dark mode)
        border.color: "#333" // Subtle border for separation
        Row {
            anchors.centerIn: parent
            anchors.left: navBar.left
            spacing: units.gu(0.5)

            Repeater {
                model: [
                    {
                        name: i18n.tr("HOME")
                    },
                    {
                        name: i18n.tr("PORTFOLIO")
                    },
                    {
                        name: i18n.tr("NEWS")
                    },
                    {
                        name: i18n.tr("ABOUT")
                    }
                ]

                delegate: MouseArea {
                    width: units.gu(12)
                    height: navBar.height
                    onClicked: {
                        selectedTab = index;
                        pageLoader.sourceComponent = getPage(selectedTab);
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Text {
                            text: modelData.name
                            anchors.centerIn: parent
                            font.pixelSize: units.gu(2)
                            font.bold: true
                            color: selectedTab === index ? LomiriColors.orange : "#f0f0f0"
                        }
                    }
                }
            }
        }
    }

    // Pages
    function getPage(index) {
        if (index === 0)
            return dashboardPage;
        if (index === 1)
            return portfolioPage;
        if (index === 2)
            return newsPage;
        if (index === 3)
            return aboutPage;
        return dashboardPage;
    }

    Component {
        id: dashboardPage
        DashboardPage {}
    }
    Component {
        id: portfolioPage
        PortfolioPage {}
    }
    Component {
        id: settingsPage
        SettingsPage {}
    }
    Component {
        id: aboutPage
        AboutPage {}
    }
    Component {
            id: newsPage
            NewsPage {}
    }
    SplashScreen{
        id:splash
        onFinished:{
            splash.visible=false
        }
    }

    Component.onCompleted:
    {
        DBCore.initializeDatabase()
        console.log("UBCrypto started and theme used is " + theme.name)
    }
}
