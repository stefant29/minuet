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
import QtQuick.Layouts 1.0
//import "pianoview"

Item {
    id: exerciseView

    property int startPos: 0
    property int marginAll: mainLayout.anchors.margins
    property int endPos: 0
    property int currentAnswer: 0
    property var correctAnswers
    property var correctColors: ["#ffffff", "#ffffff", "#ffffff", "#ffffff"]
    property var rhythmColors: ["#ffffff", "#ffffff", "#ffffff", "#ffffff"]
    property variant exerciseAnswers: []
    property var chosenExercises
    property int exercisAnswerLength:0
    property var chosenColors: [4]
    property Item answerRectangle
    property var colors: ["#8dd3c7", "#ffffb3", "#bebada", "#fb8072", "#80b1d3", "#fdb462", "#b3de69", "#fccde5", "#d9d9d9", "#bc80bd", "#ccebc5", "#ffed6f", "#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6", "#6a3d9a", "#ffff99", "#b15928"]
    property int availableAnswersHeight: mainLayout.height - messageText.height - rowLayoutQuestion.height - pianoView.height - answerCategory.height - 2*marginAll
    signal answerHoverEnter(var chan, var pitch, var vel, var color)
    signal answerHoverExit(var chan, var pitch, var vel)
    property var answers: [
        "current-rhythm.png",
        "unknown-rhythm.png",
        "unknown-rhythm.png",
        "unknown-rhythm.png"
    ]
    onChosenExercisesChanged: {
        fillCorrectAnswerGrid()
    }

    function answerClicked(answerOptionClicked,answerLength){
        if(exerciseController.currentExercise["playMode"] != "rhythm"){
            exerciseAnswers.push(answerOptionClicked)
            yourAnswerGrid.children[currentAnswer].model = answerOptionClicked
            currentAnswer++
            if(answerLength == exerciseAnswers.length){
                for(var i = 0; i < answerLength; i++)
                    checkAnswers(exerciseAnswers,answerLength)
            }
        }
        else{
            var tempAnswers = answers
            tempAnswers[currentAnswer] = answerOptionClicked
            var tempColors = rhythmColors
            tempColors[currentAnswer] = color
            rhythmColors = tempColors
            currentAnswer++
            if (currentAnswer == answerLength) {
                checkAnswers(answers,answerLength)
                correctColors = exerciseView.chosenColors
            }
            else {
                tempAnswers[currentAnswer] = "current-rhythm.png"
            }
            answers = tempAnswers
        }
    }
    function showCorrectAnswer() {
        if(exerciseController.currentExercise["playMode"] != "rhythm"){
            for (var i = 0; i < 1; ++i){
                yourAnswerGrid.children[i].border.color = "white"
                yourAnswerGrid.children[i].model = chosenExercises[i]
            }
        }
        else{
            var tempAnswers = answers
            for (var i = 0; i < 4; ++i){
                tempAnswers[i] = chosenExercises[i] + ".png"
                yourAnswerGrid.children[i].border.color = "white"
            }
            answers = tempAnswers
            rhythmColors = chosenColors
            currentAnswer = 0
        }
    }
    function resetAnswers() {
        currentAnswer = 0
        answers = ["current-rhythm.png", "unknown-rhythm.png", "unknown-rhythm.png", "unknown-rhythm.png"]
        correctAnswers = undefined
        rhythmColors = ["#ffffff", "#ffffff", "#ffffff", "#ffffff"]
        correctColors = ["#ffffff", "#ffffff", "#ffffff", "#ffffff"]
        for (var i = 0; i < yourAnswerGrid.children.length; ++i)
            yourAnswerGrid.children[i].border.color = "white"
        while(exerciseAnswers.length)
            exerciseAnswers.pop()
        piano.noteUnmark(0, exerciseController.chosenRootNote(), 0, "white")
    }
    function fillCorrectAnswerGrid() {
        correctAnswers = exerciseView.chosenExercises
    }
    function clearExerciseGrid() {
        exerciseView.visible = false
        for (var i = 0; i < answerGrid.children.length; ++i)
            answerGrid.children[i].destroy()
    }
    function highlightRightAnswer() {
        for (var i = 0; i < answerGrid.children.length; ++i) {
            answerGrid.children[i].enabled = false
            answerGrid.children[i].opacity = 0.25
        }
        exerciseView.state = "nextQuestion"
    }
    function clearYourAnswerGrid(){
        for (var i = 0; i < yourAnswerGrid.children.length; ++i)
            yourAnswerGrid.children[i].destroy()
    }
    function createYourAnswerChildren(playMode){
        var answerLength = 1
        if(playMode == "rhythm"){
            answerLength = 4
            for (var i = 0; i < answerLength; ++i)
                yourAnswerOption.createObject(yourAnswerGrid, {model: answers[i], index: i})
        }
        else{
            for (var i = 0; i < answerLength; ++i)
                yourAnswerOption.createObject(yourAnswerGrid, {model: "", index: i})
        }
    }
    function clearYourAnswerGridOptions(){
        var playMode = exerciseController.currentExercise["playMode"]
        if(playMode == "rhythm"){
            for(var i = 0 ; i < yourAnswerGrid.children.length; ++i){
                yourAnswerGrid.children[i].model = answers[i]
                yourAnswerGrid.children[i].index = i
            }
        }
        else{
            for(var i = 0 ; i < yourAnswerGrid.children.length; ++i){
                yourAnswerGrid.children[i].model = ""
                yourAnswerGrid.children[i].index = i
            }
        }
    }
    function setCurrentExercise(currentExercise) {
        var playMode = exerciseController.currentExercise["playMode"]
        clearExerciseGrid()
        clearYourAnswerGrid()
        createYourAnswerChildren(playMode)
        var currentExerciseOptions = currentExercise["options"];
        var length = currentExerciseOptions.length

        answerGrid.columns = Math.min(length,Math.floor(availableAnswers.width/((exerciseController.currentExercise["playMode"] != "rhythm") ? 140:139)))
        answerGrid.rows = Math.ceil(length/answerGrid.columns)
        for (var i = 0; i < length; ++i)
            answerOption.createObject(answerGrid, {model: currentExerciseOptions[i], index: i, color: colors[i%24]})
        exerciseView.visible = true
        exerciseView.state = "initial"
        messageText.text = exerciseController.currentExercise["userMessage"]
    }
    function checkAnswers(answers,answerLength) {
        highlightRightAnswer()
        if (exerciseController.currentExercise["playMode"] != "rhythm")
            highlightRightNotes()
        var answersOk = true
        for(var i = 0; i < answerLength; ++i) {
            if (answers[i].toString().split("/").pop().split(".")[0] != chosenExercises[i]){
                answersOk = false
                yourAnswerGrid.children[i].border.color = "red"
            }
            else{
                yourAnswerGrid.children[i].border.color = "green"
            }
        }
        if (answersOk)
            messageText.text = "Congratulations!<br/>You answered correctly!"
        else{
            messageText.text = "Oops, not this time!<br/>Try again!"
            if (uiController.isFirstTimeUser() == 1) toolBar.ToolTip.show("Click on the red rectangle(s) to know the \nright answer(s)",10000)
        }
        exerciseView.state = "nextQuestion"
    }
    function highlightRightNotes() {
        for (var i = 0; i < answerGrid.children.length; ++i) {
            if (answerGrid.children[i].model.name == chosenExercises[0])
                answerRectangle = answerGrid.children[i]
        }
        answerRectangle.model.sequence.split(' ').forEach(function(note) {
            piano.noteMark(0, exerciseController.chosenRootNote() + parseInt(note), 0, answerRectangle.color)
        })
    }

    visible: false

    Rectangle {
        id: mainLayout
        anchors.margins: 10
        color: "transparent"
        clip: true
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height
        width:parent.width

        Text {
            id: messageText
            wrapMode: Label.WordWrap
            horizontalAlignment: Qt.AlignHCenter
            font{family: "Roboto"; pixelSize: 14}
            anchors{
                top : parent.top
                margins: marginAll
                left: parent.left
                right: parent.right
            }
        }

        Row {
            id: rowLayoutQuestion
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: messageText.bottom
                margins: marginAll
            }
            spacing: 20

            Button {
                id: newQuestionButton
                width: giveUpButton.implicitWidth + 55; height: giveUpButton.implicitHeight
                text: soundBackend.questionLabel

                onClicked: {
                    clearYourAnswerGridOptions()
                    if(newQuestionButton.text == "new question"){
                        resetAnswers()
                        exerciseView.state = "waitingForAnswer"
                        var playMode = exerciseController.currentExercise["playMode"]
                        exerciseController.answerLength = (playMode == "rhythm") ? 4:1
                        exercisAnswerLength = (playMode == "rhythm") ? 4:1

                        exerciseController.randomlySelectExerciseOptions()
                        var selectedExerciseOptions = exerciseController.selectedExerciseOptions
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
                        if(playMode!= "rhythm"){
                            piano.noteMark(0, exerciseController.chosenRootNote(), 0, "white")
                        }
                    }
                    startPos = pianoView.contentX
                    endPos = 7*piano.keyWidth*(Math.floor((exerciseController.chosenRootNote()-23)/12))
                    if(endPos > 0)
                        endPos += 2*piano.keyWidth
                    if(startPos!=endPos)
                        anim.start()

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
                        highlightRightNotes()
                        showCorrectAnswer()
                    }
                    else {
                        showCorrectAnswer()
                        exerciseView.state = "nextQuestion"
                    }
                    soundBackend.setQuestionLabel("new question")
                }
            }
        }

        GroupBox {
            title: qsTr("Available Answers")
            id:availableAnswers
            width:app.width-marginAll*2 ; height: availableAnswersHeight
            anchors{
                horizontalCenter: parent.horizontalCenter
                bottom: answerCategory.top
                margins: marginAll
                top: rowLayoutQuestion.bottom
            }

            Flickable{
                id:fickable
                anchors.fill: parent
                contentHeight: answerGrid.height
                clip: true

                Grid {
                    id: answerGrid

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.centerIn: parent
                    spacing: 10
                    padding: 10
                    //columns: 2; rows: 2

                    Component {
                        id: answerOption

                        Rectangle {
                            id: answerRectangle

                            property var model
                            property int index

                            width: (exerciseController.currentExercise["playMode"] != "rhythm") ? 120:119
                            height: (exerciseController.currentExercise["playMode"] != "rhythm") ? 40:59

                            Text {
                                id: option

                                property string originalText: model.name

                                width: parent.width - 4
                                visible: exerciseController.currentExercise["playMode"] != "rhythm"
                                text: model.name
                                anchors.centerIn: parent
                                horizontalAlignment: Qt.AlignHCenter
                                color: "black"
                                wrapMode: Text.WordWrap
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
                                        answerClicked(option.originalText,1)
                                        highlightRightAnswer()
                                    }
                                    else {
                                        answerClicked(rhythmImage.source, 4)
                                    }
                                }
                            }
                        }
                    }
                }
                ScrollBar.vertical: ScrollBar{ }
            }
        }

        RowLayout{
            id: answerCategory
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: (exerciseController.currentExercise["playMode"] != "rhythm") ? pianoView.top:backspaceButton.top
                margins: marginAll
            }

            GroupBox {
                title: qsTr("Your Answer(s)")

                Row{
                    id: yourAnswerGrid
                    anchors{
                        horizontalCenter: parent.horizontalCenter
                        centerIn: parent
                    }
                    spacing: 10;

                    Component {
                        id: yourAnswerOption

                        Rectangle {
                            id: yourAnswerRectangle

                            property var model
                            property int index

                            width: (exerciseController.currentExercise["playMode"] != "rhythm") ? 120:(app.width-2*marginAll)/4-10
                            height: (exerciseController.currentExercise["playMode"] != "rhythm") ? 40:59

                            Text {
                                id: yourAnswerOptionText

                                property string yourAnswerOriginalText: model

                                width: parent.width - 4
                                visible: exerciseController.currentExercise["playMode"] != "rhythm"
                                text: model
                                anchors.centerIn: parent
                                horizontalAlignment: Qt.AlignHCenter
                                color: "black"
                                wrapMode: Text.WordWrap
                            }

                            Image {
                                id: rhythmImage

                                width: 70
                                height: 35
                                anchors.centerIn: parent
                                visible: exerciseController.currentExercise["playMode"] == "rhythm"
                                source: answers[index]
                            }

                            MouseArea{
                                anchors.fill: parent
                                onClicked:{
                                    if(exerciseController.currentExercise["playMode"] != "rhythm" && yourAnswerGrid.children[0].model != "")
                                        showCorrectAnswer()
                                    else{
                                        if(currentAnswer == 4)
                                            showCorrectAnswer()
                                    }
                                }

                            }
                        }
                    }
                }

                Layout.preferredWidth: app.width-2*marginAll
            }
        }

        Flickable{
            id:pianoView

            clip: true
            boundsBehavior: Flickable.OvershootBounds
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                margins: marginAll
            }
            contentWidth: piano.width
            height:100
            width: parent.width - 2*marginAll

            PianoView{
                id: piano
                visible: exerciseController.currentExercise["playMode"] != "rhythm"
                anchors.top: parent.top
                anchors.bottom: parent.bottom
            }
        }

        Button {
            id: backspaceButton

            text: "backspace"
            width: app.width - 2*marginAll
            height: 50
            visible: exerciseController.currentExercise["playMode"] == "rhythm"
            anchors { horizontalCenter: parent.horizontalCenter
                bottom: mainLayout.bottom
                margins: marginAll
            }
            enabled: currentAnswer > 0 && currentAnswer < 4
            onClicked: {
                if (currentAnswer > 0) {
                    var tempAnswers = answers
                    var tempColors = rhythmColors
                    tempAnswers[currentAnswer] = "unknown-rhythm.png"
                    currentAnswer--
                    tempAnswers[currentAnswer] = "current-rhythm.png"
                    tempColors[currentAnswer] = "#ffffff"
                    answers = tempAnswers
                    rhythmColors = tempColors
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
                    messageText.text = exerciseController.currentExercise["userMessage"]
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
                    messageText.text = exerciseController.currentExercise["userMessage"]
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
    ParallelAnimation{
        id:anim
        loops: 1
        NumberAnimation { target: pianoView; property: "contentX"; from: startPos; to: endPos}
    }

    Connections {
        target: exerciseController
        onSelectedExerciseOptionsChanged: piano.clearAllMarks()
        onCurrentExerciseChanged: piano.clearAllMarks()
    }
}
