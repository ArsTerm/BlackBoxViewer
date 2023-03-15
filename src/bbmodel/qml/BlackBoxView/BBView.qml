import BBViewer 1.0
import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    property alias bbSource: model.source
    property alias value: model.value
    property alias step: model.step
    property real topPadding: 50
    property real labelHeight: 50

    NameInput {
        z: 10
        x: 5
        width: parent.width / 2
        height: topPadding
        name: value
        onChoisedName: {
            value = name
            nameModel = null
        }
        onBeginInput: nameModel = model.finder()
    }

    TextInput {
        text: model.step
        x: parent.width / 2 + 5
        width: parent.width - x
        height: topPadding
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.preferShaping: false
        font.pixelSize: 25
        //        fontSizeMode: Text.Fit
        color: "white"
        onAccepted: {
            model.step = text
            console.log("Model step:", model.step)
        }
    }

    MouseArea {
        x: parent.width / 2 - width / 2
        width: 100
        height: 50
        onClicked: {
            console.log("Set sign");
            model.setSign(true)
        }
    }

    ListView {
        id: view
        y: topPadding
        width: parent.width
        height: parent.height - labelHeight - y
        orientation: ListView.Horizontal
        interactive: false
        property real valueHeight: height / model.maxVal / 2

        model: BBModel {
            id: model
            maxVal: 256
        }

        delegate: Item {
            width: view.width / 100
            Rectangle {
                color: "green"
                y: view.height / 2 - display * view.valueHeight - height / 4
                width: (nextValue !== display) ? parent.width : parent.width
                height: 3
            }
            Rectangle {
                color: "green"
                y: Math.floor(
                       -(nextValue < display ? display * view.valueHeight : nextValue
                                               * view.valueHeight) + view.height / 2)
                x: Math.min(1, parent.width - 3)
                width: 3
                height: Math.abs((display - nextValue)) * view.valueHeight
                        + (nextValue < display ? view.valueHeight * 3 : 0)
            }
        }

        MouseArea {
            anchors.fill: parent
            property real xBegin
            onPressed: xBegin = mouse.x
            onPositionChanged: {
                let positionStep = Math.round((mouse.x - xBegin) / 2)
                if (Math.abs(positionStep) > 0) {
                    xBegin = mouse.x
                }

                if (model.position + positionStep <= 0) {
                    model.position = 0
                } else {
                    model.position += positionStep
                }
            }
        }

        Rectangle {
            y: parent.height / 2
            color: "#555555"
            width: parent.width
            height: 1
        }
        Rectangle {
            y: parent.height / 4
            color: "#555555"
            width: parent.width
            height: 1
        }
        Rectangle {
            y: parent.height / 2 + parent.height / 4
            color: "#555555"
            width: parent.width
            height: 1
        }
    }

    Text {
        text: model.position
        y: view.height + topPadding
        height: parent.labelHeight
        width: height * 2
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: "white"
    }

    Text {
        text: -model.maxVal
        y: view.height + topPadding - 25
        x: -50
        width: 45
        height: 50
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: -model.maxVal / 2
        y: view.height * 3 / 4 + topPadding - 25
        x: -50
        width: 45
        height: 50
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.maxVal
        y: topPadding - 25
        x: -43
        width: 38
        height: 50
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.maxVal / 2
        y: topPadding + view.height / 4 - 25
        x: -43
        width: 38
        height: 50
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: "0"
        y: topPadding + view.height / 2 - 25
        x: -40
        width: 35
        height: 50
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.position + 100 * model.step
        y: view.height + topPadding
        x: parent.width - width
        height: parent.labelHeight
        width: height * 2
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Rectangle {
        z: -1
        y: topPadding
        color: "black"
        width: parent.width
        height: view.height + 1
        border.color: "white"
        border.width: 1
    }
}
