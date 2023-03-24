import BBViewer 1.0
import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    property alias bbSource: model.source
    property alias canMes: model.canMes
    property alias value: model.value
    property alias step: model.step
    property real topPadding: 50
    property real labelHeight: 50

    function bound(min, max, val) {
        return Math.min(max, Math.max(min, val))
    }

    property real valuesDiff: model.maxVal - model.minVal
    property real verticalStep: valuesDiff / 4

    NameInput {
        id: nameInput
        z: 10
        x: 5
        width: parent.width / 2
        height: topPadding
        name: value
        onChoisedName: {
            value = name
            nameModel = null
            if (viewMouse.containsMouse) {
                view.focus = true
            }
        }
        onBeginInput: {
            nameModel = model.finder()
        }
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
        color: "white"
        onAccepted: {
            model.step = text
        }
    }

    Text {
        text: "Значение: " + model.valueAt(Math.floor(viewMouse.mouseX / (view.width / 128)))
        x: parent.width / 2.5
        width: parent.width / 4
        height: topPadding
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.preferShaping: false
        font.pixelSize: 25
        color: "white"
    }

    ListView {
        id: view
        y: topPadding
        width: parent.width
        height: parent.height - labelHeight - y
        orientation: ListView.Horizontal
        interactive: false
        property real valueHeight: height / (model.maxVal - model.minVal)

        model: BBModel {
            id: model
            maxVal: 256
        }

        delegate: Item {
            width: view.width / 128
            property BBModel model: ListView.view.model
            Rectangle {
                id: itemRect
                color: "green"
                property real value: (display - model.minVal) * view.valueHeight
                y: bound(0, view.height, view.height - value - height / 4)
                width: parent.width
                height: 3
            }
            Rectangle {
                color: "green"
                y: bound(
                       0, view.height, Math.floor(
                           -(nextValue < display ? (display - model.minVal)
                                                   * view.valueHeight : (nextValue - model.minVal)
                                                   * view.valueHeight) + view.height))
                x: Math.min(1, parent.width - 3)
                width: 3
                height: {
                    if (y == 0) {
                        if (nextValue > display)
                            return itemRect.y
                        if (nextValue < display)
                            return Math.min(
                                        (Math.min(
                                             display,
                                             model.maxVal) - nextValue) * view.valueHeight + 1.5,
                                        view.height)
                        return 3
                    }

                    let result = Math.abs((display - nextValue))
                        * view.valueHeight + (nextValue < display ? 1.5 : 0)
                    if (result + y > view.height) {
                        result -= (result + y) - view.height
                    }
                    return Math.min(result, view.height)
                }
            }
        }

        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Shift) {
                                viewMouse.altWheel = true
                            }
                        }
        Keys.onReleased: event => {
                             if (event.key === Qt.Key_Shift) {
                                 viewMouse.altWheel = false
                             }
                         }

        MouseArea {
            id: viewMouse
            anchors.fill: parent
            property bool altWheel: false
            property real xBegin: -1
            property real yBegin
            hoverEnabled: true

            function updateValues(mouseY) {
                let step = Math.round(mouseY - yBegin)
                let k = valuesDiff / 192

                yBegin = mouseY
                let newMin = Math.round(model.minVal + Math.round(step) * k)
                let newMax = Math.round(model.maxVal + Math.round(step) * k)

                if (step < 0) {
                    if (newMin < -65536) {
                        let diff = model.maxVal - model.minVal
                        model.minVal = -65536
                        model.maxVal = -65536 + diff
                    } else {
                        model.minVal = newMin
                        model.maxVal = newMax
                    }
                } else {
                    if (newMax > 65536) {
                        let diff = newMax - 65536
                        model.maxVal = 65536
                        model.minVal = newMin - diff
                    } else {
                        model.maxVal = newMax
                        model.minVal = newMin
                    }
                }
            }

            function centerTo(value) {
                let currCenter = model.maxVal - verticalStep * 2
                let diff = value - currCenter
                if (diff > 0) {
                    let newMax = model.maxVal + diff
                    let newMin = model.minVal + diff
                    if (newMax > 65536) {
                        let maxDiff = newMax - 65536
                        model.maxVal = 65536
                        model.minVal = model.minVal + diff - maxDiff
                    } else if (newMin < -65536) {
                        let minDiff = model.maxVal - model.minVal
                        model.minVal = -65536
                        model.maxVal = model.maxVal - minDiff
                    } else {
                        model.maxVal = newMax
                        model.minVal = model.minVal + diff
                    }
                } else {
                    let newMin = model.minVal + diff
                    if (newMin < -65536) {
                        let minDiff = -model.minVal + model.maxVal
                        model.minVal = -65536
                        model.maxVal = -65536 + minDiff
                    } else {
                        model.maxVal = model.maxVal + diff
                        model.minVal = newMin
                    }
                }
            }

            function updateStep(mouseX) {
                let step = Math.round(mouseX - xBegin)
                let k = 0.5
                let positionStep = -Math.round(step * k)

                xBegin = mouseX
                positionStep *= model.step

                model.position = Math.max(0, model.position + positionStep)
            }

            function updateScale(delta) {
                if (delta > 0) {
                    if (model.maxVal > 1) {
                        model.maxVal /= 2
                        model.minVal /= 2
                        centerTo(model.maxVal - mouseY / viewMouse.height * verticalStep * 4)
                    } else {
                        model.maxVal = 1
                        model.minVal = -1
                    }
                } else {
                    let newMax = model.maxVal * 2
                    let newMin = model.minVal * 2
                    if (newMax <= 65536 && newMin >= -65536) {
                        model.maxVal = newMax
                        model.minVal = newMin
                        centerTo(model.maxVal - mouseY / viewMouse.height * verticalStep * 4)
                    } else {
                        model.maxVal = 65536
                        model.minVal = -65536
                    }
                }
            }

            onPressed: {
                nameInput.active = false
                view.focus = true
                xBegin = mouse.x
                yBegin = mouse.y
            }
            onReleased: {
                xBegin = -1
            }

            onEntered: {
                if (!nameInput.active)
                    view.focus = true
            }
            onExited: view.focus = false
            onPositionChanged: {
                if (xBegin < 0)
                    return
                let xDiff = mouse.x - xBegin
                let yDiff = mouse.y - yBegin

                if (Math.abs(xDiff) > Math.abs(yDiff)) {
                    updateStep(mouse.x)
                } else {
                    updateValues(mouse.y)
                }
            }
            onWheel: {
                if (altWheel) {
                    if (wheel.angleDelta.y > 0) {
                        if (model.step > 1) {
                            model.step--
                        }
                    } else {
                        if (model.step < 1000) {
                            model.step++
                        }
                    }
                } else {
                    updateScale(wheel.angleDelta.y)
                }
            }
        }

        Rectangle {
            id: valueHandle
            y: 0
            x: (Math.floor(viewMouse.mouseX / width) - 1) * width
            color: "#A0AAAAAA"
            width: view.width / 128
            height: view.height
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

    TextInput {
        text: model.positionToString(model.position)
        y: view.height + topPadding
        height: parent.labelHeight
        width: height * 2
        font.preferShaping: false
        font.pixelSize: 25
        //     fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: "white"
        onAccepted: {
            model.position = text
            text = Qt.binding(() => model.position)
        }
    }

    Text {
        text: model.positionToString(model.position + 128 * model.step)
        y: view.height + topPadding
        x: view.width - width
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
        text: model.maxVal
        y: topPadding - 25
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
        text: model.maxVal - verticalStep
        y: parent.height / 6 + topPadding - 25
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
        text: model.maxVal - verticalStep * 2
        y: parent.height / 6 * 2 + topPadding - 25
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
        text: model.maxVal - verticalStep * 3
        y: parent.height / 6 * 3 + topPadding - 25
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
        text: model.minVal
        y: parent.height / 6 * 4 + topPadding - 25
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
