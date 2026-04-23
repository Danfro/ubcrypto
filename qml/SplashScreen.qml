// SplashScreen.qml
import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Controls 2.2
import "theme.js" as AppTheme

Rectangle {
    id: splashScreen
    anchors.fill: parent
    color: "white"

    signal finished()

    Column {
        anchors.centerIn: parent
        spacing: units.gu(1)
        width: parent.width * 0.8
        height: childrenRect.height

        Image {
            source: "../assets/logo.png"
            width: units.gu(15)
            height: units.gu(15)
            fillMode: Image.PreserveAspectFit
            smooth: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: i18n.tr("UBCrypto")
            font.pixelSize: units.gu(4)
            font.bold: true
            color: "#333"
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        // --- Your Catchy Tagline with a simple Fade-In Animation ---
        Text {
            id: taglineText // Added an ID for clarity
            text: i18n.tr("Your Market Insights, Instantly.")
            font.pixelSize: units.gu(2.2)
            color: "#666"
            horizontalAlignment: Text.AlignHCenter
            width: parent.width

            // --- Animation Part ---
            opacity: 0 // Start invisible

            SequentialAnimation on visible { // When this Text item becomes visible
                running: true // Ensure the animation plays
                PropertyAnimation {
                    target: taglineText // Animate this specific Text item
                    property: "opacity" // Animate its opacity
                    from: 0             // Start completely transparent
                    to: 1               // End fully opaque
                    duration: 800       // Take 0.8 seconds to fade in
                    easing.type: Easing.OutSine // A smooth, natural fade
                }
            }
            // --- End Animation Part ---
        }

    }

    Timer {
        id: splashTimer
        interval: 1000
        running: true
        onTriggered: {
            splashScreen.finished() // Signal that the splash is done after the timer
            running = false
        }
    }
}
