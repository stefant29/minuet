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

#include "csoundandroidsoundbackend.h"
#include "csengine.h"

#include <QtMath>
#include <QLoggingCategory>

#include <QtQml>

Q_DECLARE_LOGGING_CATEGORY(MINUETANDROID)


CsoundAndroidSoundBackend::CsoundAndroidSoundBackend()
{
    qmlRegisterType<CsoundAndroidSoundBackend>("org.kde.minuet", 1, 0, "CsoundAndroidSoundBackend");
    m_csoundengine = new CsEngine;
}

void CsoundAndroidSoundBackend::clearExercise()
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
}

void CsoundAndroidSoundBackend::appendEvent(QList<unsigned int> midiNotes,QList<unsigned int> barStartInfo)
{
    //TODO : use grantlee processing or any other text template library
    QString content;
    QFile m_csdFileOpen("./test1.csd");
    if(!m_csdFileOpen.isOpen()){
        m_csdFileOpen.open(QIODevice::ReadWrite | QIODevice::Text);
    }
    QString lineData;
    QTextStream in(&m_csdFileOpen);
    while(!in.atEnd()){
        lineData = in.readLine();
        content= content + lineData + "\n";
        if(lineData.contains("<CsScore>")){
            for(int i=0 ; i<midiNotes.count() ; i++){
                QString initScore = "i 1 " + QString::number(barStartInfo.at(i)) + " " + QString::number(1) + " " + QString::number(midiNotes.at(i)) + " 100"+ "\n" ;
                content = content + initScore;
            }
            QString instrInit = "i 99 0 " + QString::number(barStartInfo.at(barStartInfo.count()-1)+1) + "\ne\n";//instrument will be active till the end of the notes +1 second
            content = content + instrInit;
        }
    }
    m_csdFileOpen.seek(0);
    QByteArray contentByte = content.toUtf8();
    m_csdFileOpen.write(contentByte);
}

CsoundAndroidSoundBackend::~CsoundAndroidSoundBackend()
{
    delete m_csoundengine;
}

void CsoundAndroidSoundBackend::play(){
    m_csoundengine->start();
}

void CsoundAndroidSoundBackend::stop(){
    m_csoundengine->stop();
}
