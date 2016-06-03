/****************************************************************************
**
** Copyright (C) 2016 by Sandro S. Andrade <sandroandrade@kde.org>
**
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public License as
** published by the Free Software Foundation; either version 2 of
** the License or (at your option) version 3 or any later version
** accepted by the membership of KDE e.V. (or its successor approved
** by the membership of KDE e.V.), which shall act as a proxy
** defined in Section 14 of version 3 of the license.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles.Flat 1.0 as Flat
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0

//window
ApplicationWindow {
    id:window
    visible: true
    width: 640
    height: 480

    onCurrentMenuChanged: {
        xBehavior.enabled = true;
        anchorCurrentMenu();
    }

    //called to slide the navigation menu
    function anchorCurrentMenu() {
        switch (currentMenu) {
        case -1:
            anchorItem.x = -menuWidth;
            break;
        case 0:
            anchorItem.x = 0;
            break;
        case 1:
            anchorItem.x = -menuWidth * 2;
            break;
        }
    }
    property Item selectedMenuItem : null
    readonly property int textMargins: Math.round(16 * Flat.FlatStyle.scaleFactor)
    readonly property int menuMargins: Math.round(13 * Flat.FlatStyle.scaleFactor)
    readonly property alias anchorItem: navigationMenu
    property int currentMenu: -1
    readonly property int menuWidth: Math.min(window.width, window.height) * 0.75

    Item {
        id: navigationMenuContainer
        anchors.fill: parent

        Rectangle{

            id: navigationMenu
            x: navigationMenuContainer.x - width
            z: minuetMenu.z + 1
            width: menuWidth
            height: parent.height

            //for resizing
            Binding {
                target: navigationMenu
                property: "x"
                value: navigationMenuContainer.x - navigationMenu.width
                when: !xBehavior.enabled && !xNumberAnimation.running && currentMenu == -1
            }

            Behavior on x {
                id: xBehavior
                enabled: false
                NumberAnimation {
                    id: xNumberAnimation
                    easing.type: Easing.OutExpo
                    duration: 500
                    onRunningChanged: xBehavior.enabled = false
                }
            }

            //loads the exercises from exercise controller
            Item {
            id: minuetMenu
            width: parent.width
            height: parent.height
            property string message

            signal breadcrumbPressed

            function itemClicked(delegateRect, index) {
                var model = delegateRect.ListView.view.model[index].options
                if (model !== undefined) {
                    exerciseController.setExerciseOptions(model)
                }
            }
            //back button
            Button {
                id: breadcrumb

                width: (stackView.depth > 1) ? 100:0; height: parent.height
                //not working
                //iconName: "go-previous"
                onClicked: {
                    minuetMenu.breadcrumbPressed()
                    stackView.pop()
                    if (stackView.depth == 1)
                        Qt.message = "exercise"
                }
            }
            StackView {
                id: stackView

                width: parent.width - breadcrumb.width; height: parent.height
                anchors.left: breadcrumb.right
                clip: true
                focus: true

                Component {
                    id: categoryDelegate

                    MouseArea {
                        id: delegateRect
                        width: parent.width; height:64 * Flat.FlatStyle.scaleFactor

                        Rectangle {
                            width: parent.width
                            height: Flat.FlatStyle.onePixel
                            anchors.bottom: parent.bottom
                            color: Flat.FlatStyle.lightFrameColor
                        }

                        Label {
                            id:abc
                            text: "technical term, do you have a musician friend?", modelData.name
                            font.pixelSize: Math.round(15 * Flat.FlatStyle.scaleFactor)
                            font.family: Flat.FlatStyle.fontFamily
                            renderType: Text.QtRendering
                            //color: delegateRect.ListView.isCurrentItem ? Flat.FlatStyle.styleColor : Flat.FlatStyle.defaultTextColor
                            color: Flat.FlatStyle.defaultTextColor
                            anchors.left: parent.left
                            anchors.leftMargin: menuMargins
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                             var children = delegateRect.ListView.view.model[index].children
                            if (!children) {
                                minuetMenu.itemClicked(delegateRect, index)
                            }
                            else {
                                stackView.push(categoryMenu.createObject(stackView, {model: children}))
                                var root = delegateRect.ListView.view.model[index].root
                                if (root != undefined) {
                                    exerciseController.setMinRootNote(root.split('.')[0])
                                    exerciseController.setMaxRootNote(root.split('.')[2])
                                }
                                var playMode = delegateRect.ListView.view.model[index].playMode
                                if (playMode != undefined) {
                                    if (playMode == "scale") exerciseController.setPlayMode(0) // ScalePlayMode
                                    if (playMode == "chord") exerciseController.setPlayMode(1) // ChordPlayMode
                                    exerciseController.setAnswerLength(1)
                                    if (playMode == "rhythm") {
                                        exerciseController.setPlayMode(2) // RhythmPlayMode
                                        exerciseController.setAnswerLength(4)
                                    }
                                }
                            }
                        }
                        //style: MinuetButtonStyle {}
                    }
                }
                Component {
                    id: categoryMenu

                    Rectangle {
                        property alias model: listView.model

                        width: stackView.width; height: parent.height

                        ListView {
                            id: listView
                            anchors.fill: parent
                            spacing: -2
                            delegate: categoryDelegate

                        }
                    }
                }

                Component.onCompleted: { stackView.push(categoryMenu.createObject(stackView, {model: exerciseCategories})) }
            }
        }

        }

        //Contains the title + a navigation button
        Item {
            id: contentContainer
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width
            MouseArea{
                width: parent.width;
                height: parent.height
                onClicked: {
                    if(currentMenu == 0)
                        currentMenu = -1
                }
            }

            //contains the title and one button
            ToolBar {
                id: toolBar
                width: parent.width
                height: 54 * Flat.FlatStyle.scaleFactor
                z: navigationMenuContainer.z + 1
                style: Flat.ToolBarStyle {
                    padding.left: 0
                    padding.right: 0
                }

                RowLayout {
                    anchors.fill: parent
                    //controls button in main view
                    MouseArea {
                        id: controlsButton
                        Layout.preferredWidth: toolBar.height + textMargins
                        Layout.preferredHeight: toolBar.height
                        onClicked: currentMenu = currentMenu == 0 ? -1 : 0

                        Column {
                            id: controlsIcon
                            anchors.left: parent.left
                            anchors.leftMargin: textMargins
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Math.round(2 * Flat.FlatStyle.scaleFactor)

                            Repeater {
                                model: 3

                                Rectangle {
                                    width: Math.round(4 * Flat.FlatStyle.scaleFactor)
                                    height: width
                                    radius: width / 2
                                    color: Flat.FlatStyle.defaultTextColor
                                }
                            }
                        }
                    }
                    //title
                    Text {
                        text: "Minuet Mobile"
                        font.family: Flat.FlatStyle.fontFamily
                        font.pixelSize: Math.round(16 * Flat.FlatStyle.scaleFactor)
                        horizontalAlignment: Text.AlignHCenter
                        color: "#666666"
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
