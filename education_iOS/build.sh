#!/bin/sh

BUILD_DATE=`date +%Y-%m-%d-%H.%M.%S`
ArchivePath=AgoraEducation-${BUILD_DATE}.xcarchive

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraMiniClass" -configuration Release
xcodebuild -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -archivePath ${ArchivePath} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath . -quiet || exit
