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

#ifndef MINUET_DRUMSTICKSOUNDBACKEND_H
#define MINUET_DRUMSTICKSOUNDBACKEND_H

#include <interfaces/isoundbackend.h>

class DrumstickSoundBackend : public Minuet::ISoundBackend
{
    Q_OBJECT

    Q_PLUGIN_METADATA(IID "org.kde.minuet.IPlugin" FILE "drumsticksoundbackend.json")
    Q_INTERFACES(Minuet::IPlugin)
    Q_INTERFACES(Minuet::ISoundBackend)

public:
    explicit DrumstickSoundBackend(QObject *parent = 0);
    virtual ~DrumstickSoundBackend() override;

public Q_SLOTS:
    virtual void prepareFromExerciseOptions(QJsonArray selectedOptions, const QString &playMode) override;
    virtual void prepareFromMidiFile(const QString &fileName) override;

    virtual void play() override;
    virtual void pause() override;
    virtual void stop() override;
};

#endif
