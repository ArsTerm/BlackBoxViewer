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
        height: parent.height /2
        orientation: ListView.Horizontal
        model: BBModel {
            source: "file:C:\\Projects\\BlackBoxViewer\\build\\Desktop_Qt_5_15_2_MSVC2019_64bit\\tests\\BBtest.bin"
        }
        delegate: Rectangle {
            color: "green"
            y: view.height - display
            width: 5
            height: 5
        }
    }
}
