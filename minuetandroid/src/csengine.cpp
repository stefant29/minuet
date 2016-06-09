#include "csengine.h"
#include <QDebug>
#include <QFile>
#include <QStringList>
#include <QDir>
#include <QStandardPaths>
// NB! use DEFINES += USE_DOUBLE


CsEngine::CsEngine()
{
    cs.setOpenSlCallbacks(); // for android audio to work
    mStop=false;
    cs.SetOption("-odac");
    cs.SetOption("-d");
}

void CsEngine::run() {

    QString orc ="\n sr = 44100 \n nchnls = 2 \n 0dbfs = 1 \n ksmps = 32 \n \n instr test \n prints \"INSTR TEST\" \n kval chnget \"value\" \n ;printk2 kval \n kfreq = 300+400*kval \n asig vco2 linen(0.5,0.05,p3,0.1), kfreq \n asig moogvcf asig, 400+600*(1-kval), 0.3+(1-kval)/2 \n outs asig, asig \n endin";
    if (!cs.CompileOrc(orc.toLocal8Bit())) {
            cs.Start();
            cs.Perform();
    }

}

void CsEngine::stop()
{
    cs.Stop();
}


void CsEngine::setChannel(const QString &channel, MYFLT value)
{
    //qDebug()<<"setChannel "<<channel<<" value: "<<value;
    cs.SetChannel(channel.toLocal8Bit(), value);
}

void CsEngine::csEvent(const QString &event_string)
{
    cs.InputMessage(event_string.toLocal8Bit());
}
