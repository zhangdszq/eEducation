#!/bin/sh
ArchivePath=AgoraEducationDev.xcarchive
IPAName="IPADEV"

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration DevRelease
xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration DevRelease -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/AgoraEducation.ipa AgoraEducationDev.ipa

