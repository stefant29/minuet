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
//ask if minuetandroid or minuet
#ifndef MINUET_CSOUNDANDROIDSOUNDBACKEND_H
#define MINUET_CSOUNDANDROIDSOUNDBACKEND_H

#include "isoundbackend.h"

class CsEngine;

class CsoundAndroidSoundBackend : public Minuet::ISoundBackend
{
    Q_OBJECT

    //Q_PLUGIN_METADATA(IID "org.kde.minuet.IPlugin" FILE "csoundandroidsoundbackend.json")
    Q_INTERFACES(Minuet::IPlugin)
    Q_INTERFACES(Minuet::ISoundBackend)

public:
    explicit CsoundAndroidSoundBackend(QObject *parent = 0);
    virtual ~CsoundAndroidSoundBackend() override;

public Q_SLOTS:

    virtual void setPitch(qint8 pitch);
    virtual void setVolume(quint8 volume);
    virtual void setTempo (quint8 tempo);

    virtual void prepareFromExerciseOptions(QJsonArray selectedExerciseOptions, const QString &playMode) override;
    virtual void prepareFromMidiFile(const QString &fileName) override;

    virtual void play() override;
    virtual void pause() override;
    virtual void stop() override;

private:
    CsEngine *m_csoundEngine;
    void appendEvent(QList<unsigned int> midiNotes,QList<unsigned int> barStartInfo);
    void clearExercise();

};

#endif
