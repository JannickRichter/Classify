import QtQuick
import QtQuick.Controls
import QtCharts

Item {
    width: 1920
    height: 1080

    // String für die Tab-Auswahl
    property string selector: "statistic"
    property int classSelection: 0

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

                // Erster Tab: Abitur Note
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

                // Zweiter Tab: Notenstatistik
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

                    // X-Achse: DateTimeAxis zeigt das Datum an
                    DateTimeAxis {
                        id: dateAxis
                        format: "dd MMM"
                        tickCount: 10
                    }

                    // Y-Achse: ValueAxis von 0 bis 15 mit 16 Ticks
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

                    // Notendurchschnitt-Anzeige
                    Rectangle {
                        id: rectangle6
                        width: 3 * parent.width / 8
                        color: "#e0e0e0"
                        radius: 20
                        anchors.left: row2.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        Text {
                            id: _text4
                            text: qsTr("Notendurchschnitt:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            font.pixelSize: 24
                        }

                        Item {
                            id: _item
                            anchors.left: _text4.right
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom

                            Rectangle {
                                id: rectangle4
                                width: background1.width / 13
                                color: "#a17c6b"
                                radius: 15
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
                                    backend.getAverage(comboBox.currentText.toString());
                                }
                            }
                        }
                    }

                    // Schulklasse-Auswahl
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

                            ComboBox {
                                id: comboBox1
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: ["12/2", "12/1", "11/2", "11/1", "10/2", "10/1", "9/2", "9/1", "8/2", "8/1", "7/2", "7/1"]
                                font.pointSize: 20
                                currentIndex: classSelection
                                onActivated: {
                                    backend.noteClass(comboBox1.currentText);
                                    backend.getMarkStatistic(0);
                                    classSelection = parseInt(comboBox1.currentIndex);
                                }
                            }
                        }
                    }

                    // Zeitrahmen-Auswahl
                    Item {
                        id: row2
                        width: 3 * parent.width / 8
                        height: parent.height
                        anchors.left: row4.right

                        Text {
                            id: _text2
                            text: qsTr("Zeitrahmen:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 30
                            font.pixelSize: 24
                            horizontalAlignment: Text.AlignHCenter
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

                // JSON-String verarbeiten und Daten in LineSeries übertragen
                function processChartData(jsonStr) {
                    var data = JSON.parse(jsonStr);
                    lineSeries.clear();

                    var minTime = Number.MAX_VALUE;
                    var maxTime = 0;

                    for (var i = 0; i < data.length; i++) {
                        var entry = data[i];
                        // Konvertiere das Datum in TimeStemp
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

                // Connections-Element, empfängt gesandte Daten vom Backend
                Connections {
                    target: backend
                    function onSendData(usage, data) {
                        // Prüfen des Usage und Aktion ausführen (Daten eintragen, Durchschnitt ändern, Diagramm Skalierung)
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
            
            Item {
                id: abiturnoteWrapper
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
                            currentIndex: classSelection
                            onActivated: {
                                backend.noteClass(comboBox1.currentText);
                                backend.getMarkStatistic(0);
                                classSelection = parseInt(comboBox1.currentIndex);
                            }
                        }
                    }

                }

                Item {
                    id: _item4
                    width: background1.width * 0.7
                    anchors.top: parent.top
                    anchors.bottom: row4.bottom
                    anchors.topMargin: 50
                    anchors.bottomMargin: 50
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: _text7
                        text: qsTr("Wähle 5 Prüfungsfächer!")
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
                        font.pixelSize: 28
                        font.bold: true
                    }

                    Item {
                        id: _item2
                        height: 450
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: _text7.bottom
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        anchors.topMargin: 30

                        Rectangle {
                            id: rectangle7
                            x: 0
                            width: (parent.width - 90) / 4
                            color: "#80a17c6b"
                            radius: 20
                            border.width: 0
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0




                            Text {
                                id: _text8
                                text: qsTr("Naturwissenschaften")
                                anchors.top: parent.top
                                anchors.topMargin: 15
                                font.pixelSize: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                id: _item3
                                x: 30
                                y: 77
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: _text8.bottom
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 15
                                anchors.bottomMargin: 0

                                CheckBox {
                                    id: checkBox
                                    x: -30
                                    y: -57
                                    text: qsTr("Mathe")
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                    font.underline: false
                                }

                                CheckBox {
                                    id: checkBox2
                                    x: -30
                                    y: 23
                                    text: qsTr("Physik")
                                    anchors.left: parent.left
                                    anchors.top: checkBox.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox3
                                    x: -30
                                    y: 63
                                    text: qsTr("Biologie")
                                    anchors.left: parent.left
                                    anchors.top: checkBox2.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox4
                                    x: -30
                                    y: 103
                                    text: qsTr("Chemie")
                                    anchors.left: parent.left
                                    anchors.top: checkBox3.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox5
                                    x: -30
                                    text: qsTr("Astronomie")
                                    anchors.left: parent.left
                                    anchors.top: checkBox4.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox10
                                    x: -30
                                    text: qsTr("Informatik")
                                    anchors.left: parent.left
                                    anchors.top: checkBox5.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }
                            }





                        }

                        Rectangle {
                            id: rectangle8
                            width: (parent.width - 90) / 4
                            color: "#806b86a1"
                            radius: 20
                            border.width: 0
                            anchors.left: rectangle7.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 30
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            Text {
                                id: _text9
                                text: qsTr("Sprache")
                                anchors.top: parent.top
                                anchors.topMargin: 15
                                font.pixelSize: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                id: _item5
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: _text9.bottom
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 15
                                anchors.bottomMargin: 0

                                CheckBox {
                                    id: checkBox1
                                    x: -30
                                    y: -57
                                    text: qsTr("Deutsch")
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                    font.underline: false
                                }

                                CheckBox {
                                    id: checkBox6
                                    x: -30
                                    y: 23
                                    text: qsTr("Englisch")
                                    anchors.left: parent.left
                                    anchors.top: checkBox1.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox7
                                    x: -30
                                    y: 63
                                    text: qsTr("Französisch")
                                    anchors.left: parent.left
                                    anchors.top: checkBox6.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox8
                                    x: -30
                                    y: 103
                                    text: qsTr("Russisch")
                                    anchors.left: parent.left
                                    anchors.top: checkBox7.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox9
                                    x: -30
                                    text: qsTr("Latein")
                                    anchors.left: parent.left
                                    anchors.top: checkBox8.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox11
                                    x: -30
                                    text: qsTr("Italienisch")
                                    anchors.left: parent.left
                                    anchors.top: checkBox9.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }
                            }
                        }

                        Rectangle {
                            id: rectangle9
                            width: (parent.width - 90) / 4
                            color: "#806ba186"
                            radius: 20
                            border.width: 0
                            anchors.left: rectangle8.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 30
                            anchors.topMargin: 0
                            anchors.bottomMargin: 0
                            Text {
                                id: _text10
                                text: qsTr("Gesellschaft")
                                anchors.top: parent.top
                                anchors.topMargin: 15
                                font.pixelSize: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                id: _item6
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: _text10.bottom
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 15
                                anchors.bottomMargin: 0
                                CheckBox {
                                    id: checkBox12
                                    x: -30
                                    y: -57
                                    text: qsTr("Wirtschaft")
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                    font.underline: false
                                }

                                CheckBox {
                                    id: checkBox13
                                    x: -30
                                    y: 23
                                    text: qsTr("Geschichte")
                                    anchors.left: parent.left
                                    anchors.top: checkBox12.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox14
                                    x: -30
                                    y: 63
                                    text: qsTr("Geografie")
                                    anchors.left: parent.left
                                    anchors.top: checkBox13.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox15
                                    x: -30
                                    y: 103
                                    text: qsTr("Sozialkunde")
                                    anchors.left: parent.left
                                    anchors.top: checkBox14.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox16
                                    x: -30
                                    text: qsTr("Religion")
                                    anchors.left: parent.left
                                    anchors.top: checkBox15.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }

                                CheckBox {
                                    id: checkBox17
                                    x: -30
                                    text: qsTr("Ethik")
                                    anchors.left: parent.left
                                    anchors.top: checkBox16.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }
                            }
                        }

                        Rectangle {
                            id: rectangle10
                            width: (parent.width - 90) / 4
                            height: (parent.height - 15) / 2
                            color: "#80a16b7b"
                            radius: 20
                            border.width: 0
                            anchors.left: rectangle9.right
                            anchors.top: parent.top
                            anchors.leftMargin: 30
                            anchors.topMargin: 0
                            Text {
                                id: _text11
                                text: qsTr("Künstlerisch")
                                anchors.top: parent.top
                                anchors.topMargin: 15
                                font.pixelSize: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                id: _item7
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: _text11.bottom
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 15
                                anchors.bottomMargin: 0
                                CheckBox {
                                    id: checkBox18
                                    x: -30
                                    y: -57
                                    text: qsTr("Kunst")
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                    font.underline: false
                                }

                                CheckBox {
                                    id: checkBox19
                                    x: -30
                                    y: 23
                                    text: qsTr("Musik")
                                    anchors.left: parent.left
                                    anchors.top: checkBox18.bottom
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                }
                            }
                        }

                        Rectangle {
                            id: rectangle11
                            width: (parent.width - 90) / 4
                            height: (parent.height - 15) / 2
                            color: "#80a18c6b"
                            radius: 20
                            border.width: 0
                            anchors.left: rectangle9.right
                            anchors.top: rectangle10.bottom
                            anchors.leftMargin: 30
                            anchors.topMargin: 15
                            Text {
                                id: _text12
                                text: qsTr("Seminarfach")
                                anchors.top: parent.top
                                anchors.topMargin: 15
                                font.pixelSize: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                id: _item8
                                x: -1001
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: _text12.bottom
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 15
                                anchors.bottomMargin: 0
                                CheckBox {
                                    id: checkBox20
                                    x: -30
                                    y: -57
                                    text: qsTr("Eingebracht:")
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.leftMargin: 0
                                    anchors.topMargin: 0
                                    font.pixelSize: 24
                                    font.underline: false
                                    onCheckedChanged: {
                                        if (checked) {
                                            rectangle12.visible = true;
                                        } else {
                                            rectangle12.visible = false;
                                        }
                                    }
                                }

                                Rectangle {
                                    id: rectangle12
                                    height: 64
                                    color: "#80ffffff"
                                    radius: 25
                                    visible: false
                                    border.width: 0
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: checkBox20.bottom
                                    anchors.leftMargin: 0
                                    anchors.rightMargin: 0
                                    anchors.topMargin: 15

                                    TextInput {
                                        id: textInput
                                        text: qsTr("")
                                        anchors.fill: parent
                                        font.pixelSize: 24
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                            }
                        }


                    }

                    Rectangle {
                        id: rectangle13
                        width: parent.width * 0.3
                        height: 70
                        color: "#a17c6b"
                        radius: 20
                        border.width: 0
                        anchors.top: _item2.bottom
                        anchors.topMargin: 30
                        anchors.horizontalCenter: parent.horizontalCenter

                        Behavior on color {
                            ColorAnimation {
                                duration: 300  // Übergangsdauer in Millisekunden
                            }
                        }

                        MouseArea {
                            id: calculateButtonArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onEntered: {
                                parent.color = "#5B7B7A";
                            }
                            onExited: {
                                parent.color = "#a17c6b";
                            }

                            onClicked: {
                                var checkedItems = []; // Liste für ausgewählte Checkboxen
                                var checkBoxes = []

                                if (checkBox.checked) {
                                    checkedItems.push(checkBox.text);
                                }

                                // Alle Objekte der QML-Hierarchie durchlaufen
                                for (var i = 1; i <= 20; i++) {
                                    var item = eval("checkBox" + i);

                                    // Prüfen, ob die ID "checkBox" enthält und ob das Element eine Checkbox ist
                                    if (item.checked) {
                                        checkedItems.push(item.text);
                                    }
                                }

                                console.log(checkedItems)

                                if (checkedItems.length != 5) {
                                    return;
                                }

                                if (checkedItems.includes("Eingebracht:")) {
                                    backend.getAbiMark(checkedItems[0], checkedItems[1], checkedItems[2], checkedItems[3], checkedItems[4], parseInt(textInput.text))
                                } else {
                                    backend.getAbiMark(checkedItems[0], checkedItems[1], checkedItems[2], checkedItems[3], checkedItems[4], -1)
                                }
                            }
                        }

                        Text {
                            id: _text13
                            text: qsTr("Prognose berechnen")
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 28
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.bold: true
                        }
                    }

                }


            }
        }
    }
}