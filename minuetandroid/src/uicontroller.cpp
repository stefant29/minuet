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

#include "uicontroller.h"
#include "exercisecontroller.h"
#include "csengine.h"
#include "csoundandroidsoundbackend.h"
#include "isoundbackend.h"
#include "iexercisecontroller.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QQuickStyle>
namespace Minuet
{

UiController::UiController(QObject *parent)
    : IUiController(parent),
      m_firstTime(1)
{
}

UiController::~UiController()
{
}

bool UiController::initialize()
{
    QQmlApplicationEngine *engine = new QQmlApplicationEngine(this);
    QQmlContext *rootContext = engine->rootContext();
    CsEngine cs;

    QFile afile (QStringLiteral("assets:/share/sf_GMbank.sf2"));
    QFile ffile (QStringLiteral("libs:/armeabi-v7a/libshare_libfluidOpcodes.so"));
    QString source = QStringLiteral("assets:/share/minuet");
    QString destination = QStringLiteral("./");

    if (afile.exists()){
        afile.copy(QStringLiteral("./sf_GMbank.sf2"));
        QFile::setPermissions(QStringLiteral("./sf_GMbank.sf2"),QFile::WriteOwner | QFile::ReadOwner);
    }

    if (ffile.exists()){
        ffile.copy(QStringLiteral("./libshare_libfluidOpcodes.so"));
        QFile::setPermissions(QStringLiteral("./libshare_libfluidOpcodes.so"),QFile::WriteOwner | QFile::ReadOwner);
    }

    copyDir(source,destination);

    Minuet::ISoundBackend *m_soundBackend = new CsoundAndroidSoundBackend();
    Minuet::IExerciseController *exerciseController = new Minuet::ExerciseController(0);
    ((Minuet::ExerciseController *)exerciseController)->initialize();

    rootContext->setContextProperty("soundBackend", m_soundBackend); // forward c++ object that can be reached form
    rootContext->setContextProperty("exerciseController", exerciseController);
    rootContext->setContextProperty("uiController",this);

    engine->load(QUrl(QStringLiteral("qrc:/main.qml")));

    return true;
}

bool UiController::copyDir(const QString source, const QString destination)
{

    QDir qdir(destination);
    if(!qdir.exists())
    {
        qdir.mkpath(destination);
    }
    QDir directory(source);
    bool error = false;
    if (!directory.exists())
    {
        return false;
    }


    QStringList files = directory.entryList(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Hidden);


    QList<QString>::iterator f = files.begin();


    for (; f != files.end(); ++f)
    {
        QString filePath = QDir::toNativeSeparators(directory.path() + '/' + (*f));
        QString dPath = destination + "/" + directory.relativeFilePath(filePath);
        QFileInfo fi(filePath);
        if (fi.isFile() || fi.isSymLink())
        {
            QFile::copy(filePath, dPath);
            QFile::setPermissions(dPath, QFile::ReadOwner);
        }
        else if (fi.isDir())
        {

            QDir ddir(dPath);
            ddir.mkpath(dPath);
            if (!copyDir(filePath, dPath))
            {
                error = true;
            }
        }
    }
    return !error;
}

int UiController::isFirstTimeUser(){
    if (m_firstTime){
        m_firstTime = 0;
        return 1;
    }
    return 0;
}

}
