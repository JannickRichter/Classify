import QtQuick
import QtQuick.Controls

Item {
    width: 1920
    height: 1080

    property string selector: "statistic"

    Image {
        id: background1
        width: 1920
        height: 1080
        source: "../material/bg1.png"
    }

    Rectangle {
        id: rectangle
        color: "#ffffff"
        radius: 20
        anchors.fill: parent
        anchors.leftMargin: 85
        anchors.rightMargin: 85
        anchors.topMargin: 85
        anchors.bottomMargin: 85

        Rectangle {
            id: rectangle1
            color: "#dbdbdb"
            radius: 20
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.top
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            anchors.topMargin: 30
            anchors.bottomMargin: -100

            Row {
                id: row
                anchors.fill: parent

                Rectangle {
                    id: rectangle2
                    width: row.width / 2
                    height: row.height
                    color: "#dbdbdb"

                    Behavior on color {
                        ColorAnimation {
                            duration: 300  // Übergangsdauer in Millisekunden
                        }
                    }
                    radius: 20

                    Text {
                        id: _text
                        text: qsTr("ABITUR NOTE")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 28
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: mouseArea
                        width: parent.width - 10
                        height: parent.height
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onEntered: parent.color = "#5B7B7A"
                        onExited: {
                            if (selector == "statistic") {
                                rectangle2.color = "#dbdbdb"
                            } else if (selector == "abinote") {
                                rectangle2.color = "#a17c6b"
                            }
                        }
                        onClicked: {
                            selector = "abinote"
                            rectangle2.color = "#a17c6b"
                            rectangle3.color = "#dbdbdb"
                        }
                    }
                }

                Rectangle {
                    id: rectangle3
                    width: row.width / 2
                    height: row.height
                    color: "#a17c6b"

                    Behavior on color {
                        ColorAnimation {
                            duration: 300  // Übergangsdauer in Millisekunden
                        }
                    }
                    radius: 20

                    Text {
                        id: _text1
                        text: qsTr("NOTENSTATISTIK")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 28
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: mouseArea1
                        width: parent.width - 10
                        height: parent.height
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onEntered: rectangle3.color = "#5B7B7A"
                        onExited: {
                            if (selector == "statistic") {
                                rectangle3.color = "#a17c6b"
                            } else if (selector == "abinote") {
                                rectangle3.color = "#dbdbdb"
                            }
                        }
                        onClicked: {
                            selector = "statistic"
                            rectangle3.color = "#a17c6b"
                            rectangle2.color = "#dbdbdb"

                            backend.getMarkStatistic()
                        }
                    }
                }
            }
        }

        // Loader, der den Inhalt unter der Tab-Leiste anzeigt:
        Loader {
            id: tabContent
            anchors.top: rectangle1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            sourceComponent: selector === "statistic" ? notenStatistikPage : abiturnotePage
        }

        // Component für die Notenstatistik-Seite
        Component {
            id: notenStatistikPage
            Rectangle {
                anchors.fill: parent
                radius: 20
                Text {
                    text: "Notenstatistik Content"
                    anchors.centerIn: parent
                    font.pixelSize: 32
                }
            }
        }

        // Component für die Abiturnote-Seite
        Component {
            id: abiturnotePage
            Rectangle {
                anchors.fill: parent
                radius: 20
                Text {
                    text: "Abiturnote Content"
                    anchors.centerIn: parent
                    font.pixelSize: 32
                }
            }
        }

    }

    Connections {
        target: backend

        function onSendData(data) {
        }
    }


}
