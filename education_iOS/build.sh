#!/bin/sh
BUILD_DATE=`date +%Y-%m-%d-%H.%M.%S`
ArchivePath=AgoraMiniClass-${BUILD_DATE}.xcarchive

xcodebuild \
clean -configuration Release -quiet  || exit
echo '清理完成'

echo '开始编译'
xcodebuild \
archive -workspace 'AgoraMiniClass.xcworkspace' \
-scheme 'AgoraMiniClass' \
-configuration Release \
-archivePath ${ArchivePath}  -quiet  || exit

xcodebuild -exportArchive -archivePath ${ArchivePath} \
-configuration Release \
-exportPath .  \
-exportOptionsPlist exportPlist.plist \
-quiet || exit
echo '编译完成'
