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


    function clearUserAnswers() {
        clearAllMarks()
    }

    function checkAnswers() {
    }

    function highlightRightAnswer() {
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
        if (currentExercise["playMode"] != "rhythm") {
            noteMark(0, core.exerciseController.chosenRootNote(), 0, "white")
            scrollToNote(core.exerciseController.chosenRootNote())
            sheetMusicView.model = [core.exerciseController.chosenRootNote()]
            sheetMusicView.clef.type = (core.exerciseController.chosenRootNote() >= 60) ? 0:1
        }
        exerciseView.state = "waitingForAnswer"
        if (internal.isTest)
            internal.currentExercise++
        
   /*     
                print(internal.rightAnswerRectangle)
        print(internal.rightAnswerRectangle.model.name)
        print(internal.rightAnswerRectangle.model.sequence)
        print(internal.rightAnswerRectangle.model.usedAE)
        print(internal.rightAnswerRectangle.model.barAE)
        print(internal.rightAnswerRectangle.model.seqAE)
        print(internal.rightAnswerRectangle.model.usedFB)
        print(internal.rightAnswerRectangle.model.barFB)
        print(internal.rightAnswerRectangle.model.seqFB)
        
        
        if (getNameNote(pitch) <= 4)
            // A->E
        else if (getNameNote(pitch) <= 11)
            // F->B
            
            
            
                 3     0/5       2    4    1    
            
            C C# D D#   E   F F# G G# A A# B
            0 1  2 3    4   5 6  7 8  9 10 11
            // A == 9
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
    }

    function noteOn(chan, pitch, vel) {
    }
    function noteOff(chan, pitch, vel) {
    }
    function noteMark(chan, pitch, vel, color) {
        var aux = [false, false, false, false, false, false]
        var noteName = getNameNote(pitch)
        
        
        if (noteName <= 4) {
            var len = internal.rightAnswerRectangle.model.usedCE.length
                        print("MARK NOTE: " + pitch + "   ultima nota din cele alese este: " + internal.rightAnswerRectangle.model.usedCE[len-1])
            
            var lastStringNote = getNameNote2(internal.rightAnswerRectangle.model.usedCE[len-1])
                        print("noteName: " + noteName)
                        print("lastStringNote: " + lastStringNote)
            var dif = ((noteName+12)-lastStringNote)%12
                        print("dif: " + (dif-1))
            aux[internal.rightAnswerRectangle.model.usedCE[len-1]] = true
            guitar.frets[dif-1].press = aux
        } else {
            var len = internal.rightAnswerRectangle.model.usedFB.length
                        print("MARK NOTE: " + pitch + "   ultima nota din cele alese este: " + internal.rightAnswerRectangle.model.usedFB[len-1])
            
            var lastStringNote = getNameNote2(internal.rightAnswerRectangle.model.usedFB[len-1])
                        print("noteName: " + noteName)
                        print("lastStringNote: " + lastStringNote)
            var dif = ((noteName+12)-lastStringNote)%12
                        print("dif: " + (dif-1))
            aux[internal.rightAnswerRectangle.model.usedFB[len-1]] = true
            guitar.frets[dif-1].press = aux
            
        }
    }
    function noteUnmark(chan, pitch, vel, color) {
     //   fretBoard4.press = [false, false, false, false, false, false];
    }
    function clearAllMarks() {
    }
    function scrollToNote(pitch) {
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
