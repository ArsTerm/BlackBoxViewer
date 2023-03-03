import QtQuick.Window 2.15
import QtQuick 2.15
import BBViewer 1.0

Window {
    width: 800
    height: 600
    color: "black"
    visible: true

    ListView {
        id: view
        x: parent.width / 4
        y: parent.height / 4
        width: parent.width / 2
        height: parent.height / 2
        orientation: ListView.Horizontal
        interactive: false
        property real valueHeight: height / 255
        model: BBModel {
            id: model
            source: "file:C:\\Projects\\02171842"
            value: "c_secs"
        }

        MouseArea {
            anchors.fill: parent
            property real xBegin
            onPressed: xBegin = mouse.x
            onPositionChanged: {
                let positionStep = Math.round((mouse.x - xBegin) * 10)
                if (positionStep > 0) {
                    xBegin = mouse.x
                }

                if (model.position + positionStep <= 0) {
                    model.position = 0
                } else {
                    model.position += positionStep
                }
            }
        }

        Text {
            y: view.height
            x: -width / 2
            text: model.position
            width: 100
            height: 50
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
        }

        Text {
            text: model.position + 100
            y: view.height
            x: view.width - width / 2
            width: 100
            height: 50
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "white"
        }

        delegate: Rectangle {
            color: "green"
            y: view.height / 2 - display * view.valueHeight - height / 4
            width: view.width / 100
            height: 3
        }
        Rectangle {
            color: "transparent"
            width: parent.width
            height: parent.height
            border.color: "white"
            border.width: 1
        }
        Rectangle {
            color: "#555555"
            width: parent.width
            height: 1
            y: parent.height / 2
        }
        Rectangle {
            color: "#555555"
            width: parent.width
            height: 1
            y: parent.height / 4
        }
        Rectangle {
            color: "#555555"
            width: parent.width
            height: 1
            y: parent.height / 2 + parent.height / 4
        }
    }
}
