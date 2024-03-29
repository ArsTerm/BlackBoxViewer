import QtQuick 2.12

Item {
    property alias name: input.text
    property alias nameModel: nameView.model
    property alias active: inputTemp.focus
    signal beginInput
    signal choisedName(string name)

    onChoisedName: {
        inputTempRect.visible = false
        inputTemp.text = ""
    }

    Text {
        id: input
        width: parent.width
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        color: "white"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                inputTempRect.visible = true
                inputTemp.focus = true
                beginInput()
            }
        }
    }

    Rectangle {
        id: inputTempRect
        visible: false
        width: parent.width
        height: parent.height
        color: "white"
        TextInput {
            id: inputTemp
            width: parent.width
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.preferShaping: false
            font.pixelSize: height * 0.75
            color: "black"
            focus: false
            onFocusChanged: {
                if (focus == false)
                    choisedName(name)
            }

            onTextChanged: {
                nameView.model.setTemplate(text)
            }
        }
    }

    ListView {
        id: nameView
        visible: inputTempRect.visible
        y: parent.height
        width: parent.width
        height: parent.height * 5
        clip: true
        delegate: Rectangle {
            color: "black"
            border.color: "white"
            width: ListView.view.width
            height: ListView.view.height / 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    choisedName(display)
                }
            }

            Text {
                text: display
                width: parent.width
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                color: "white"
                font.pixelSize: 25
                fontSizeMode: Text.Fit
            }
        }
    }
}
