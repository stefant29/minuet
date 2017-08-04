import QtQuick 2.7

Rectangle {
    id: fretBoard
    height: (string_E1.height + string_E1.anchors.topMargin) * 6 + string_E1.anchors.topMargin
    color: "#4b3020"
    property var mark_color: "black"
    property double string_size: 3
    property string string_color: "#FFF2E6"
    property bool show_fret_marker: false
    property bool show_two_markers: false
    property bool is_nut: false
    property bool is_end: false
    property var press: [false, false, false, false, false, false]
    property var ids: [string_E1, string_B, string_G, string_D, string_A, string_E2]
    property int startBar: -1
    property int endBar: -1
    
    Rectangle {
        id: fret_marker1
        height: 6.5 * string_size; width: height
        radius: width * 0.5
        visible: show_fret_marker
        opacity: 0.7
        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset:  - string_size / 2
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: show_two_markers ? -(parent.height - (string_E1.y - parent.y)) / 4 : 0
        }
        color: "#E2E2E2"
        border.width: string_size / 2
        border.color: "#535353"
    }

    Rectangle {
        id: fret_marker2
        height: fret_marker1.height; width: height
        radius: width * 0.5
        visible: show_two_markers
        opacity: fret_marker1.opacity
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: show_two_markers ? (parent.height - (string_E1.y - parent.y)) / 4 : 0
        }
        color: "#E2E2E2"
        border.width: string_size / 2
        border.color: "#535353"
    }

    Rectangle {
        id: string_E1
        width: parent.width; height: string_size
        anchors { left: parent.left; top: parent.top; topMargin: 3 * height}
        color: string_color
    }

    Rectangle {
        id: string_B
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string_E1.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string_G
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string_B.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string_D
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string_G.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string_A
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string_D.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string_E2
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string_A.bottom; topMargin: 3 * height}
        color: string_color
    }

    Rectangle {
        id: rightBar
        width: is_nut ? string_size * 4 : string_size; height: parent.height
        anchors {right: parent.right; top: parent.top; bottom: parent.bottom}
        visible: is_end ? false : true
        color: "#D9D9D9"
    }

    Repeater {
        id: press_marks
        model: fretBoard.press

        Rectangle {
            id: press1
            height: 5 * string_size; width: height
            radius: width * 0.5
            visible: is_end || is_nut ? false : modelData
            color: fretBoard.mark_color
            border.width: 1
            border.color: "black"
            anchors.centerIn: fretBoard.ids[index]
        }
    }
    
    Rectangle {
        id: bar
        width: 5 * string_size
        radius: width * 0.5
        visible: (endBar - startBar) > 0
        color: fretBoard.mark_color
        border.width: 1
        border.color: "black"
        anchors.top: fretBoard.ids[startBar] ? fretBoard.ids[startBar].top : parent.top
        anchors.bottom: fretBoard.ids[endBar] ? fretBoard.ids[endBar].bottom : parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: - width / 2
        anchors.bottomMargin: - width / 2
    }

}
