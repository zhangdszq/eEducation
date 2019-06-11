# Agora eEducation

> Complete eEducation solutions for both web and native platform.

## Feature

- Device Test before class
- Basic video&audio realtime communication
- Basic class control like mute/unmute video/audio/chat
- Whiteboard for realtime visual collaboration
- Screen Sharing
- Text chat rooms
- Recording

## Quickstart

- Web App: https://webdemo.agora.io/education_web/  
- Mac: https://github.com/AgoraIO-Usecase/eEducation/releases/download/v4.0.2/AgoraEducation-4.0.2-mac.zip
- Win: https://github.com/AgoraIO-Usecase/eEducation/releases/download/v4.0.2/AgoraEducation.Setup.4.0.2.exe

You can traverse Readmes under each folder for detail.

## Structure

### education_web

Web client based on a list of Agora RTM/Media SDK (JS) and React.

### education_electron

Mac and Windows Client based on Agora RTM SDK (JS) and Media SDK (NodeJs based on c++ addon), React and Electron.

### education_server

Sentry server based on Agora RTM SDK (NodeJS based on c++ addon) to accept and solve command message and do in-memory-cache.

### whiteboard\_server (Will be merged into education_server)

RESTFul gateway for Herewhite whiteboard service.

### recording_server (Go to [this repo](https://github.com/AgoraIO/Basic-Recording/tree/release/2.3.3/Agora-Restful-Recording-Nodejs))

RESTFul gateway for Agora Recording.

## Develop
Before constructing your own project based on this repo, we recommend you to have a basic knowledge of resourses below:

### Typescript, React, Electron
### Agora SDKs
- RTC SDK for [Web](https://docs.agora.io/en/Video/API%20Reference/web/index.html) and [Electron](https://github.com/AgoraIO/Electron-SDK)
- RTM for [Web]() and [NodeJS](https://github.com/AgoraIO-Community/Agora-RTM-Nodejs)
- [Recording Server](https://github.com/AgoraIO/Basic-Recording/tree/release/2.3.3/Agora-Restful-Recording-Nodejs)


## License
MIT
