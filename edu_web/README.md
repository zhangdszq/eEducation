# Agora Edu

### 简介
  Agora Edu是基于声网的音视频sdk和实时消息sdk，以及Netless的白板sdk构成
  主要功能如下:
  老师1v1教学授课
  小班课场景：老师1v17学生教学授课
  大班课场景：老师1v多学生，学生举手开始授课

### 需要用到的环境
  * typescript 3.6.4
  * react & react hooks
  * agora-web-sdk
  * agora-rtm-sdk
  * electron 5.0.8
  * electron-builder

### 环境搭建

# 搭建之前先获取 agora appid和netless sdktoken
  按照.env.example
  修改为.env

```bash
# 声网的APPID 通过声网开发者管理界面获取
REACT_APP_AGORA_APP_ID=Agora APPID
# true表示开启声网前端日志
REACT_APP_AGORA_LOG=true
# 白板的sdktoken 可以通过后台获取
REACT_APP_NETLESS_APP_TOKEN=SDKTOKEN
# 白板的api 详情请参考白板官方文档的集成指南
REACT_APP_NETLESS_APP_API_ENTRY=https://cloudcapiv4.herewhite.com/room?token=
REACT_APP_NETLESS_APP_JOIN_API=https://cloudcapiv4.herewhite.com/room/join?token=
# 声网的云录制服务地址 （不推荐在前端或客户端直接集成）
REACT_APP_AGORA_RECORDING_SERVICE_URL=https://api.agora.io/v1/apps/%s/cloud_recording/
# Electron启动时候读取的create-react-app的URL地址
ELECTRON_START_URL=http://localhost:3000
# 下列OSS相关的信息不建议放在前端存储
REACT_APP_AGORA_OSS_BUCKET_NAME=你的oss名字
REACT_APP_AGORA_OSS_BUCKET_FOLDER=你的oss存储目录
REACT_APP_AGORA_OSS_BUCKET_REGION=你的oss存储节点地区
REACT_APP_AGORA_OSS_BUCKET_KEY=你的oss存储key或者存储id
REACT_APP_AGORA_OSS_BUCKET_SECRET=你的oss的存储秘钥
```

# 部署的时候需要修改package.json
  "homepage": "你的域名/路径"

# 运行方式
  npm run dev

# 部署方式
  npm run build