#!/bin/bash

jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ../../../Minuet-release-key.keystore ./minuetandroid_build_apk/bin/QtApp-release-unsigned.apk KDE

jarsigner -verify -verbose -certs ./minuetandroid_build_apk/bin/QtApp-release-unsigned.apk KDE

/home/android-devel/android-sdk-linux/build-tools/24.0.1/zipalign -v 4 ./minuetandroid_build_apk/bin/QtApp-release-unsigned.apk ./minuetandroid_build_apk/bin/QtApp-release-signed-aligned.apk
