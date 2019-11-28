#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():
    os.system("pod install")

    appId = ""
    if "AGORA_APP_ID" in os.environ:
        appId = os.environ["AGORA_APP_ID"]


    f = open("./AgoraEducation/Supporting Files/Configs.m", 'r+')
    content = f.read()
    appString = "@\"" + appId + "\""
    tokenString = "@\"" + baseUrl + "\""
    contentNew = re.sub(r'<#@"Agora AppID"#>', appString, content)
    contentNew = re.sub(r'<#@"netless Token"#>', tokenString, contentNew)
    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
