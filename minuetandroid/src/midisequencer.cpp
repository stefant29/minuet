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

#include "midisequencer.h"
#include "csengine.h"

#include <QtMath>
#include <QLoggingCategory>

#include <QtQml>

Q_DECLARE_LOGGING_CATEGORY(MINUET)


MidiSequencer::MidiSequencer() :
    i(1),
    j(1)
{
    qmlRegisterType<MidiSequencer>("org.kde.minuetandroid", 1, 0, "MidiSequencer");
    m_csoundengine = new CsEngine;
}

void MidiSequencer::clearExercise()
{
    QFile dfile("./test1.csd");
    if(dfile.exists())
        QFile::remove("./test1.csd");
    QFile sfile("assets:/share/test1.csd");
    if (sfile.exists())
    {
        sfile.copy("./test1.csd");
        QFile::setPermissions("./test1.csd",QFile::WriteOwner | QFile::ReadOwner);
    }
    i=1;
    j=1;
}

void MidiSequencer::appendEvent(unsigned int midiNote,unsigned int barStart)
{
    //QString number;
//    QString instrumentString = "</CsInstruments>";
//    QString scoreString =  "</CsScore>";
    QString content;
    QFile m_csdFileOpen("./test1.csd");
    if(!m_csdFileOpen.isOpen()){
        m_csdFileOpen.open(QIODevice::ReadWrite | QIODevice::Text);
    }
    QString lineData;
    QTextStream in(&m_csdFileOpen);
    while(!in.atEnd()){
        lineData = in.readLine();
        /*if(lineData.contains("</CsInstruments>")){
            number = QString::number(i);
            QString a = "instr ";
            //QString b = "\naout vco2 0.5, 440\nouts aout, aout\nendin\n";
            QString b = "\naout oscil 0.5, " + QString::number(noteFreq) + "\nouts aout, aout\nendin\n";
            //QString b = "\nasig oscil 10000, 440, 1\nout asig\nendin\n";
            QString instrument = a + number + b;
            content= content + instrument;
            i++;
        }*/
        if(lineData.contains("i 99 0 10")){
            //QString initScore = "i" + QString::number(j) + " 0 " + "3\n" ;
            QString initScore = "i 1 " + QString::number(barStart) + " " + QString::number(barStart+1) + " " + QString::number(midiNote) + " 100"+ "\n" ;
            content = content + initScore;
            //j++;
        }
        content= content + lineData + "\n";
    }
    m_csdFileOpen.seek(0);
    QByteArray contentByte = content.toUtf8();
    m_csdFileOpen.write(contentByte);
}

/*float MidiSequencer::midiFreq(unsigned int midiNote)
{
    float freq;
    int a = 440; // a is 440 hz...
    float num=(midiNote-9)/12.0;
    freq=(a*1.0 / 32) * qPow(2,num);
    return freq;
}*/

MidiSequencer::~MidiSequencer()
{
    delete m_csoundengine;
}

void MidiSequencer::play(){
    m_csoundengine->start();
}

void MidiSequencer::stop(){
    m_csoundengine->stop();
}
