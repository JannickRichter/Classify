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

                            backend.getMarkStatistic(3)
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

            Rectangle {
                id: rectangle5
                color: "#ffffff"
                anchors.fill: parent

                Item {
                    id: row4
                    width: 2 * parent.width / 8
                    height: 70
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 30
                    anchors.bottomMargin: 30

                    Text {
                        id: _text6
                        text: qsTr("Schulklasse:")
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item {
                        id: _item1
                        anchors.left: _text6.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0

                        ComboBox {
                            id: comboBox1
                            y: 8
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 30
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: ["12/2", "12/1", "11/2", "11/1", "10/2", "10/1", "9/2", "9/1", "8/2", "8/1", "7/2", "7/1"]
                            font.pointSize: 20
                            onActivated: {
                                backend.noteClass(comboBox1.currentText);
                                backend.getMarkStatistic(0);
                            }
                        }
                    }

                }

                Item {
                    id: _item4
                    width: 125
                    height: 500
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 30
                    anchors.topMargin: 0

                    Text {
                        id: _text7
                        height: 0
                        text: qsTr("schriftliche Prüfungen")
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
                        font.pixelSize: 8
                    }

                    CheckBox {
                        id: checkBox
                        y: 20
                        height: 40
                        text: qsTr("Mathe")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 20
                        font.pixelSize: 22
                        font.underline: false
                    }

                    CheckBox {
                        id: checkBox1
                        text: qsTr("Deutsch")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 60
                        font.pixelSize: 22
                    }

                    CheckBox {
                        id: checkBox2
                        text: qsTr("Englisch")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 100
                        font.pixelSize: 22
                    }

                    CheckBox {
                        id: checkBox3
                        text: qsTr("Biologie")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 140
                        font.pixelSize: 22
                    }

                    CheckBox {
                        id: checkBox4
                        text: qsTr("Chemie")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 180
                        font.pixelSize: 22
                    }
                }


            }
        }

        // Component für die Notenstatistik-Seite

        Component {
            id: notenStatistikPage
            Rectangle {
                anchors.fill: parent
                radius: 20

                ChartView {
                    id: chartView
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: row1.top
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    anchors.topMargin: 30
                    anchors.bottomMargin: 30
                    antialiasing: true
                    legend.visible: false

                    // X-Achse: DateTimeAxis zeigt das Datum an (Format z.B. "09 Dez")
                    DateTimeAxis {
                        id: dateAxis
                        format: "dd MMM"
                        tickCount: 10
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
                        color: "#a17c6b"
                    }
                }

                Item {
                    id: row1
                    x: 30
                    y: 710
                    height: 70
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    anchors.bottomMargin: 30



                    Rectangle {
                        id: rectangle6
                        width: 3 * parent.width / 8
                        color: "#e0e0e0"
                        radius: 20
                        anchors.left: row2.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
                        anchors.bottomMargin: 0

                        Text {
                            id: _text4
                            x: 1086
                            y: 19
                            text: qsTr("Notendurchschnitt:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            font.pixelSize: 24
                        }

                        Item {
                            id: _item
                            x: 1690
                            y: 0
                            anchors.left: _text4.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0

                            Rectangle {
                                id: rectangle4
                                x: 64
                                y: 8
                                width: background1.width / 13
                                color: "#a17c6b"
                                radius: 15
                                border.width: 0
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 8
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8

                                Text {
                                    id: _text5
                                    text: qsTr("-")
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 28
                                    font.bold: true
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            ComboBox {
                                id: comboBox
                                y: 7
                                anchors.left: parent.left
                                anchors.right: rectangle4.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8
                                model: ["2024/2", "2024/1", "2023/2", "2023/1", "2022/2", "2022/1", "2021/2", "2021/1", "2020/2", "2020/1", "2019/2", "2019/1"]
                                font.pointSize: 20
                                onActivated: {
                                    backend.getAverage(comboBox.currentText);
                                }
                            }

                        }
                    }

                    Item {
                        id: row4
                        width: 2 * parent.width / 8
                        height: parent.height

                        Text {
                            id: _text6
                            text: qsTr("Schulklasse:")
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 24
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Item {
                            id: _item1
                            anchors.left: _text6.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 0
                            anchors.rightMargin: 0
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0

                            ComboBox {
                                id: comboBox1
                                y: 8
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: ["12/2", "12/1", "11/2", "11/1", "10/2", "10/1", "9/2", "9/1", "8/2", "8/1", "7/2", "7/1"]
                                font.pointSize: 20
                                onActivated: {
                                    backend.noteClass(comboBox1.currentText);
                                    backend.getMarkStatistic(0);
                                }
                            }
                        }

                    }
                    Item {
                        id: row2
                        width: 3 * parent.width / 8
                        height: parent.height
                        anchors.left: row4.right
                        anchors.leftMargin: 0
                        clip: false

                        Text {
                            id: _text2
                            text: qsTr("Zeitrahmen:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            font.pixelSize: 24
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignTop
                        }

                        Slider {
                            id: slider
                            value: 3
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: _text2.right
                            anchors.right: _text3.left
                            anchors.leftMargin: 30
                            anchors.rightMargin: 30
                            snapMode: RangeSlider.SnapOnRelease
                            stepSize: 1
                            to: 12
                            from: 1

                            onValueChanged: {
                                _text3.text = slider.value + " Monat(e)";
                            }
                            onPressedChanged: {
                                if (!pressed) {
                                    backend.getMarkStatistic(parseInt(Math.round(value, 0)))
                                }
                            }
                        }

                        Text {
                            id: _text3
                            text: qsTr("3 Monat(e)")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 30
                            font.pixelSize: 24
                        }
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
                        } else if (usage == "average") {
                            if (data) {
                                _text5.text = data;
                            }
                        } else if (usage == "chart_scale") {
                            if (data) {
                                valueAxis.tickCount = parseInt(data);
                                valueAxis.max = parseInt(data);
                            }
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
