# Agora Education iOS Demo

*其他语言版本： [简体中文](README.zh.md)*

## Running the App
#### Download project
```
git clone https://github.com/AgoraIO-Usecase/eEducation.git
```

#### Run  project
```
cd education_iOS
pod install
open AgoraEducation.xcworkspace
```

#### Config parameter
First, update KeyCenter.m file  "agoraAppid" value

```
+ (NSString *)agoraAppid {
    return <#Your Agora App Id#>;
}

```
Second, update KeyCenter.m file "agoraRTCToken" value

```
+ (NSString *)agoraRTCToken {
    return <#Your Agora RTC Token#>;
}

```
Next, update KeyCenter.m file "agoraRTMToken" value

```
+ (NSString *)agoraRTMToken {
    return <#Your Agora RTM Token#>;
}

```
Last, update KeyCenter.m file "whiteBoardToken" value

```
+ (NSString *)whiteBoardToken {
    return <#Your White Token#>;
}

```
> agoraRTCToken & agoraRTMToken to nil if you have not enabled app certificate before you deploy your own token server, you can easily generate a temp RTC token for dev use at https://dashboard.agora.io note the token generated are allowed to join corresponding room ONLY.

## Developer Environment Requirements
•	Xcode 10.0+
•	Physical iOS device (iPhone or iPad)


## Connect Us
- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can file bugs about this demo at [issue](https://github.com/AgoraIO/RTM/issues)
- You can get Agora Appid at [Agora console](https://console.agora.io/)
- You can get herewhite Token at [herewhite console](https://console.herewhite.com/)

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.