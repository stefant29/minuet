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

#ifndef MIDISEQUENCER_H
#define MIDISEQUENCER_H

#include <QObject>

class CsEngine;

class MidiSequencer : public QObject
{
    Q_OBJECT

public:
    explicit MidiSequencer();
    virtual ~MidiSequencer();

    void appendEvent(QList<unsigned int> midiNotes,QList<unsigned int> barStartInfo);
    void clearExercise();

public Q_SLOTS:
    void play();
    void stop();

private:
    unsigned int i;
    unsigned int j;
    CsEngine *m_csoundengine;
};

#endif // MIDISEQUENCER_H

