# Agora Education iOS Demo

*Read this in other languages: [English](README.md)*

## 项目简介
#### 小班课是基于教育场景的一个demo示例，大家可以通过工程下载到本地进行工程编译和体验，里面包含老师和学生通话，白板功能。
## 运行体验方法
#### 工程依赖
```
  pod 'AFNetworking', '~> 3.2.1'
  pod 'MJExtension', '~> 3.0.16'
  pod 'Whiteboard'
  pod 'AgoraRtcEngine_iOS', '<=2.9.0'
  pod 'AgoraRtm_iOS', '~> 1.2.2'
```
#### 系统要求
	•	最低支持iOS版本：iOS 10.0+
	•	支持CPU架构：arm64e,arm64,armv7s,armv7(x86_64模拟器)
#### 下载工程
```
git clone https://github.com/AgoraIO-Usecase/eEducation.git
```
#### 运行工程
```
cd education_iOS
pod install
open AgoraEducation.xcworkspace
```
#### 注意配置agoraAppid、agoraRTCToken、agoraRTMToken和whiteBoardToken:
```
请在KeyCenter.m 里面配置对应的内容
运行工程之前需要填入agoraAppid,获取agoraAppid的方式请登录[声网](https://console.agora.io/)获取。
运行工程之前需要填入agoraRTCToken,获取agoraRTCToken的方式请登录[声网](https://console.agora.io/)获取。
运行工程之前需要填入agoraRTMToken,获取agoraRTMToken的方式请参考[声网](https://docs.agora.io/cn/Real-time-Messaging/rtm_token)。
运行工程之前需要写入whiteBoardToken, 获取whiteBoardToken的方式请登录[Herewhite](https://console.herewhite.com/) 获取
```
> 如果没有打开鉴权Token, 这里的agoraRTCToken和agoraRTMToken值给nil就好。生成Token需要参照官方文档部署Token服务器，开发阶段若想先不部署服务器, 可以在https://dashbaord.agora.io生成临时RTC Token. 请注意生成Token时指定的频道名, 该Token只允许加入对应的频道。


## 参考文档
[声网API参考](https://docs.agora.io/cn/Interactive%20Broadcast/API%20Reference/oc/docs/headers/Agora-Objective-C-API-Overview.html)        
[白板的API参考](https://developer.netless.link/docs/ios/overview/ios-introduction)              
[RTM文档参考](https://docs.agora.io/cn/Real-time-Messaging/RTM_product?platform=All%20Platforms)

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.

