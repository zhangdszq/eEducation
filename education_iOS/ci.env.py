#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():
    os.system("pod install")

    agoraAppId = ""
    agoraRTCToken = ""
    agoraRTMToken = ""
    whiteBoardToken = ""
    if "AGORA_APP_ID" in os.environ:
        agoraAppId = os.environ["AGORA_APP_ID"]
    if "AGORA_RTC_TOKEN" in os.environ:
        agoraRTCToken = os.environ["AGORA_RTC_TOKEN"]
    if "AGORA_RTM_TOKEN" in os.environ:
        agoraRTMToken = os.environ["AGORA_RTM_TOKEN"]
    if "WHITE_BOARD_TOKEN" in os.environ:
        whiteBoardToken = os.environ["WHITE_BOARD_TOKEN"]

    f = open("./AgoraEducation/KeyCenter.m", 'r+')
    content = f.read()
    agoraAppIdString = "@\"" + agoraAppId + "\""
    agoraRTCTokenString = "@\"" + agoraRTCToken + "\""
    agoraRTMTokenString = "@\"" + agoraRTMToken + "\""
    whiteBoardTokenString = "@\"" + whiteBoardToken + "\""
    
    contentNew = re.sub(r'<#Your Agora App Id#>', agoraAppIdString, content)
    contentNew = re.sub(r'<#Your Agora RTC Token#>', agoraRTCTokenString, contentNew)
    contentNew = re.sub(r'<#Your Agora RTM Token#>', agoraRTMTokenString, contentNew)
    contentNew = re.sub(r'<#Your White Token#>', whiteBoardTokenString, contentNew)
    
    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
