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

#include "exercisecontroller.h"
#include "csoundandroidsoundbackend.h"

#include <QDir>
#include <QDateTime>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QtMath>

#include <QtQml> // krazy:exclude=includes

//#include <drumstick/alsaevent.h>

ExerciseController::ExerciseController(Minuet::ISoundBackend *csoundAndroidSoundBackend) :
    m_csoundAndroidSoundBackend(csoundAndroidSoundBackend),
    m_minRootNote(0),
    m_maxRootNote(0),
    m_playMode(ScalePlayMode),
    m_answerLength(1),
    m_chosenRootNote(0),
    m_chosenExercise(0)
{
    qmlRegisterType<ExerciseController>("org.kde.minuet", 1, 0, "ExerciseController");
}

ExerciseController::~ExerciseController()
{
}

void ExerciseController::setExerciseOptions(QJsonArray exerciseOptions)
{
    m_exerciseOptions = exerciseOptions;
}

void ExerciseController::setMinRootNote(unsigned int minRootNote)
{
    m_minRootNote = minRootNote;
}

void ExerciseController::setMaxRootNote(unsigned int maxRootNote)
{
    m_maxRootNote = maxRootNote;
}

void ExerciseController::setPlayMode(PlayMode playMode)
{
    m_playMode = playMode;
}

void ExerciseController::setAnswerLength(unsigned int answerLength)
{
    m_answerLength = answerLength;
}

unsigned int ExerciseController::chosenRootNote()
{
    return m_chosenRootNote;
}
QStringList ExerciseController::randomlyChooseExercises()
{
    QList<unsigned int> midiNotes;
    QList<unsigned int> barStartInfo;
    m_csoundAndroidSoundBackend->clearExercise();
    //clearExercise();
    qsrand(QDateTime::currentDateTimeUtc().toTime_t());
    QStringList chosenExercises;
    unsigned int barStart=0;
    for (unsigned int i = 0; i < m_answerLength; ++i) {
        m_chosenExercise = qrand() % m_exerciseOptions.size();
        QString sequence = m_exerciseOptions[m_chosenExercise].toObject()[QStringLiteral("sequence")].toString();

        if (m_playMode != RhythmPlayMode) {
            int minNote = INT_MAX;
            int maxNote = INT_MIN;
            foreach(const QString &additionalNote, sequence.split(' ')) {
                int note = additionalNote.toInt();
                if (note > maxNote) maxNote = note;
                if (note < minNote) minNote = note;
            }
            do
                m_chosenRootNote = m_minRootNote + qrand() % (m_maxRootNote - m_minRootNote);
            while (m_chosenRootNote + maxNote > 108 || m_chosenRootNote + minNote < 21);
            //appendEvent(midiFreq(m_chosenRootNote), barStart);
            midiNotes.append(m_chosenRootNote);
            barStartInfo.append(barStart);
            //m_midiSequencer->appendEvent(m_chosenRootNote, barStart);

//            barStart++;
            unsigned int j = 1;
            foreach(const QString &additionalNote, sequence.split(' ')) {
                midiNotes.append(m_chosenRootNote+additionalNote.toInt());
                barStartInfo.append((m_playMode == ScalePlayMode) ? barStart+j:barStart);
                //m_midiSequencer->appendEvent(m_chosenRootNote + additionalNote.toInt(),(m_playMode == ScalePlayMode) ? barStart+j:barStart);
                //appendEvent(midiFreq(m_chosenRootNote + additionalNote.toInt()),barStart);
                j++;
            }
        chosenExercises << m_exerciseOptions[m_chosenExercise].toObject()[QStringLiteral("name")].toString();
        }
    }
    m_csoundAndroidSoundBackend->appendEvent(midiNotes,barStartInfo);
    return chosenExercises;
}

