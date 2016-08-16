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

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0

//app
ApplicationWindow {
    id:app
    visible: true
    width: 360;height: 520

    function exerciseViewStateChanged() {
        if (exerciseView.state == "waitingForAnswer"){
            exerciseView.resetAnswers()
            soundBackend.setQuestionLabel("play again")
        }
    }
    property string titleText: "Minuet Mobile"
    property string aboutlinkColor: "#3F51B5"

    //contains title and button
    header: ToolBar{
        Material.primary: "#181818"
        Material.foreground: "white"
        id:toolBar

        RowLayout{
            spacing: 20
            anchors.fill: parent
            height: parent.height/5

            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "drawer.png"
                }
                onClicked: navigationMenu.open()
            }
 
            FontLoader {source: "qrc:/Roboto-Regular.ttf"}
            FontLoader {source: "qrc:/Roboto-Bold.ttf"}

            Label {
                id: titleLabel
                text: titleText
                font { family: "Roboto"; weight: Font.Bold; pixelSize: 16 }
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                contentItem: Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "menu.png"
                }
                onClicked: optionsMenu.open()

                Menu {
                    id: optionsMenu
                    x: parent.width - width
                    transformOrigin: Menu.TopRight

                    MenuItem {
                        text: "About"
                        onTriggered: aboutDialog.open()
                    }
                }
            }
        }
    }

    Drawer{
        id: navigationMenu
        width: Math.min(app.width, app.height) * 0.75; height: app.height

        //loads the exercises from exercise controller
        Item {
            id: minuetMenu

            property variant exerciseArray: []
            property Item selectedMenuItem : null
            signal backPressed
            readonly property alias currentExercise: stackView.currentExercise
            signal itemChanged(var model)
            width: parent.width; height: parent.height

            onCurrentExerciseChanged: {
                exerciseController.currentExercise = currentExercise
                exerciseView.setCurrentExercise(currentExercise)
                exerciseView.resetAnswers()
            }
            onBackPressed: {
                soundBackend.stop()
                exerciseView.clearExerciseGrid()
                exerciseView.clearYourAnswerGrid()
            }

            Image {
                id: drawerImage
                source: "qrc:/minuet-drawer.png"
                width: parent.width
                height: 0.53125*width
                fillMode: Image.PreserveAspectFit
            }

            //back button
            Item {
                id: breadcrumb
                width: parent.width; height: (stackView.depth > 1) ? 50:0
                anchors { top: drawerImage.bottom }
                Image {
                    height: parent.height/2
                    id: backButton
                    fillMode: Image.Stretch
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    source: "back@2x.png"
                    anchors{
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        margins: 10
                    }
                }

                Label{
                    id: currentExerciseParent
                    text:""
                    font{family: "Roboto"; weight: Font.Bold; pixelSize: 16}
                    elide: Label.ElideRight
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    anchors{
                        left: backButton.right
                        verticalCenter: parent.verticalCenter
                        margins: 10
                    }
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        stackView.currentExerciseMenuItem = null
                        exerciseController.currentExercise ={}
                        stackView.pop()
                        minuetMenu.exerciseArray.pop()
                        currentExerciseParent.text = minuetMenu.exerciseArray.toString()
                        minuetMenu.backPressed()
                        titleText = "Minuet Mobile"
                    }
                }
            }

            StackView {
                id: stackView
                z: -10

                property var currentExercise
                property Item currentExerciseMenuItem

                width: parent.width;
                anchors{top: breadcrumb.bottom; bottom:parent.bottom}
                clip: true
                focus: true

                Component {
                    id: categoryDelegate

                    Rectangle {
                        id: delegateRect
                        width: stackView.width; height:exerciseName.height

                        Image {
                            id: parentIcon

                            source: (modelData._icon != undefined)? modelData._icon:""
                            visible: modelData._icon != undefined
                            fillMode: Image.Pad
                            horizontalAlignment: Image.AlignHCenter
                            verticalAlignment: Image.AlignVCenter
                            anchors{
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                                margins: 10
                            }
                            sourceSize.height: 30
                            sourceSize.width : 30
                        }

                        Text {
                            id: exerciseName
                            text: "technical term, do you have a musician friend?", modelData.name
                            leftPadding: 12
                            topPadding: 17
                            bottomPadding: 17
                            font{family: "Roboto"; pixelSize: 14}
                            anchors.left: parentIcon.right
                        }

                        MouseArea{
                            anchors.fill: parent
                            onPressed: {
                                delegateRect.color =  "#E0E0E0"
                            }
                            onCanceled: {
                                delegateRect.color = "white"
                            }
                            onReleased: {
                                var children = modelData.children
                                if (!children) {
                                    if (uiController.isFirstTimeUser() == 1) toolBar.ToolTip.show("Press on Your Answer section to find the answers",10000)
                                    if (minuetMenu.selectedMenuItem != undefined && minuetMenu.selectedMenuItem!=delegateRect) minuetMenu.selectedMenuItem.color = "white"
                                    minuetMenu.selectedMenuItem = delegateRect
                                    soundBackend.setQuestionLabel("new question")
                                    stackView.currentExercise = modelData
                                    stackView.currentExerciseMenuItem = delegateRect
                                    titleText = modelData.name
                                    navigationMenu.close()
                                }
                                else {
                                    delegateRect.color = "white"
                                    stackView.push(categoryMenu.createObject(stackView, {model: children}))
                                    currentExerciseParent.text = modelData.name
                                    minuetMenu.exerciseArray.push(modelData.name)
                                }
                            }
                        }
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
                            delegate: categoryDelegate
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                    }
                }

                Component.onCompleted: { stackView.push(categoryMenu.createObject(stackView, {model: exerciseController.exercises})) }
            }

        }
    }

    Item {
        id: contentContainer
        width: parent.width
        height: parent.height

        ExerciseView {
            id: exerciseView
            width: contentContainer.width ; height: contentContainer.height
        }
    }

    Popup{
        id: aboutDialog
        modal: true
        focus: true
        x: (app.width - width) / 2
        y: app.height / 6
        width: Math.min(app.width, app.height) * 0.9
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Image {
                id: icon
                source: "minuet.svgz"
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally("https://www.kde.org/applications/education/minuet/")
                }
            }

            Label {
                width: aboutDialog.availableWidth
                wrapMode: Label.Wrap
                linkColor: aboutlinkColor
                text: "Minuet is a <a href='http://kde.org'>KDE</a> " + "application for music education."
                onLinkActivated: Qt.openUrlExternally(link)
                font.pixelSize: 13
            }

            Label {
                width: aboutDialog.availableWidth
                wrapMode: Label.WordWrap
                linkColor: aboutlinkColor
                text: "In case you want to learn more about Minuet, you can find more information "+
                      "<a href='https://www.kde.org/applications/education/minuet/'>in the official site</a>.<br>"+
                      "<br>Please use <a href='http://bugs.kde.org'>our bug tracker</a> to report bugs."
                onLinkActivated: Qt.openUrlExternally(link)
                font.pixelSize: 13
            }

            Label {
                width: aboutDialog.availableWidth
                wrapMode: Label.WordWrap
                linkColor: aboutlinkColor
                text: "Developers:<br>Sandro Andrade &lt;<a href='mailto:sandroandrade@kde.org'>sandroandrade@kde.org</a>&gt;"+
                      "<br>Ayush Shah &lt;<a href='mailto:1595ayush@gmail.com'>1595ayush@gmail.com</a>&gt;"
                onLinkActivated: Qt.openUrlExternally(link)
                font.pixelSize: 13
            }

            Label {
                width: aboutDialog.availableWidth
                wrapMode: Label.WordWrap
                linkColor: aboutlinkColor
                text: "Icon Designer:<br>Alessandro Longo &lt;<a href='mailto:alessandro.longo@kdemail.net'>alessandro.longo@kdemail.net</a>&gt;"
                onLinkActivated: Qt.openUrlExternally(link)
                font.pixelSize: 13
            }
        }
    }

    Connections {
        target: exerciseView
        onStateChanged: app.exerciseViewStateChanged()
    }
}
