#!/bin/sh
BUILD_DATE=`date +%Y-%m-%d-%H.%M.%S`
ArchivePath=Agora-iOS-Tutorial-${BUILD_DATE}.xcarchive

xcodebuild clean -project "AgoraMiniClass.xcworkspace" -scheme "AgoraMiniClass" -configuration Release
xcodebuild -project "AgoraMiniClass.xcworkspace" -scheme "AgoraMiniClass" -archivePath ${ArchivePath} archive
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath .
