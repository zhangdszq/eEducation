# eEducation (Android)

*Read this in other languages: [English](README.md)*

## 运行示例程序
首先在 [Agora.io 注册](https://dashboard.agora.io/cn/signup/) 注册账号，并创建自己的测试项目，获取到 AppID。

将 AppID 填写进 "app/src/main/res/values/strings.xml" 和 "app/src/main/res/values-zh/strings.xml"

```
<string name="agora_app_id"><#YOUR APP ID#></string>

```

其次将服务器的base url, 填写进 "app/src/main/java/io/agora/rtc/MiniClass/model/constant/Constant.java"

```
public static final String BASE_URL = your_base_url;

```

## 运行环境
- Android Studio 2.0 +
- 真实 Android 设备 (Nexus 5X 或者其它设备)
- 部分模拟器会存在功能缺失或者性能问题，所以推荐使用真机

## 联系我们
- 完整的 API 文档见 [文档中心](https://docs.agora.io/cn/)
- 如果在集成中遇到问题, 你可以到 [开发者社区](https://dev.agora.io/cn/) 提问
- 如果有售前咨询问题, 可以拨打 400 632 6626，或加入官方Q群 12742516 提问
- 如果需要售后技术支持, 你可以在 [Agora Dashboard](https://dashboard.agora.io) 提交工单
- 如果发现了示例代码的 bug, 欢迎提交 [issue](https://github.com/AgoraIO/Rtm/issues)

## 代码许可
The MIT License (MIT).
