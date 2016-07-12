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
import QtQuick.Controls.Material 2.0

Item {
    id: exerciseView

    property var chosenExercises
    property var chosenColors: [4]
    property Item answerRectangle
    property var colors: ["#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#fccde5", "#d9d9d9", "#bc80bd", "#ccebc5", "#ffed6f", "#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#ffff99", "#b15928"]

    signal answerHoverEnter(var chan, var pitch, var vel, var color)
    signal answerHoverExit(var chan, var pitch, var vel)
    signal answerClicked(var answerImageSource, var color)
    signal showCorrectAnswer(var chosenExercises, var chosenColors)

    function clearExerciseGrid() {
        exerciseView.visible = false
        for (var i = 0; i < answerGrid.children.length; ++i)
            answerGrid.children[i].destroy()
    }
    function highlightRightAnswer() {
        for (var i = 0; i < answerGrid.children.length; ++i) {
            answerGrid.children[i].enabled = false
            if (answerGrid.children[i].model.name != chosenExercises[0])
                answerGrid.children[i].opacity = 0.25
            else
                answerRectangle = answerGrid.children[i]
        }
        answerRectangle.model.sequence.split(' ').forEach(function(note) {
            answerHoverEnter(0, exerciseController.chosenRootNote() + parseInt(note), 0, answerRectangle.color)
        })
        animation.start()
    }
    function setCurrentExercise(currentExercise) {
        clearExerciseGrid()
        var currentExerciseOptions = currentExercise["options"];
        var length = currentExerciseOptions.length
        answerGrid.columns = Math.min(6, length)
        answerGrid.rows = Math.ceil(length/6)
        for (var i = 0; i < length; ++i)
            answerOption.createObject(answerGrid, {model: currentExerciseOptions[i], index: i, color: colors[i%24]})
        exerciseView.visible = true
        exerciseView.state = "initial"
    }
    function checkAnswers(answers) {
        var answersOk = true
        for(var i = 0; i < 4; ++i) {
            if (answers[i].toString().split("/").pop().split(".")[0] != chosenExercises[i])
                answersOk = false
        }
        if (answersOk)
            messageText.text = "Congratulations!<br/>You answered correctly!"
        else
            messageText.text = "Oops, not this time!<br/>Try again!"
        exerciseView.state = "nextQuestion"
    }

    visible: false

    Column {
        spacing: 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        height: parent.height

        Text {
            id: messageText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 18
            textFormat: Text.RichText
        }

        Row {
            anchors { horizontalCenter: parent.horizontalCenter }
            spacing: 20

            Button {
                id: newQuestionButton
                width: giveUpButton.implicitWidth + 55; height: giveUpButton.implicitHeight
                text: soundBackend.questionLabel

                onClicked: {
                    if(newQuestionButton.text == "new question"){
                        exerciseView.state = "waitingForAnswer"
                        var playMode = exerciseController.currentExercise["playMode"]
                        exerciseController.answerLength = (playMode == "rhythm") ? 4:1
                        exerciseController.randomlySelectExerciseOptions()
                        var selectedExerciseOptions = exerciseController.selectedExerciseOptions
                        //temporary condition
                        if(playMode != "rhythm")
                            soundBackend.prepareFromExerciseOptions(selectedExerciseOptions, playMode)
                        var newChosenExercises = [];
                        for (var i = 0; i < selectedExerciseOptions.length; ++i)
                            newChosenExercises.push(selectedExerciseOptions[i].name);
                        chosenExercises = newChosenExercises
                        for (var i = 0; i < chosenExercises.length; ++i)
                            for (var j = 0; j < answerGrid.children.length; ++j)
                                if (answerGrid.children[j].children[0].originalText == chosenExercises[i]) {
                                    chosenColors[i] = answerGrid.children[j].color
                                    break
                                }
                    }
                    soundBackend.play()
                }
            }

            Button {
                id: giveUpButton
                width: giveUpButton.implicitWidth + 55; height: giveUpButton.implicitHeight
                text: "give up"
                onClicked: {
                    if (exerciseController.currentExercise["playMode"] != "rhythm") {
                        highlightRightAnswer()
                    }
                    else {
                        showCorrectAnswer(chosenExercises, chosenColors)
                        exerciseView.state = "nextQuestion"
                    }
                    soundBackend.setQuestionLabel("new question")
                }
            }
        }

        Rectangle {
            width: answerGrid.width + 20; height: answerGrid.height + 20
            color: "#475057"
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter

            Grid {
                id: answerGrid
                anchors.centerIn: parent
                spacing: 10; columns: 2; rows: 1

                Component {
                    id: answerOption

                    Rectangle {
                        id: answerRectangle

                        property var model
                        property int index

                        width: window.width*0.85/6; height: (exerciseController.currentExercise["playMode"] != "rhythm") ? window.height*0.5/4:window.height*0.3/5

                        Text {
                            id: option

                            property string originalText: model.name

                            width: parent.width - 4
                            visible: exerciseController.currentExercise["playMode"] != "rhythm"
                            text: model.name
                            anchors.centerIn: parent
                            horizontalAlignment: Qt.AlignHCenter
                            color: "black"
                            wrapMode: Text.Wrap
                        }

                        Image {
                            id: rhythmImage
                            anchors.centerIn: parent
                            visible: exerciseController.currentExercise["playMode"] == "rhythm"
                            source: (exerciseController.currentExercise["playMode"] == "rhythm") ? model.name + ".png":""
                            fillMode: Image.Pad
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (exerciseController.currentExercise["playMode"] != "rhythm") {
                                    onExited()
                                    if (option.originalText == chosenExercises[0])
                                        messageText.text = "Congratulations!<br/>You answered correctly!"
                                    else
                                        messageText.text = "Oops, not this time!<br/>Try again!"
                                    answerHoverExit(0, exerciseController.chosenRootNote() + parseInt(model.sequence), 0)
                                    highlightRightAnswer()
                                }
                                else {
                                    answerClicked(rhythmImage.source, colors[answerRectangle.index])
                                }
                            }
                            hoverEnabled: true
                            onEntered: {
                                answerRectangle.color = Qt.darker(answerRectangle.color, 1.1)
                                if (exerciseController.currentExercise["playMode"] != "rhythm") {
                                    model.sequence.split(' ').forEach(function(note) {
                                        answerHoverEnter(0, exerciseController.chosenRootNote() + parseInt(note), 0, colors[answerRectangle.index])
                                    })
                                }
                            }
                            onExited: {
                                answerRectangle.color = colors[answerRectangle.index]
                                if (exerciseController.currentExercise["playMode"] != "rhythm") {
                                    if (!animation.running)
                                        model.sequence.split(' ').forEach(function(note) {
                                            answerHoverExit(0, exerciseController.chosenRootNote() + parseInt(note), 0)
                                        })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    states: [
        State {
            name: "initial"
            StateChangeScript {
                script: {
                    newQuestionButton.enabled = true
                    messageText.text = exerciseController.currentExercise["userMessage"] + "Click 'play question' if you want to hear again!"
                    giveUpButton.enabled = false
                    answerGrid.enabled = false
                    answerGrid.opacity = 0.25
                }
            }
        },
        State {
            name: "waitingForAnswer"
            StateChangeScript {
                script: {
                    for (var i = 0; i < answerGrid.children.length; ++i) {
                        answerGrid.children[i].opacity = 1
                        answerGrid.children[i].enabled = true
                    }
                    giveUpButton.enabled = true
                    answerGrid.enabled = true
                    answerGrid.opacity = 1
                    messageText.text = exerciseController.currentExercise["userMessage"] + "Click 'play question' if you want to hear again!"
                }
            }
        },
        State {
            name: "nextQuestion"
            StateChangeScript {
                script: {
                    soundBackend.setQuestionLabel("new question")
                    newQuestionButton.enabled = true
                    giveUpButton.enabled = false
                    answerGrid.enabled = false
                }
            }
        }
    ]
    ParallelAnimation {
        id: animation
        loops: 2

        SequentialAnimation {
            PropertyAnimation { target: answerRectangle; property: "rotation"; to: -45; duration: 200 }
            PropertyAnimation { target: answerRectangle; property: "rotation"; to:  45; duration: 200 }
            PropertyAnimation { target: answerRectangle; property: "rotation"; to:   0; duration: 200 }
        }
        SequentialAnimation {
            PropertyAnimation { target: answerRectangle; property: "scale"; to: 1.2; duration: 300 }
            PropertyAnimation { target: answerRectangle; property: "scale"; to: 1.0; duration: 300 }
        }

        onStopped: exerciseView.state = "nextQuestion"
    }
}
