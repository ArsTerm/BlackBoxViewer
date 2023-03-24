import BBViewer 1.0
import QtQuick 2.0
import QtQuick.Controls 2.15

Item {
    property alias bbSource: model.source
    property alias canMes: model.canMes
    property alias value: model.value
    property alias step: model.step
    property alias position: model.position
    property int currentValue: 0
    property real topPadding: height * 0.1
    property real botPadding: height * 0.1
    property real leftPadding: width * 0.1

    function bound(min, max, val) {
        return Math.min(max, Math.max(min, val))
    }

    property real valuesDiff: model.maxVal - model.minVal
    property real verticalStep: valuesDiff / 4

    NameInput {
        id: nameInput
        z: 10
        x: leftPadding
        width: leftPadding
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
        font.pixelSize: height
        color: "white"
        onAccepted: {
            model.step = text
        }
    }

    Text {
        text: "Значение: " + model.valueAt(currentValue)
        x: parent.width / 2.5
        width: parent.width / 4
        height: topPadding
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.preferShaping: false
        fontSizeMode: Text.Fit
        font.pixelSize: 25
        color: "white"
    }

    ListView {
        id: view
        y: topPadding
        x: leftPadding
        width: parent.width - leftPadding
        height: parent.height - botPadding - y
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
                x: parent.width - width
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

            onMouseXChanged: {
                currentValue = Math.floor(viewMouse.mouseX / (view.width / 128))
            }

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
                let currVal = model.maxVal - mouseY / viewMouse.height * verticalStep * 4
                if (delta > 0) {
                    if (model.maxVal > 1) {
                        model.maxVal /= 2
                        model.minVal /= 2
                        centerTo(currVal)
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
                        centerTo(currVal)
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
            x: (currentValue - 1) * width
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

    Text {
        text: model.positionToString(model.position)
        x: leftPadding
        y: view.height + topPadding
        height: botPadding
        width: height * 2
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: "white"
//        onAccepted: {
//            model.position = text
//            text = Qt.binding(() => model.position)
//        }
    }

    Text {
        text: model.positionToString(model.position + 128 * model.step)
        y: view.height + topPadding
        x: view.width + leftPadding - width
        height: botPadding
        width: height * 2
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.maxVal
        y: topPadding - height / 2
        width: leftPadding - leftPadding * 0.05
        height: botPadding
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.maxVal - verticalStep
        y: topPadding - height / 2 + view.height / 4
        width: leftPadding - leftPadding * 0.05
        height: botPadding
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.maxVal - verticalStep * 2
        y: view.height / 2 + topPadding - height / 2
        width: leftPadding - leftPadding * 0.05
        height: botPadding
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.maxVal - verticalStep * 3
        y: view.height * 3 / 4 + topPadding - height / 2
        width: leftPadding - leftPadding * 0.05
        height: botPadding
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        text: model.minVal
        y: view.height + topPadding - height / 2
        width: leftPadding - leftPadding * 0.05
        height: botPadding
        font.preferShaping: false
        font.pixelSize: 25
        fontSizeMode: Text.Fit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Rectangle {
        z: -1
        x: leftPadding
        y: topPadding
        color: "black"
        width: parent.width - x
        height: view.height + 1
        border.color: "white"
        border.width: 1
    }
}
