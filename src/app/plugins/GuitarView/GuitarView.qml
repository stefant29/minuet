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

    width: Math.min(parent.width, guitar.width)
    height: keyHeight + 30
    contentWidth: guitar.width
    boundsBehavior: Flickable.OvershootBounds
    clip: true

    property int keyWidth: Math.max(16, (parent.width - 80) / 52)
    property int keyHeight: 3.4 * keyWidth

    function noteOn(chan, pitch, vel) {
    }
    function noteOff(chan, pitch, vel) {
    }
    function noteMark(chan, pitch, vel, color) {
    }
    function noteUnmark(chan, pitch, vel, color) {
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

        width: fretBoard1.width * 10 + 55*4+40*6; height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 5
        color: "#141414"

        Row {
            id: fretBoardNumber
            width: parent.width; height: 18
            anchors.left: parent.left

            Repeater {
                model: 20

                Label {
                    text: modelData < 10 ? i18nc("technical term, do you have a musician friend?", "Octave") + " " + (1 + modelData) :
                                          i18nc("technical term, do you have a musician friend?", "Oct") + (1 + modelData)
                    width: modelData < 10 ? board.fretBoard_width : modelData < 14 ? 55 : 40;
                    color: "white"
                    height: parent.height
                }
            }
        }

        Item {
            id: board
            anchors {top: fretBoardNumber.bottom; left: parent.left; right: parent.right}
            height: fretBoard1.height * 1.1

            property alias fretBoard_width: fretBoard1.width

            FretBoard { id: fretBoard1; anchors.left: parent.left}
            FretBoard { id: fretBoard2; anchors.left: fretBoard1.right}
            FretBoard { id: fretBoard3; anchors.left: fretBoard2.right}
            FretBoard { id: fretBoard4; anchors.left: fretBoard3.right}
            FretBoard { id: fretBoard5; anchors.left: fretBoard4.right}
            FretBoard { id: fretBoard6; anchors.left: fretBoard5.right}
            FretBoard { id: fretBoard7; anchors.left: fretBoard6.right}
            FretBoard { id: fretBoard8; anchors.left: fretBoard7.right}
            FretBoard { id: fretBoard9; anchors.left: fretBoard8.right}
            FretBoard { id: fretBoard10; anchors.left: fretBoard9.right}
            FretBoard { id: fretBoard11; anchors.left: fretBoard10.right; width: 55}
            FretBoard { id: fretBoard12; anchors.left: fretBoard11.right; width: 55}
            FretBoard { id: fretBoard13; anchors.left: fretBoard12.right; width: 55}
            FretBoard { id: fretBoard14; anchors.left: fretBoard13.right; width: 55}
            FretBoard { id: fretBoard15; anchors.left: fretBoard14.right; width: 40}
            FretBoard { id: fretBoard16; anchors.left: fretBoard15.right; width: 40}
            FretBoard { id: fretBoard17; anchors.left: fretBoard16.right; width: 40}
            FretBoard { id: fretBoard18; anchors.left: fretBoard17.right; width: 40}
            FretBoard { id: fretBoard19; anchors.left: fretBoard18.right; width: 40}
            FretBoard { id: fretBoard20; anchors.left: fretBoard19.right; width: 40}
        }
    }

    ScrollIndicator.horizontal: ScrollIndicator { active: true }
}
