# Agora Education Web & Electron demo  
*Other Language: [简体中文](README.zh.md)*

### Preview
  [web demo](https://solutions.agora.io/education/web/)

### Description
  Agora Education solution is based on Agora RTM/Media sdk & netless whiteboard sdk.  
  For developer guideline:

  |Feature|code entry|description|  
  | ---- | ----- | ----- |
  | 1v1 | [one-to-one.tsx](./src/pages/classroom/one-to-one.tsx) | One teacher co-video with one student |
  | 1v16: small-class scenario| [small-class.tsx](./src/pages/classroom/small-class.tsx) | One teacher co-video with 16 students |
  | 1vN：big-class scenario | [big-class.tsx](./src/pages/classroom/big-class.tsx) | One teacher co-video with one student, student can join class with audience role, only send co-video with teacher, teacher permit co-video will become host and co-video. |

### Core SDKs
  * agora-rtc-sdk (agora web sdk)
  * agora-rtm-sdk (agora web sdk)
  * agora-electron-sdk  (official agora electron sdk)
  * white-web-sdk (netless web sdk)
  * ali-oss (can be replaced with your own cloud oss sdk)
  * agora cloud recording (we recommend to integrate in server side)

### Frontend Tech Utilities
  * typescript ^3.6.4
  * react & react hooks & rxjs
  * electron 5.0.8 & electron-builder
  * material-ui


### Development Environment
  * mac or windows
  * nodejs LTS
  * electron 5.0.8

### For Windows Electron Developer
  * npm install electron@5.0.8 arch=ia32 manually  
  ```  
  npm install electron@5.0.8 --arch=ia32 --save-dev
  ```  
  * find the `agora_electron` from package.json, replace it with below code snippet  
  ```
    "agora_electron": {
      "electron_version": "5.0.8",
      "prebuilt": true,
      "platform": "win32"
    },
  ```  

### Setup

# Notice 
#### If you are already enabled app certificate for security, please find below comment and integrate with your obtain token code snippet here.
```
WARN: IF YOU ENABLED APP CERTIFICATE, PLEASE SIGN YOUR TOKEN IN YOUR SERVER SIDE AND OBTAIN IT FROM YOUR OWN TRUSTED SERVER API
```

# obtain agora appid 和 netless sdktoken
  rename .env.example to .env.local
```bash
# agora APPID obtain from dashboard.agora.io
REACT_APP_AGORA_APP_ID=Agora APPID
# true is indicate the agora sdk will enable log
REACT_APP_AGORA_LOG=true
# obtain netless whiteboard sdk from herewhite official website
REACT_APP_NETLESS_APP_TOKEN=SDKTOKEN
# whiteboard api create room entry and join room end-points
REACT_APP_NETLESS_APP_API_ENTRY=https://cloudcapiv4.herewhite.com/room?token=
REACT_APP_NETLESS_APP_JOIN_API=https://cloudcapiv4.herewhite.com/room/join?token=
# agora recording service end-point
REACT_APP_AGORA_RECORDING_SERVICE_URL=https://api.agora.io/v1/apps/%s/cloud_recording/
# oss for cloud recording storage
REACT_APP_AGORA_RECORDING_OSS_URL=云录制OSS地址
# oss parameters for whiteboard courseware
REACT_APP_AGORA_OSS_BUCKET_NAME=your_oss_bucket_name
REACT_APP_AGORA_OSS_BUCKET_FOLDER=your_oss_folder
REACT_APP_AGORA_OSS_BUCKET_REGION=your_oss_region
REACT_APP_AGORA_OSS_BUCKET_KEY=your_oss_bucket_ak
REACT_APP_AGORA_OSS_BUCKET_SECRET=your_oss_bucket_sk
```

# Build Web 

#### Development build
  `npm run dev`

#### Production build
  `npm run build`

### Please double check your package.json，then `npm run build`
  "homepage": "Your domain/website path"

# Build Electron

#### Development build
  * `npm run electron`  
  * `Please take care, because this project using process manager to bootstrap electron main process, and render process start with create-react-app。`  

#### Package Electron for Mac  
  npm run pack:mac  

#### Package Electron for Win32  
  * npm i electron@5.0.8 --arch=ia32  
  * find and replace `agora_electron`:  
  ```
    "agora_electron": {
      "electron_version": "5.0.8",
      "prebuilt": true,
      "platform": "win32"
    },
  ```    
  * If you already did npm install, please clean node_modules & reinstall  
  * final step: npm run pack:win   

#### FAQ
  * [ISSUES](https://github.com/AgoraIO-Usecase/eEducation/issues/new)  
  * If you find your localhost:3000 port already exists or refused, please modify `ELECTRON_START_URL` from package.json, change to available port then run it again.  
