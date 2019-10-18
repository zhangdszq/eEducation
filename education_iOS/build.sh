#!/bin/sh

BUILD_DATE=`date +%Y-%m-%d-%H.%M.%S`
ArchivePath=AgoraMiniClass-${BUILD_DATE}.xcarchive

xcodebuild clean -workspace "AgoraMiniClass.xcworkspace" -scheme "AgoraMiniClass" -configuration Release
xcodebuild -workspace "AgoraMiniClass.xcworkspace" -scheme "AgoraMiniClass" -archivePath ${ArchivePath} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath . -quiet || exit
