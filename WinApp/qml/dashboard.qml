import QtQuick
import QtQuick.Controls

Item {
    width: 1920
    height: 1080

    Image {
        id: background1
        width: 1920
        height: 1080
        source: "../material/bg1.png"
    }

    Connections {
        target: backend
        onSendData: (data) => {
        }
    }

}
