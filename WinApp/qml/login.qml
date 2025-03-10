import QtQuick
import QtQuick.Controls

Item {
    id: _item
    Image {
        id: background
        width: 2127
        height: 1276
        source: "../material/bg1.png"

        // Parallax-Bewegung basierend auf der Maus
        x: -101 + -(mouseArea.mouseX - width / 2) * 0.025
        y: -110 + -(mouseArea.mouseY - height / 2) * 0.025

        // Sanfte Animation
        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
        }
        Behavior on y {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
        }
    }

    Image {
        id: image1
        x: 1586
        y: 829
        width: 100
        height: 100
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 50
        anchors.bottomMargin: 50
        source: "../material/edu_logo.png"
        fillMode: Image.PreserveAspectFit
    }

    Rectangle {
        id: rectangle1
        width: 692
        height: 334
        color: "#ffffff"
        radius: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 100
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            id: column
            width: parent.width
            spacing: 24
            padding: 20

            // Subdomain Eingabefeld
            Row {
                id: row
                width: parent.width
                spacing: 20
                Text {
                    id: _text
                    width: 200
                    height: 50
                    text: qsTr("Subdomain:")
                    font.pixelSize: 30
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Arial"
                }

                Rectangle {
                    id: rectangle2
                    width: 380
                    height: 50
                    color: "#eeeeee"
                    radius: 20
                    border.color: "#eeeeee"
                    TextInput {
                        id: textInput
                        text: qsTr("")
                        anchors.fill: parent
                        font.pixelSize: 30
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        persistentSelection: true
                        font.family: "Arial"
                    }
                }
            }

            // Username Eingabefeld
            Row {
                id: row1
                width: parent.width
                spacing: 20
                Text {
                    id: _text1
                    width: 200
                    height: 50
                    text: qsTr("Username:")
                    font.pixelSize: 30
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Arial"
                }

                Rectangle {
                    id: rectangle3
                    width: 380
                    height: 50
                    color: "#eeeeee"
                    radius: 20
                    TextInput {
                        id: textInput1
                        text: qsTr("")
                        anchors.fill: parent
                        font.pixelSize: 30
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        persistentSelection: true
                        font.family: "Arial"
                    }
                }
            }

            // Passwort Eingabefeld
            Row {
                id: row2
                width: parent.width
                spacing: 20
                Text {
                    id: _text2
                    width: 200
                    height: 50
                    text: qsTr("Password:")
                    font.pixelSize: 30
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Arial"
                }

                Rectangle {
                    id: rectangle4
                    width: 380
                    height: 50
                    color: "#eeeeee"
                    radius: 20
                    TextInput {
                        id: textInput2
                        text: qsTr("")
                        anchors.fill: parent
                        font.pixelSize: 30
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        echoMode: TextInput.Password
                        persistentSelection: true
                        font.family: "Arial"
                    }
                }
            }
        }

        // Login Button
        Button {
            id: button
            x: 156
            y: 242
            width: 380
            height: 60
            text: qsTr("Einloggen")
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            font.family: "Arial"
            flat: false
            font.pointSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                backend.login(textInput.text, textInput1.text, textInput2.text)
            }
        }
    }

    // Logo Bild
    Image {
        id: image
        width: 692
        height: 175
        anchors.bottom: rectangle1.top
        anchors.bottomMargin: 32
        source: "../material/icon2.png"
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.height: 265
        sourceSize.width: 300
        fillMode: Image.PreserveAspectFit
    }

    // Ladeindikator
    BusyIndicator {
        id: busyIndicator
        width: 110
        height: 110
        anchors.verticalCenter: parent.verticalCenter
        hoverEnabled: true
        enabled: false
        visible: false
        wheelEnabled: false
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // Mausbereich für Parallax-Effekt
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true       // Bewegung wird bei Hover registriert
        acceptedButtons: Qt.NoButton

        // Keine Klick-Ereignisse blockieren
    }

    // Verbindungen zum Backend
    Connections {
        target: backend

        // Zeigt den Ladeindikator an, wenn die Login-Anfrage gesendet wird
        function onLoginAttention() {
            busyIndicator.enabled = true
            busyIndicator.visible = true
        }

        // Verarbeitet das Login-Ergebnis
        function onLoginSuccess(success) {
            if (!success) {
                busyIndicator.enabled = false
                busyIndicator.visible = false
                button.text = "Erneut versuchen"
            }
        }
    }
}
