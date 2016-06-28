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
import QtQuick.Controls 2.0
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

    function userMessageChanged(message) {
     //   pianoView.visible = (message != "the rhythm" && message != "exercise")
        rhythmAnswerView.visible = (message == "the rhythm")
    }

    function exerciseViewStateChanged() {
        if (exerciseView.state == "waitingForAnswer"){
            rhythmAnswerView.resetAnswers()
        }
    }

    readonly property int textMargins: Math.round(16 * Flat.FlatStyle.scaleFactor)
    readonly property int menuMargins: Math.round(13 * Flat.FlatStyle.scaleFactor)
    readonly property alias anchorItem: navigationMenu
    //property int currentMenu: -1
    readonly property int menuWidth: Math.min(window.width, window.height) * 0.75

    Drawer{
       id: navigationMenu
       width: Math.min(window.width, window.height) * 0.75
       height: window.height

       //loads the exercises from exercise controller
       Item {
            property string message
            //property Item selectedMenuItem : null

            signal breadcrumbPressed
            signal itemChanged(var model)
            signal userMessageChanged(string message)
            id: minuetMenu
            width: parent.width
            height: parent.height

            function itemClicked(delegateRect, index) {
                var model = delegateRect.ListView.view.model[index].options
                if (model != undefined) {
                    exerciseController.setExerciseOptions(model)
                    minuetMenu.itemChanged(model)
                }
            }

            //back button
            Rectangle {
                id: breadcrumb
                border.width: 1
                border.color: "gray"
                height: (stackView.depth > 1) ? 100:0; width: parent.width
                //not working
                //iconName: "go-previous"
                MouseArea
                {
                    width: parent.width; height: parent.height
                    onClicked: {
                        sequencer.stop()
                        minuetMenu.breadcrumbPressed()
                        //minuetMenu.selectedMenuItem = null
                        stackView.pop()
                        minuetMenu.userMessageChanged("exercise")
                        if (stackView.depth == 1)
                            minuetMenu.message = "exercise"
                    }
                }
            }

            StackView {
                id: stackView
                width: parent.width; height: parent.height
                anchors.top: breadcrumb.bottom
                clip: true
                focus: true

                Component {
                    id: categoryDelegate

                    Rectangle {
                        id: delegateRect
                        width: stackView.width
                        height:exerciseName.height - exerciseName.padding
                        Label {
                            id: exerciseName
                            text: "technical term, do you have a musician friend?", modelData.name
                            padding: 50
                        }

                        //checkable: (!delegateRect.ListView.view.model[index].children) ? true:false
                        MouseArea{
                            width: parent.width
                            height: parent.height
                            onClicked: {
                                var userMessage = delegateRect.ListView.view.model[index].userMessage
                                if (userMessage != undefined)
                                    minuetMenu.message = userMessage
                                var children = delegateRect.ListView.view.model[index].children
                                if (!children) {
                                    //if (minuetMenu.selectedMenuItem != undefined) minuetMenu.selectedMenuItem.checked = false
                                    minuetMenu.userMessageChanged(minuetMenu.message)
                                    minuetMenu.itemClicked(delegateRect, index)
                                    //minuetMenu.selectedMenuItem = delegateRect
                                    navigationMenu.close()
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
                        }
//                        style: MinuetButtonStyle {}
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
                            ScrollIndicator.vertical: ScrollIndicator { }
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

        //contains the title and one button
        ToolBar {
            id: toolBar
            width: parent.width
            height: 36 * Flat.FlatStyle.scaleFactor

            RowLayout {
                anchors.fill: parent
                //controls button in main view
                MouseArea {
                    id: controlsButton
                    Layout.preferredWidth: toolBar.height + textMargins
                    Layout.preferredHeight: toolBar.height
                    //onClicked: currentMenu = currentMenu == 0 ? -1 : 0
                    onClicked: navigationMenu.open()
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

        RhythmAnswerView {
            id: rhythmAnswerView
            anchors { bottom: parent.bottom; bottomMargin: 20; horizontalCenter: parent.horizontalCenter }
            visible: false
            exerciseView: exerciseView
        }

        ExerciseView {
            id: exerciseView
            width: contentContainer.width ; height: contentContainer.height
            anchors { top: toolBar.bottom; horizontalCenter: contentContainer.horizontalCenter }
        }
    }

    Connections {
        target: minuetMenu
        onItemChanged: exerciseView.itemChanged(model)
        onBreadcrumbPressed: exerciseView.clearExerciseGrid()
        onUserMessageChanged: exerciseView.changeUserMessage(message)
    }
    Connections {
        target: minuetMenu
        onItemChanged: rhythmAnswerView.resetAnswers(model)
        onBreadcrumbPressed: rhythmAnswerView.resetAnswers()
        onUserMessageChanged: window.userMessageChanged(message)
    }
    Connections {
        target: exerciseView
        onAnswerClicked: rhythmAnswerView.answerClicked(answerImageSource, color)
        onStateChanged: window.exerciseViewStateChanged()
        onShowCorrectAnswer: rhythmAnswerView.showCorrectAnswer(chosenExercises, chosenColors)
        onChosenExercisesChanged: rhythmAnswerView.fillCorrectAnswerGrid()
    }
    Connections {
        target: rhythmAnswerView
        onAnswerCompleted: exerciseView.checkAnswers(answers)
    }
}
