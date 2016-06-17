cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(minuetandroid)

#set(CMAKE_AUTOMOC ON)

# KDE Application Version, managed by release script
set (KDE_APPLICATIONS_VERSION_MAJOR "16")
set (KDE_APPLICATIONS_VERSION_MINOR "07")
set (KDE_APPLICATIONS_VERSION_MICRO "70")
#set (KDE_APPLICATIONS_VERSION "${KDE_APPLICATIONS_VERSION_MAJOR}.${KDE_APPLICATIONS_VERSION_MINOR}.${KDE_APPLICATIONS_VERSION_MICRO}")
set (KDE_APPLICATIONS_VERSION "0.1.70")

set(ECM_MIN_VERSION "5.15.0")
set(QT_MIN_VERSION "5.4.0")
set(KF5_MIN_VERSION "5.15.0")

if(CMAKE_SYSTEM_NAME STREQUAL Android)
    add_definitions(-DANDROID )
    add_definitions(-DUSE_DOUBLE)
    set(ANDROID TRUE)
endif()
find_package(ECM ${ECM_MIN_VERSION} CONFIG REQUIRED)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(ECMSetupVersion)
include(ECMInstallIcons)
include(KDEInstallDirs)
include(KDECMakeSettings)

include(FeatureSummary)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS I18n)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Core Gui Quick Qml)

add_library(csoundandroid SHARED IMPORTED)
set_property(TARGET csoundandroid PROPERTY IMPORTED_LOCATION_RELEASE /home/ayush/csound-android-6.07.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi/libcsoundandroid.so)

add_library(sndfile SHARED IMPORTED)
set_property(TARGET sndfile PROPERTY IMPORTED_LOCATION_RELEASE /home/ayush/csound-android-6.07.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi/libsndfile.so)

add_library(c++_shared SHARED IMPORTED)
set_property(TARGET c++_shared PROPERTY IMPORTED_LOCATION_RELEASE /home/ayush/csound-android-6.07.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi/libc++_shared.so)

link_directories(/home/ayush/csound-android-6.07.0/CsoundForAndroid/CsoundAndroid/src/main/jniLibs/armeabi)

include_directories(/home/ayush/csound/include)
include_directories(/home/ayush/csound/android/CsoundAndroid/jni/)

add_subdirectory(src)
add_subdirectory(exercises)
set(minuetandroid_CSD
test1.csd)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
install(FILES ${minuetandroid_CSD} DESTINATION ${KDE_INSTALL_DATADIR})
