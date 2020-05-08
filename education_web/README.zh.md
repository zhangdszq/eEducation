# 声网教育场景demo  

*English Version: [English](README.md)*  

### 在线预览
  [web demo](https://solutions.agora.io/education/web/)

### 简介
  Agora Edu是基于声网的音视频sdk和实时消息sdk，以及Netless的白板sdk构成  
  主要功能如下:

  |功能概述|代码入口|功能描述|  
  | ---- | ----- | ----- |
  |老师1v1教学授课 | [one-to-one.tsx](./src/pages/classroom/one-to-one.tsx) | 1个老师和1个学生默认连麦进入教室 |
  |小班课场景：老师1v16学生教学授课| [small-class.tsx](./src/pages/classroom/small-class.tsx) | 1个老师和至多16个学生默认连麦进入教室 |
  |大班课场景：老师1v多学生，默认以观众身份进入频道，举手向老师发起连麦，老师接受连麦并且统一以后，连麦互动。| [big-class.tsx](./src/pages/classroom/big-class.tsx) | 1个老师默认连麦进入教室，学生进入无限制人数 |

### 使用的SDK
  * agora-rtc-sdk（web版声网sdk）
  * agora-rtm-sdk（web版声网实时消息sdk）
  * agora-electron-sdk（声网官方electron-sdk）
  * white-web-sdk（netless官方白板sdk）
  * ali-oss（可替换成你自己的oss client）
  * 声网云录制 （不推荐直接在客户端集成）

### 使用到的服务  
  * agora教育后端（可选）

### 所用技术
  * typescript ^3.6.4
  * react & react hooks & rxjs
  * electron 7.1.2 & electron-builder
  * material-ui
  * Agora eEducation 教育后端服务


### 开发环境
  * mac or windows
  * nodejs LTS
  * electron 7.1.2

### electron & node-sass 下载慢的解决方案
  * mac
  ```
  export ELECTRON_MIRROR="https://npm.taobao.org/mirrors/electron/"
  export ELECTRON_CUSTOM_DIR="7.1.2"
  export SASS_BINARY_SITE="https://npm.taobao.org/mirrors/node-sass/"

  ```
  * windows
  ```
  set ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/
  set ELECTRON_CUSTOM_DIR=7.1.2
  set SASS_BINARY_SITE=https://npm.taobao.org/mirrors/node-sass/
  ```

### electron 打包程序慢的解决方案
  * mac
  ```
  export ELECTRON_CUSTOM_DIR=7.1.2
  export ELECTRON_BUILDER_BINARIES_MIRROR=https://npm.taobao.org/mirrors/electron-builder-binaries/
  export ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/ 

  ```
  * windows
  ```
  set ELECTRON_CUSTOM_DIR=7.1.2
  set ELECTRON_BUILDER_BINARIES_MIRROR=https://npm.taobao.org/mirrors/electron-builder-binaries/
  set ELECTRON_MIRROR=https://npm.taobao.org/mirrors/electron/
  ```

### electron环境注意事项
  * mac 不需要修改package.json
  * windows 需要找到package.json里的`agora_electron` 按照如下结构替换
  ```
    "agora_electron": {
      "electron_version": "7.1.2",
      "prebuilt": true,
      "platform": "win32"
    },
  ```
  (windows上推荐手动安装electron 7.1.2)
  ```
  npm install electron@7.1.2 --arch=ia32 --save-dev
  ```

### 环境搭建

# 注意 
#### 如果你的appid项目里启用了证书服务，请在代码里搜索以下注释寻找使用到token的地方，在这里加入获取token的业务逻辑。
```
WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
```

# 搭建之前先获取 agora appid和netless sdktoken
  按照.env.example
  修改为.env.local
```bash
# 声网的 APPID
REACT_APP_AGORA_APP_ID=agora appId
REACT_APP_AGORA_LOG=true
ELECTRON_START_URL=http://localhost:3000

# (可选参数配置项)
# 声网开发者customerId
REACT_APP_AGORA_CUSTOMER_ID=customer_id
# 声网开发者customerCertificate
REACT_APP_AGORA_CUSTOMER_CERTIFICATE=customer_certificate
# 声网开发者rtm restful api接口仅供demo展示（请在自己的服务端接入）
REACT_APP_AGORA_RTM_ENDPOINT=your_server_rtm_endpoint_api
# 声网教育场景化后端api前缀
REACT_APP_AGORA_EDU_ENDPOINT_PREFIX=agora_edu_api_prefix

# 你自己的全路径白板后端api服务
REACT_APP_YOUR_BACKEND_WHITEBOARD_API=your_server_whiteboard_api

# 声网restful api token
REACT_APP_AGORA_RESTFULL_TOKEN=agora_restful_api_token

# 你自己的OSS bucket name
REACT_APP_YOUR_OWN_OSS_BUCKET_NAME=your_oss_bucket_name
# 你自己的OSS bucket 目录
REACT_APP_YOUR_OWN_OSS_BUCKET_FOLDER=your_oss_bucket_folder
# 你自己的OSS bucket region
REACT_APP_YOUR_OWN_OSS_BUCKET_REGION=your_bucket_region
# 你自己的OSS bucket access key
REACT_APP_YOUR_OWN_OSS_BUCKET_KEY=your_bucket_ak
# 你自己的OSS bucket access secret key
REACT_APP_YOUR_OWN_OSS_BUCKET_SECRET=your_bucket_sk
# 你自己的OSS bucket access endpoint
REACT_APP_YOUR_OWN_OSS_CDN_ACCELERATE=your_cdn_accelerate_endpoint
```

# Web发布和开发操作  

#### 本地开发运行方式  
  `npm run dev`  

#### 本地编译方式  
  `npm run build`  

### 部署的时候需要修改package.json，然后执行npm run build  
  "homepage": "你的域名/路径"  

# Electron版发布和开发操作  

#### 本地运行  
  `npm run electron`  
  `此时会启动两个进程，一个进程使用cra的webpack编译构建render进程，electron主进程会等待webpack构建成功以后开始执行。`  

#### electron mac打包方式
  npm run pack:mac  
  等待成功运行结束时会产生一个release目录，默认会打包出一个dmg文件，正常打开更新到Application目录即可完成安装，然后可以执行程序。  

#### electron win32程序打包方式（执行之前请务必确保已经正确安装--arch=ia32版本5.0.8的electron和agora-electron-sdk "platform": "win32"版）
  npm run pack:win  
  
  等待成功运行结束时会产生一个release目录，默认会打包出一个安装程序，请使用windows管理员身份打开，即可完成安装，然后可以执行程序。  

#### FAQ  
  * [问题反馈](https://github.com/AgoraIO-Usecase/eEducation/issues/new)  
  * 关于electron启动时发现localhost:3000端口被占用问题解决方案，可以在package.json里找到ELECTRON_START_URL=http://localhost:3000 修改成你本地可以使用的端口号  
