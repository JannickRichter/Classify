import QtQuick
import QtQuick.Controls
import QtCharts

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

                ChartView {
                    id: chartView
                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: false

                    // X-Achse: DateTimeAxis zeigt das Datum an (Format z.B. "09 Dez")
                    DateTimeAxis {
                        id: dateAxis
                        format: "dd MMM"
                        tickCount: 6
                    }

                    // Y-Achse: ValueAxis von 0 bis 15 mit 16 Ticks, die ganze Zahlen anzeigen
                    ValueAxis {
                        id: valueAxis
                        min: 0
                        max: 15
                        tickCount: 16
                        labelFormat: "%d"
                    }

                    // Linie, die die Datenpunkte verbindet
                    LineSeries {
                        id: lineSeries
                        axisX: dateAxis
                        axisY: valueAxis
                    }
                }

                // Funktion, die den JSON-String verarbeitet und die Daten in die LineSeries überträgt
                function processChartData(jsonStr) {
                    var data = JSON.parse(jsonStr);
                    lineSeries.clear();

                    var minTime = Number.MAX_VALUE;
                    var maxTime = 0;

                    for (var i = 0; i < data.length; i++) {
                        var entry = data[i];
                        // Konvertiere das Datum (Format "YYYY-MM-DD") in einen Zeitstempel
                        var timeValue = new Date(entry.week).getTime();
                        lineSeries.append(timeValue, entry.average);
                        if (timeValue < minTime)
                            minTime = timeValue;
                        if (timeValue > maxTime)
                            maxTime = timeValue;
                    }
                    // Setze den Bereich der X-Achse basierend auf den Daten
                    dateAxis.min = new Date(minTime);
                    dateAxis.max = new Date(maxTime);
                }

                // Connections-Element, das das Signal vom Python-Backend empfängt
                Connections {
                    target: backend
                    function onSendData(usage, data) {
                        // Hier gehen wir davon aus, dass das Signal so definiert ist, dass usage und data als Strings übertragen werden.
                        if (usage == "chart") {
                            processChartData(data);
                        }
                    }
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
}
