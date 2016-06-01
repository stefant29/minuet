cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
#cmake_minimum_required(VERSION 3.3.2 FATAL_ERROR)#Currently I am using this version
# --^ do you need anything specific of this version?

project(minuetandroid)

set(QT_MIN_VERSION "5.4.0")
set(CMAKE_AUTOMOC ON)

include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Core Gui Quick Qml)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

add_subdirectory(src)
