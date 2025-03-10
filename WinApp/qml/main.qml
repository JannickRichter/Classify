import QtQuick
import QtQuick.Controls

//Window starten und maximieren
Window {
    width: 1920
    height: 1080
    visibility: "Maximized"

    visible: true
    title: "Classify"

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: "login.qml"
    }

    // Signal zur Seitenänderung empfangen
    Connections {
        target: backend

        function onLoginSuccess(success) {
            if (success) {
                pageLoader.source = "dashboard.qml"
            }
        }
    }

}
