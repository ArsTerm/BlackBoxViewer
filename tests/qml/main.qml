import QtQuick.Window 2.15
import QtQuick 2.15
import BlackBoxView 1.0

Window {
    width: 800
    height: 600
    color: "black"
    visible: true


    BBGroup {
        width: parent.width
        height: parent.height
        bbSource: "file:C:\\Projects\\03180511"
        canMes: "file:C:\\Projects\\BlackBoxViewer\\external\\CanInitParser\\CanInit.h"
        defaultValue: "I_Can"
    }
}
