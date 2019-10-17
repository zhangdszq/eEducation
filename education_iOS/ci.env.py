#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os

def main():
    os.system("pod install")

    appId = ""
    if "AGORA_APP_ID" in os.environ:
        appId = os.environ["AGORA_APP_ID"]

    baseUrl = ""
    if "AGORA_BASE_URL" in os.environ:
        baseUrl = os.environ["AGORA_BASE_URL"]

    f = open("./AgoraMiniClass/Configs.m", 'r+')
    content = f.read()
    appString = "@\"" + appId + "\""
    tokenString = "@\"" + baseUrl + "\""
    contentNew = re.sub(r'<#@"请获取正确的appid后测试"#>', appString, content)
    contentNew = re.sub(r'<#@"请部署服务端系统，写入正确的baseUrl"#>', tokenString, contentNew)
    f.seek(0)
    f.write(contentNew)
    f.truncate()


if __name__ == "__main__":
    main()
