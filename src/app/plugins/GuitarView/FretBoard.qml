import QtQuick 2.7

Rectangle {
    width: 70; height: (string1.height + string1.anchors.topMargin) * 6 + string1.anchors.topMargin
    color: "#4b3020"
    property int string_size: 3
    property string string_color: "#FFFFFF"

    Rectangle {
        id: string1
        width: parent.width; height: string_size
        anchors { left: parent.left; top: parent.top; topMargin: 3 * height}
        color: string_color
    }

    Rectangle {
        id: string2
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string1.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string3
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string2.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string4
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string3.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string5
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string4.bottom; topMargin: 3 * height}
        color: string_color
    }
    Rectangle {
        id: string6
        width: parent.width; height: string_size
        anchors { left: parent.left; top: string5.bottom; topMargin: 3 * height}
        color: string_color
    }

    Rectangle {
        id: leftBar
        width: string_size; height: parent.height
        anchors {left: parent.left; leftMargin: -string_size/3; top: parent.top; bottom: parent.bottom}
        color: string_color
    }

    Rectangle {
        id: rightBar
        width: string_size; height: parent.height
        anchors {right: parent.right; top: parent.top; bottom: parent.bottom}
        color: string_color
    }
}
