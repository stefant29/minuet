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

#include "csengine.h"
#include <QDebug>
#include <QFile>
#include <QStringList>
#include <QDir>
#include <QStandardPaths>
// NB! use DEFINES += USE_DOUBLE


CsEngine::CsEngine()
{
    //mStop=false;
    //cs.SetOption("-odac");
    //cs.SetOption("-d");
    m_fileName = (char *)"./test1.csd";
}

void CsEngine::run() {

    /*QString orc ="\n sr = 44100 \n nchnls = 2 \n 0dbfs = 1 \n ksmps = 32 \n \n instr test \n prints \"INSTR TEST\" \n kval chnget \"value\" \n ;printk2 kval \n kfreq = 300+400*kval \n asig vco2 linen(0.5,0.05,p3,0.1), kfreq \n asig moogvcf asig, 400+600*(1-kval), 0.3+(1-kval)/2 \n outs asig, asig \n endin";
    if (!cs.CompileOrc(orc.toLocal8Bit())) {
            cs.Start();
            cs.Perform();
    }*/
    cs.setOpenSlCallbacks(); // for android audio to work
    cs.Compile(m_fileName);
    cs.Start();
    cs.Perform();
    cs.Cleanup();
    cs.Reset();
    cs.Stop();
}

void CsEngine::stop()
{
    cs.Stop();
}


/*void CsEngine::setChannel(const QString &channel, MYFLT value)
{
    //qDebug()<<"setChannel "<<channel<<" value: "<<value;
    cs.SetChannel(channel.toLocal8Bit(), value);
}

void CsEngine::csEvent(const QString &event_string)
{
    cs.InputMessage(event_string.toLocal8Bit());
}*/
