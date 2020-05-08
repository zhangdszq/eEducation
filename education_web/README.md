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

### Backend Service  
  * agora education backend

### Frontend Tech Utilities
  * typescript ^3.6.4
  * react & react hooks & rxjs
  * electron 7.1.2 & electron-builder
  * material-ui
  * Agora eEducation Backend api


### Development Environment
  * mac or windows
  * nodejs LTS
  * electron 7.1.2

### For Windows Electron Developer
  * npm install electron@7.1.2 arch=ia32 manually  
  ```  
  npm install electron@7.1.2 --arch=ia32 --save-dev
  ```  
  * find the `agora_electron` from package.json, replace it with below code snippet  
  ```
    "agora_electron": {
      "electron_version": "7.1.2",
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
# Agora AppId
REACT_APP_AGORA_APP_ID=agora appId
REACT_APP_AGORA_LOG=true
ELECTRON_START_URL=http://localhost:3000

# (OPTIONAL)
# agora customer id obtain from developer console dashboard
REACT_APP_AGORA_CUSTOMER_ID=customer_id
# agora customer certificate obtain from developer console dashboard
REACT_APP_AGORA_CUSTOMER_CERTIFICATE=customer_certificate
# agora rtm endpoint obtain from developer documentation center
REACT_APP_AGORA_RTM_ENDPOINT=your_server_rtm_endpoint_api
# agora education endpoint prefix
REACT_APP_AGORA_EDU_ENDPOINT_PREFIX=agora_edu_api_prefix

# your whiteboard server endpoint
REACT_APP_YOUR_BACKEND_WHITEBOARD_API=your_server_whiteboard_api

# agora restful api token
REACT_APP_AGORA_RESTFULL_TOKEN=agora_restful_api_token

# your oss bucket name
REACT_APP_YOUR_OWN_OSS_BUCKET_NAME=your_oss_bucket_name
# your oss bucket folder
REACT_APP_YOUR_OWN_OSS_BUCKET_FOLDER=your_oss_bucket_folder
# your oss bucket region
REACT_APP_YOUR_OWN_OSS_BUCKET_REGION=your_bucket_region
# your oss bucket access key
REACT_APP_YOUR_OWN_OSS_BUCKET_KEY=your_bucket_ak
# your oss bucket access secret key
REACT_APP_YOUR_OWN_OSS_BUCKET_SECRET=your_bucket_sk
# your oss bucket endpoint
REACT_APP_YOUR_OWN_OSS_CDN_ACCELERATE=your_cdn_accelerate_endpoint
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
  * npm i electron@7.1.2 --arch=ia32  
  * find and replace `agora_electron`:  
  ```
    "agora_electron": {
      "electron_version": "7.1.2",
      "prebuilt": true,
      "platform": "win32"
    },
  ```    
  * If you already did npm install, please clean node_modules & reinstall  
  * final step: npm run pack:win   

#### FAQ
  * [ISSUES](https://github.com/AgoraIO-Usecase/eEducation/issues/new)  
  * If you find your localhost:3000 port already exists or refused, please modify `ELECTRON_START_URL` from package.json, change to available port then run it again.  
