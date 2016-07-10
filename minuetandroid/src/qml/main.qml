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

import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.3
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0
import QtQuick.Controls.Material 2.0

//window
ApplicationWindow {
    id:window
    visible: true
    width: 640;height: 480

    function userMessageChanged(message) {
     //   pianoView.visible = (message != "the rhythm" && message != "exercise")
        rhythmAnswerView.visible = (message == "the rhythm")
    }

    function exerciseViewStateChanged() {
        if (exerciseView.state == "waitingForAnswer"){
            rhythmAnswerView.resetAnswers()
            soundBackend.setQuestionLabel("play again")
        }
    }

    //contains title and button
    header: ToolBar{
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

            Label {
                id: titleLabel
                text: "Minuet Mobile"
                font.pixelSize: 25
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
                        text: "Settings"
                    }

                    MenuItem {
                        text: "About"
                    }
                }
            }
        }
    }

    //TODO: Have an icon next to the name for each type of main exercise(chords,intervals,rhythm) in navigation drawer
    Drawer{
       id: navigationMenu
       width: Math.min(window.width, window.height) * 0.75; height: window.height

       //loads the exercises from exercise controller
       Item {
            //property string message
            property variant exerciseArray: []
            property Item selectedMenuItem : null
            signal backPressed
            readonly property alias currentExercise: stackView.currentExercise
            //signal breadcrumbPressed
            signal itemChanged(var model)
            signal userMessageChanged(string message)
            id: minuetMenu
            width: parent.width; height: parent.height

            onCurrentExerciseChanged: {
                exerciseView.setCurrentExercise(currentExercise)
                rhythmAnswerView.resetAnswers()
                exerciseController.currentExercise = currentExercise
            }
            onBackPressed: {
                soundBackend.stop()
                exerciseView.clearExerciseGrid()
                //pianoView.clearAllMarks()
            }
            function itemClicked(delegateRect, index) {
                var model = delegateRect.ListView.view.model[index].options
                if (model != undefined) {
                    exerciseController.setExerciseOptions(model)
                    minuetMenu.itemChanged(model)
                }
            }

            //back button
            Item {
                id: breadcrumb
                width: parent.width; height: (stackView.depth > 1) ? 50:0

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

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            //soundBackend.stop()
                            //minuetMenu.breadcrumbPressed()
                            stackView.currentExerciseMenuItem = null
                            exerciseController.currentExercise ={}
                            //minuetMenu.selectedMenuItem = null
                            stackView.pop()
                            minuetMenu.exerciseArray.pop()
                            currentExerciseParent.text = minuetMenu.exerciseArray.toString()
                            //minuetMenu.userMessageChanged("exercise")
                            //if (stackView.depth == 1)
                            //    minuetMenu.message = "exercise"
                            minuetMenu.backPressed()
                        }
                    }
                }

                Label{
                    id: currentExerciseParent
                    text:""
                    font.pixelSize: 25
                    elide: Label.ElideRight
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    anchors{
                        left: backButton.right
                        verticalCenter: parent.verticalCenter
                        margins: 10
                    }
                }
            }

            StackView {
                id: stackView

                property var currentExercise
                property Item currentExerciseMenuItem

                width: parent.width;
                anchors.top: breadcrumb.bottom
                anchors.bottom:parent.bottom
                clip: true
                focus: true

                Component {
                    id: categoryDelegate

                    Rectangle {
                        id: delegateRect
                        width: stackView.width; height:exerciseName.height

                        Label {
                            id: exerciseName
                            text: "technical term, do you have a musician friend?", modelData.name
                            padding: 25
                        }

                        //checkable: (!delegateRect.ListView.view.model[index].children) ? true:false
                        MouseArea{

                            anchors.fill: parent

                            onPressed: {
                               delegateRect.color =  " light gray"
                            }

                            onCanceled: {
                                delegateRect.color = "white"
                            }

                            onReleased: {
                                //var userMessage = delegateRect.ListView.view.model[index].userMessage
                                //if (userMessage != undefined)
                                //    minuetMenu.message = userMessage
                                //checkable: (!delegateRect.ListView.view.model[index].children) ? true:false
                                var children = delegateRect.ListView.view.model[index].children
                                if (!children) {
                                    if (minuetMenu.selectedMenuItem != undefined) minuetMenu.selectedMenuItem.color = "white"
                                    minuetMenu.selectedMenuItem = delegateRect
                                    //if (minuetMenu.selectedMenuItem != undefined) minuetMenu.selectedMenuItem.highlight = true
                                    soundBackend.setQuestionLabel("new question")
                                    //minuetMenu.userMessageChanged(minuetMenu.message)
                                    //minuetMenu.itemClicked(delegateRect, index)
                                    //minuetMenu.selectedMenuItem = delegateRect
                                    stackView.currentExercise = delegateRect.ListView.view.model[index]
                                    stackView.currentExerciseMenuItem = delegateRect
                                    navigationMenu.close()
                                }
                                else {
                                    delegateRect.color = "white"
                                    stackView.push(categoryMenu.createObject(stackView, {model: children}))
                                    //stackView.push(categoryMenu.createObject(stackView, {model: children}))
                                    currentExerciseParent.text = modelData.name
                                    minuetMenu.exerciseArray.push(modelData.name)
                                    /*var root = delegateRect.ListView.view.model[index].root
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
                                    }*/
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

                //Component.onCompleted: { stackView.push(categoryMenu.createObject(stackView, {model: exerciseCategories})) }
                Component.onCompleted: { stackView.push(categoryMenu.createObject(stackView, {model: exerciseController.exercises})) }
            }
        }
    }

    Item {
        id: contentContainer
        anchors.fill: parent

        RhythmAnswerView {
            id: rhythmAnswerView
            anchors { bottom: parent.bottom; bottomMargin: 20; horizontalCenter: parent.horizontalCenter }
            visible: false
            exerciseView: exerciseView
        }

        ExerciseView {
            id: exerciseView
            width: contentContainer.width ; height: contentContainer.height
            anchors { horizontalCenter: contentContainer.horizontalCenter }
        }
    }

    /*Connections {
        target: minuetMenu
        onItemChanged: exerciseView.itemChanged(model)
        onBreadcrumbPressed: exerciseView.clearExerciseGrid()
        onUserMessageChanged: exerciseView.changeUserMessage(message)
    }*/
    /*Connections {
        target: minuetMenu
        onItemChanged: rhythmAnswerView.resetAnswers(model)
        onBreadcrumbPressed: rhythmAnswerView.resetAnswers()
        onUserMessageChanged: window.userMessageChanged(message)
    }*/
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
