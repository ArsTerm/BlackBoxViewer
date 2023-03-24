import QtQuick 2.15

Column {
    property url canMes
    property url bbSource
    property string defaultValue

    Component {
        id: viewComp
        BBView {
            width: parent.width
            height: parent.height / parent.children.length
            canMes: parent.canMes
            bbSource: parent.bbSource
            onPositionChanged: {
                for (let i = 0; i < parent.children.length; i++) {
                    let child = parent.children[i]
                    if (child !== this) {
                        child.position = this.position
                    }
                }
            }
            onStepChanged: {
                for (let i = 0; i < parent.children.length; i++) {
                    let child = parent.children[i]
                    if (child !== this) {
                        child.step = this.step
                    }
                }
            }
            onCurrentValueChanged: {
                for (let i = 0; i < parent.children.length; i++) {
                    let child = parent.children[i]
                    if (child !== this) {
                        child.currentValue = this.currentValue
                    }
                }
            }
        }
    }
    function addView() {
        viewComp.createObject(this, {value: defaultValue})
    }
    Component.onCompleted: {
        addView()
        addView()
    }
}
