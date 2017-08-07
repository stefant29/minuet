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

Flickable {
    id: flickable

    width: guitar.width
    height: 156.4
    contentWidth: guitar.width
    boundsBehavior: Flickable.OvershootBounds
    clip: true
    
    property int rootFret: 0
    property int rootName: 0
    property var sequence
    property var rightSequence
    property int barFret: rootFret
    property var stringsUsed

    function setSequence(sequence, stringsUsed, root) {
        flickable.sequence = []
        flickable.stringsUsed = []
        
        //print("SETSEQUENCE: " + stringsUsed)
        var i = 0
        if (root <= 4) {
            sequence[1].split(' ').forEach(function(note) {
                flickable.sequence[i++] = note
            })
            i = 0
            stringsUsed[0].split(' ').forEach(function(string) {
                flickable.stringsUsed[i++] = string
            })
        } else {
            sequence[2].split(' ').forEach(function(note) {
                flickable.sequence[i++] = note
            })
            i = 0
            stringsUsed[1].split(' ').forEach(function(string) {
                flickable.stringsUsed[i++] = string
            })
        }
    }
    // change the opacity of unused strings to 0.3
    function drawUnusedStrings() {
        var i, j
        for (i = 0; i < guitar.frets.length; i++) {
            for (j = 0; j < 6; j++)
                if (j < flickable.stringsUsed[0] || j > flickable.stringsUsed[1])
                    guitar.frets[i].ids[j].opacity = 0.3
        }
    }
    // change the opacity back to 1 for unused strings
    function clearUnusedStrings() {
        var i, j
        for (i = 0; i < guitar.frets.length; i++) {
            for (j = 0; j < 6; j++)
                if (j < flickable.stringsUsed[0] || j > flickable.stringsUsed[1])
                    guitar.frets[i].ids[j].opacity = 1
        }
    }
    function setBar() {
        var i = 0
        var startBar = -1;
        var endBar = -1;
        flickable.barFret = flickable.rootFret
        // save the furthest to the left fret
        for (i = 0; i < flickable.sequence.length; i++) {
            var crtFret = parseInt(flickable.rootFret) + parseInt(flickable.sequence[i])
            if (crtFret < flickable.barFret)
                flickable.barFret = crtFret
        }
        // save the start string and the end string of the bar
        for (i = 0; i < flickable.sequence.length; i++) {
            if (parseInt(flickable.rootFret) + parseInt(flickable.sequence[i]) == flickable.barFret) {
                    if (startBar == -1)
                        startBar = i;
                    endBar = i;
            }
        }
        // set the start and end of the bar into the saved fret
        guitar.frets[flickable.barFret].startBar = startBar
        guitar.frets[flickable.barFret].endBar = endBar
    }
    function markNotes(model, color) {
        setSequence(model.sequence, model.stringsUsed, flickable.rootName)
        drawUnusedStrings()
        setBar()
        var i
        for (i = 0; i < flickable.sequence.length; i++) {
            var index = parseInt(flickable.rootFret) + parseInt(flickable.sequence[i])
            var aux = guitar.frets[index].press
            aux[i] = true
                    /*print("index: " + index)
                    print("rootFret: " + flickable.rootFret)
                    print("seq: " + flickable.sequence)
                    print(aux) */
            guitar.frets[index].press = aux
            guitar.frets[index].mark_color = color
        }
    }

    function unmarkNotes(sequence) {
        // follow the same technique as for the markNotes
        var i
        for (i = 0; i < flickable.sequence.length-1; i++) {
            var index = parseInt(flickable.rootFret) + parseInt(flickable.sequence[i])
            var aux = guitar.frets[index].press
            aux[i] = false
            guitar.frets[index].press = aux
            guitar.frets[index].mark_color = color
        }
        clearUnusedStrings()
        clearBar()
    }

    function setRootFret(chan, pitch, vel, color, sequence) {
        flickable.rootName = getNameNote(pitch)
        flickable.rightSequence = []

        var i = 0
        if (flickable.rootName <= 4) {
            sequence[1].split(' ').forEach(function(note) {
                flickable.rightSequence[i++] = note
            })
        } else {
            sequence[2].split(' ').forEach(function(note) {
                flickable.rightSequence[i++] = note
            })
        }
//                     print("   with rightSequence: " + flickable.rightSequence)
//                     print("len: " + flickable.sequence.length)
        var string = flickable.rightSequence.length-1
        var lastStringNote = getNameNote2(string)
        flickable.rootFret = ((flickable.rootName+12)-lastStringNote)%12
//                 print("    MARK NOTE: " + pitch + "   ultima nota din cele alese este: " + string)
//                 print("    flickable.rootName: " + flickable.rootName)
//                 print("    lastStringNote: " + lastStringNote)
        var index
        index = parseInt(flickable.rootFret) + parseInt(flickable.rightSequence[string])
//                 print("index: " + index)
//                 print("rootFret: " + flickable.rootFret)
//                 print("seq: " + flickable.sequence)
//                 print("string: " + string)
        var aux = guitar.frets[index].press
        aux[string] = true
//                 print(aux)
        guitar.frets[index].press = aux
        guitar.frets[index].mark_color = color
//                 print("")
//                 print("")

    }

    function clearUserAnswers() {
        clearAllMarks()
        sheetMusicView.clearAllMarks()
        for (var i = 0; i < yourAnswersParent.children.length; ++i)
            yourAnswersParent.children[i].destroy()
        yourAnswersParent.children = ""
        internal.currentAnswer = 0
        internal.userAnswers = []
        if (flickable.stringsUsed)
            clearUnusedStrings()
    }

    function checkAnswers() {
        var rightAnswers = core.exerciseController.selectedExerciseOptions
        internal.answersAreRight = true
        for (var i = 0; i < currentExercise.numberOfSelectedOptions; ++i) {
            //print("internal.userAnswers[i].name :" + internal.userAnswers[i].name)
            //print("rightAnswers[i].name: " + rightAnswers[i].name)
            if (internal.userAnswers[i].name != rightAnswers[i].name) {
                yourAnswersParent.children[i].border.color = "red"
                internal.answersAreRight = false
            }
            else {
                yourAnswersParent.children[i].border.color = "green"
                if (internal.isTest)
                    internal.correctAnswers++
            }
        }
        messageText.text = (internal.giveUp) ? i18n("Here is the answer") : (internal.answersAreRight) ? i18n("Congratulations, you answered correctly!"):i18n("Oops, not this time! Try again!")
        if (internal.currentExercise == internal.maximumExercises) {
            messageText.text = i18n("You answered correctly %1%", internal.correctAnswers * 100 / internal.maximumExercises)
            resetTest()
        }

        if (currentExercise.numberOfSelectedOptions == 1)
            highlightRightAnswer()
        else
            exerciseView.state = "waitingForNewQuestion"
        internal.giveUp = false
    }

    function highlightRightAnswer() {
        //print("==highlightRightAnswer == in guitar view ==")
        var chosenExercises = core.exerciseController.selectedExerciseOptions
        for (var i = 0; i < answerGrid.children.length; ++i) {
            if (answerGrid.children[i].model.name != chosenExercises[0].name) {
                answerGrid.children[i].opacity = 0.25
            }
            else {
                internal.rightAnswerRectangle = answerGrid.children[i]
                answerGrid.children[i].opacity = 1
            }
        }
        var array = [core.exerciseController.chosenRootNote()]
        markNotes(internal.rightAnswerRectangle.model, internal.rightAnswerRectangle.color)
        internal.rightAnswerRectangle.model.sequence[0].split(' ').forEach(function(note) {
            //instrumentView.noteMark(0, core.exerciseController.chosenRootNote() + parseInt(note), 0, internal.rightAnswerRectangle.color)
            array.push(core.exerciseController.chosenRootNote() + parseInt(note))
        })
        sheetMusicView.model = array
        animation.start()
    }

    function resetTest() {
    }

    function nextTestExercise() {
    }

    function generateNewQuestion () {
        clearUserAnswers()
        if (internal.isTest)
            messageText.text = i18n("Question %1 out of %2", internal.currentExercise + 1, internal.maximumExercises)
        else
            messageText.text = ""
        core.exerciseController.randomlySelectExerciseOptions()
        chosenExercises = core.exerciseController.selectedExerciseOptions
        
        
        core.soundController.prepareFromExerciseOptions(chosenExercises)        
        //print("FANE " + JSON.stringify(chosenExercises[0].sequence))
        //print("FANE " + chosenExercises[0].sequence)
        //print("not used: " + chosenExercises[0].stringsUsed)

        if (currentExercise["playMode"] != "rhythm") {
            //noteMark(0, core.exerciseController.chosenRootNote(), 0, "white")
            //TODO: change this in pianoview as well
            setRootFret(0, core.exerciseController.chosenRootNote(), 0, "white", chosenExercises[0].sequence)
            scrollToNote(core.exerciseController.chosenRootNote())
            sheetMusicView.model = [core.exerciseController.chosenRootNote()]
            sheetMusicView.clef.type = (core.exerciseController.chosenRootNote() >= 60) ? 0:1
        }
        exerciseView.state = "waitingForAnswer"
        if (internal.isTest)
            internal.currentExercise++

   /*
                 3     0/5       2    4    1   

            C C# D D#   E   F F# G G# A A# B
            0 1  2 3    4   5 6  7 8  9 10 11
        */
    }

    function getNameNote2(index) {
        if (index == 3)                     // D  ->  2
            return 2
        else if (index == 0 || index == 5)  // E  ->  4
            return 4
        else if (index == 2)                // G  ->  7
            return 7
        else if (index == 4)                // A  ->  9
            return 9
        else if (index == 1)                // B  ->  11
            return 11
    }

    function getNameNote(pitch) {
        return pitch%12   //(pitch-21)%12
    }

    function applyCurrentQuestion() {
        core.soundController.prepareFromExerciseOptions(chosenExercises)
        if (currentExercise["playMode"] != "rhythm") {
            //instrumentView.noteMark(0, core.exerciseController.chosenRootNote(), 0, "white")
            setRootFret(0, core.exerciseController.chosenRootNote(), 0, "white", chosenExercises[0].sequence)
            instrumentView.scrollToNote(core.exerciseController.chosenRootNote())
            sheetMusicView.model = [core.exerciseController.chosenRootNote()]
            sheetMusicView.clef.type = (core.exerciseController.chosenRootNote() >= 60) ? 0:1
        }
    }

    function noteOn(chan, pitch, vel) {
    }
    function noteOff(chan, pitch, vel) {
    }

    function noteMark(chan, pitch, vel, color) {
    }
    function noteUnmark(chan, pitch, vel, color) {
        //print("noteUnmark")
    }
    function clearAllMarks() {
        var i
        for (i = 0; i < guitar.frets.length; i++)
            guitar.frets[i].press = [false, false, false, false, false, false]
        clearBar()
    }
    function clearBar() {
        guitar.frets[flickable.barFret].startBar = -1
        guitar.frets[flickable.barFret].endBar = -1
    }
    function scrollToNote(pitch) {
        flickable.contentX = guitar.frets[flickable.rootFret].x - flickable.width/2
    }
    function highlightKey(pitch, color) {
    }
    function itemForPitch(pitch) {
    }

    Rectangle {
        id: guitar

        width: board.board_width * 410 + 8.5; height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 5
        color: "#141414"
        
        property var frets: [fretBoard1, fretBoard2, fretBoard3, fretBoard4, fretBoard5, fretBoard6, fretBoard7,
         fretBoard8, fretBoard9, fretBoard10, fretBoard11, fretBoard12, fretBoard13, fretBoard14, fretBoard15,
         fretBoard16, fretBoard17,  fretBoard18, fretBoard19, fretBoard20, fretBoard21, fretBoard22
        ]

        Item {
            id: board
            width: parent.width
            height: fretBoard1.height
            anchors.centerIn: parent

            property double board_width: 2.5

            FretBoard { id: nut;         anchors.left: parent.left     ;  width: board.board_width * 8.5; is_nut: true}
            FretBoard { id: fretBoard1;  anchors.left: nut.right       ;  width: board.board_width * 29.466}
            FretBoard { id: fretBoard2;  anchors.left: fretBoard1.right;  width: board.board_width * 27.812}
            FretBoard { id: fretBoard3;  anchors.left: fretBoard2.right;  width: board.board_width * 26.251; show_fret_marker: true}
            FretBoard { id: fretBoard4;  anchors.left: fretBoard3.right;  width: board.board_width * 24.788}
            FretBoard { id: fretBoard5;  anchors.left: fretBoard4.right;  width: board.board_width * 23.387; show_fret_marker: true}
            FretBoard { id: fretBoard6;  anchors.left: fretBoard5.right;  width: board.board_width * 22.075}
            FretBoard { id: fretBoard7;  anchors.left: fretBoard6.right;  width: board.board_width * 20.836; show_fret_marker: true}
            FretBoard { id: fretBoard8;  anchors.left: fretBoard7.right;  width: board.board_width * 19.666}
            FretBoard { id: fretBoard9;  anchors.left: fretBoard8.right;  width: board.board_width * 18.562; show_fret_marker: true}
            FretBoard { id: fretBoard10; anchors.left: fretBoard9.right;  width: board.board_width * 17.521}
            FretBoard { id: fretBoard11; anchors.left: fretBoard10.right; width: board.board_width * 16.537}
            FretBoard { id: fretBoard12; anchors.left: fretBoard11.right; width: board.board_width * 15.609; show_fret_marker: true; show_two_markers: true}
            FretBoard { id: fretBoard13; anchors.left: fretBoard12.right; width: board.board_width * 14.733}
            FretBoard { id: fretBoard14; anchors.left: fretBoard13.right; width: board.board_width * 13.906}
            FretBoard { id: fretBoard15; anchors.left: fretBoard14.right; width: board.board_width * 13.126; show_fret_marker: true}
            FretBoard { id: fretBoard16; anchors.left: fretBoard15.right; width: board.board_width * 12.289}
            FretBoard { id: fretBoard17; anchors.left: fretBoard16.right; width: board.board_width * 11.693; show_fret_marker: true}
            FretBoard { id: fretBoard18; anchors.left: fretBoard17.right; width: board.board_width * 11.037}
            FretBoard { id: fretBoard19; anchors.left: fretBoard18.right; width: board.board_width * 10.418}
            FretBoard { id: fretBoard20; anchors.left: fretBoard19.right; width: board.board_width * 9.833}
            FretBoard { id: fretBoard21; anchors.left: fretBoard20.right; width: board.board_width * 9.282}
            FretBoard { id: fretBoard22; anchors.left: fretBoard21.right; width: board.board_width * 9.760}
            FretBoard { id: chords;      anchors.left: fretBoard22.right; width: board.board_width * 30; is_end: true}
        }
    }

    ScrollIndicator.horizontal: ScrollIndicator { active: true }
}
