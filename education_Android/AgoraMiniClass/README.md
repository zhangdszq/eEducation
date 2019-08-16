# eEducation (Android)

*其他语言版本： [简体中文](README.zh.md)*

## Running the App
First, create a developer account at [Agora.io](https://dashboard.agora.io/signin/), and obtain an App ID.
Update "app/src/main/res/values/strings.xml" and "app/src/main/res/values-zh/strings.xml" with your App ID .

```
<string name="agora_app_id"><#YOUR APP ID#></string>

```

Second, update "app/src/main/java/io/agora/rtc/MiniClass/model/constant/Constant.java" with your server's base url.

```
public static final String BASE_URL = your_base_url;

```

## Developer Environment Requirements
- Android Studio 2.0 or above
- Real devices (Nexus 5X or other devices)
- Some simulators are function missing or have performance issue, so real device is the best choice

## Connect Us
- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can file bugs about this demo at [issue](https://github.com/AgoraIO/RTM/issues)

## License
The MIT License (MIT).
