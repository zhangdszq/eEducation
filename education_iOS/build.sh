#!/bin/sh

BUILD_DATE=`date +%Y-%m-%d-%H.%M.%S`
ArchivePath=AgoraEducation-${BUILD_DATE}.xcarchive
IPAName="IPADEV"

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration Release
xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration Release -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/AgoraEducation.ipa AgoraEducationDev.ipa

# =======build qa=======
ArchivePathQA=AgoraEducationQA-${BUILD_DATE}.xcarchive
IPANameQA="IPAQA"

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QARelease
xcodebuild -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QARelease -archivePath ${ArchivePathQA} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist exportPlist.plist -archivePath ${ArchivePathQA} -exportPath ${IPANameQA} -quiet || exit
cp ${IPANameQA}/AgoraEducation.ipa AgoraEducationQA.ipa