bool ExerciseController::configureExercises()
{
    m_errorString.clear();
    QStringList exercisesDirs = QStandardPaths::locateAll(QStandardPaths::AppDataLocation, QStringLiteral("exercises"), QStandardPaths::LocateDirectory);
    foreach (const QString &exercisesDirString, exercisesDirs) {
        QDir exercisesDir(exercisesDirString);
        foreach (const QString &exercise, exercisesDir.entryList(QDir::Files)) {
            QFile exerciseFile(exercisesDir.absoluteFilePath(exercise));
            if (!exerciseFile.open(QIODevice::ReadOnly)) {
                m_errorString = QStringLiteral("Couldn't open exercise file \"%1\".").arg(exercisesDir.absoluteFilePath(exercise));
                return false;
            }
            QJsonParseError error;
            QJsonDocument jsonDocument = QJsonDocument::fromJson(exerciseFile.readAll(), &error);

            if (error.error != QJsonParseError::NoError) {
                m_errorString = error.errorString();
                exerciseFile.close();
                return false;
            }
            else {
                if (m_exercises.length() == 0)
                    m_exercises = jsonDocument.object();
                else
                    m_exercises[QStringLiteral("exercises")] = mergeExercises(m_exercises[QStringLiteral("exercises")].toArray(),
                                                            jsonDocument.object()[QStringLiteral("exercises")].toArray());
            }
            exerciseFile.close();
        }
    }
    return true;
}

QString ExerciseController::errorString() const
{
    return m_errorString;
}

QJsonObject ExerciseController::exercises() const
{
    return m_exercises;
}

QJsonArray ExerciseController::mergeExercises(QJsonArray exercises, QJsonArray newExercises)
{
    for (QJsonArray::ConstIterator i1 = newExercises.constBegin(); i1 < newExercises.constEnd(); ++i1) {
        if (i1->isObject()) {
            QJsonArray::ConstIterator i2;
            for (i2 = exercises.constBegin(); i2 < exercises.constEnd(); ++i2) {
                if (i2->isObject() && i1->isObject() && i2->toObject()[QStringLiteral("name")] == i1->toObject()[QStringLiteral("name")]) {
                    QJsonObject jsonObject = exercises[i2-exercises.constBegin()].toObject();
                    jsonObject[QStringLiteral("children")] = mergeExercises(i2->toObject()[QStringLiteral("children")].toArray(), i1->toObject()[QStringLiteral("children")].toArray());
                    exercises[i2-exercises.constBegin()] = jsonObject;
                    break;
                }
            }
            if (i2 == exercises.constEnd())
                exercises.append(*i1);
        }
    }
    return exercises;
}

/*void ExerciseController::clearExercise()
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

void ExerciseController::appendEvent(float noteFreq,unsigned int barStart)
{
    QString number;
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
        if(lineData.contains("</CsInstruments>")){
            number = QString::number(i);
            QString a = "instr ";
            //QString b = "\naout vco2 0.5, 440\nouts aout, aout\nendin\n";
            QString b = "\naout oscil 0.5, " + QString::number(noteFreq) + "\nouts aout, aout\nendin\n";
            //QString b = "\nasig oscil 10000, 440, 1\nout asig\nendin\n";
            QString instrument = a + number + b;
            content= content + instrument;
            i++;
        }
        if(lineData.contains("</CsScore>")){
            //QString initScore = "i" + QString::number(j) + " 0 " + "3\n" ;
            QString initScore = "i" + QString::number(j) + " " + QString::number(barStart) + " "+ "1\n" ;
            content = content + initScore;
            j++;
        }
        content= content + lineData + "\n";
    }
    m_csdFileOpen.seek(0);
    QByteArray contentByte = content.toUtf8();
    m_csdFileOpen.write(contentByte);
}

float ExerciseController::midiFreq(unsigned int midiNote)
{
    float freq;
    int a = 440; // a is 440 hz...
    float num=(midiNote-9)/12.0;
    freq=(a*1.0 / 32) * qPow(2,num);
    return freq;
}
*/
