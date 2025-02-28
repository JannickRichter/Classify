import QtQuick
import QtQuick.Controls

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

    Connections {
        target: backend

        function onSendData(usage, data) {
            if (data) {
                pageLoader.source = "dashboard.qml"
            }
        }
    }

}
