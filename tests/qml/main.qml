import QtQuick.Window 2.15
import QtQuick 2.15
import BlackBoxView 1.0

Window {
    width: 800
    height: 600
    color: "black"
    visible: true

    BBView {
        x: parent.width / 4
        width: parent.width / 2
        height: parent.height / 2
        bbSource: "file:C:\\Projects\\BBtest.bin"
        value: "I_Can"
    }

    BBView {
        x: parent.width / 4
        y: parent.height / 2 + 5
        height: parent.height / 2 - 5
        width: parent.width / 2
        bbSource: "file:C:\\Projects\\BBtest.bin"
        value: "I_Can"
    }
}
