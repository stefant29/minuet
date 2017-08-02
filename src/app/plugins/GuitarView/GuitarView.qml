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
    
    property int crtString: 0
    property int rootFret: 0
    property int rootName: 0
    property var sequence
    property var rightSequence

    function markNotes(sequence, color) {
        // call noteMark() for the current sequence
        //     ACTUALLY, NO
        // no matter the sequence, select the sequence 
        //    from Guitar definitions based on the root position: CE or FB
        
        flickable.sequence = [0,0,0,0,0,0]

        var i = 0
        if (flickable.rootName <= 4) {
            sequence[1].split(' ').forEach(function(note) {
                flickable.sequence[i++] = note
            })
        } else {
            sequence[2].split(' ').forEach(function(note) {
                flickable.sequence[i++] = note
            })
        }
        
         flickable.crtString = 0
        var i = 0
        for (i = 0; i < flickable.sequence.length; i++) {
            flickable.noteMark(0, core.exerciseController.chosenRootNote() + parseInt(flickable.sequence[i]), 0, color)
           // flickable.crtString = i
        }
  /*      flickable.sequence.split(' ').forEach(function(note) {
            var sum = core.exerciseController.chosenRootNote() + parseInt(note)
            print("val: " + sum)
            flickable.crtString++
            flickable.noteMark(0, core.exerciseController.chosenRootNote() + parseInt(note), 0, color)
        })
    */    
        
        flickable.crtString = 0
        print(flickable.crtString)
    }

    function unmarkNotes(sequence) {
        // follow the same technique as for the markNotes
    print("unmarkNotes")
        clearAllMarks()
        flickable.crtString = flickable.rightSequence.length-1
        noteMark(0, core.exerciseController.chosenRootNote(), 0, "white")
    }

    function setRootFret(chan, pitch, vel, color) {
        var aux = [false, false, false, false, false, false]
        flickable.rootName = getNameNote(pitch)

        flickable.rightSequence = [0,0,0,0,0,0]

        var i = 0
        if (flickable.rootName <= 4) {
            internal.rightAnswerRectangle.model.sequence[1].split(' ').forEach(function(note) {
                flickable.rightSequence[i++] = note
            })
        }
        else {
            internal.rightAnswerRectangle.model.sequence[2].split(' ').forEach(function(note) {
                flickable.rightSequence[i++] = note
            })
        }

                    print("chord is: " + internal.rightAnswerRectangle.model.name + "   with seq: " + flickable.rightSequence)

                    //print("len: " + flickable.sequence.length)
        flickable.crtString = flickable.rightSequence.length-1
                    //print("MARK NOTE: " + pitch + "   ultima nota din cele alese este: " + crtString)
        var lastStringNote = getNameNote2(crtString)
                    //print("flickable.rootName: " + flickable.rootName)
                    //print("lastStringNote: " + lastStringNote)
        flickable.rootFret = ((flickable.rootName+12)-lastStringNote)%12
    }
    
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
        /*core.soundController.prepareFromExerciseOptions(chosenExercises)
        if (currentExercise["playMode"] != "rhythm") {
            instrumentView.noteMark(0, core.exerciseController.chosenRootNote(), 0, "white")
            instrumentView.scrollToNote(core.exerciseController.chosenRootNote())
            sheetMusicView.model = [core.exerciseController.chosenRootNote()]
            sheetMusicView.clef.type = (core.exerciseController.chosenRootNote() >= 60) ? 0:1
        }*/
    }

    function noteOn(chan, pitch, vel) {
    }
    function noteOff(chan, pitch, vel) {
    }

    function noteMark(chan, pitch, vel, color) {
        print("noteMark    pitch: " + pitch)
        var index
        if (!flickable.sequence) {  // || flickable.crtString == flickable.sequence.length-1) 
            setRootFret(chan, pitch, vel, color)
            index = parseInt(flickable.rootFret) + parseInt(flickable.rightSequence[flickable.crtString])
        } else 
            index = parseInt(flickable.rootFret) + parseInt(flickable.sequence[flickable.crtString])
        print("index: " + index)
        print("rootFret: " + flickable.rootFret)
        print("seq: " + flickable.sequence)
        print("crtString: " + flickable.crtString)
        var aux = guitar.frets[index].press
        aux[flickable.crtString] = true
        print(aux)
        guitar.frets[index].press = aux
        guitar.frets[index].mark_color = color
        
        if (!flickable.sequence) //flickable.crtString == flickable.sequence.length-1)
            flickable.crtString = 0
        else
            flickable.crtString++
        
        print("")
        print("")
/*
        var aux = [false, false, false, false, false, false]
        var noteName = getNameNote(pitch)


        crtString = chordsUsed.length-1
                    print("MARK NOTE: " + pitch + "   ultima nota din cele alese este: " + crtString)
        var lastStringNote = getNameNote2(crtString)
                    print("noteName: " + noteName)
                    print("lastStringNote: " + lastStringNote)
        var fretNo = ((noteName+12)-lastStringNote)%12
                    print("fretNo: " + (fretNo-1))
        aux[crtString] = true
        guitar.frets[fretNo-1].press = aux
        guitar.frets[fretNo-1].mark_color = color

        var i
        for (i = 0; i < crtString; i++) {
             var aux = guitar.frets[fretNo-1 + chordsUsed[i]].press
             aux[i] = true
             print(aux)
             guitar.frets[fretNo-1 + chordsUsed[i]].press = aux
        }
        */
    }
    function noteUnmark(chan, pitch, vel, color) {
        print("noteUnmark")
        clearAllMarks()
    }
    function clearAllMarks() {
        print("clearAllMarks")
        flickable.crtString = 0
        var clear = [false, false, false, false, false, false]
        var i
        for (i = 0; i < guitar.frets.length; i++)
            guitar.frets[i].press = [false, false, false, false, false, false]
        print("")
        print("")
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
