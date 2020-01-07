<!-- PROJECT SHIELDS -->
[![Build Status][build-shield]][build-url]
[![MIT License][license-shield]][license-url]



<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href=".">
    <img src="logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Agora e-Education</h3>

  <p align="center">
    Complete e-Education solutions for both web and native platform.
    <br />
    <a href="#about-the-project"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="#using">View Demo</a>
    ·
    <a href="https://github.com/AgoraIO-Usecase/eEducation/issues">Report Bug</a>
    ·
    <a href="https://github.com/AgoraIO-Usecase/eEducation/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents
* [Using](#using)
* [About the Project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)


<!-- Using Demos -->
## Using
Have a try with our built demo!

- Web App: https://webdemo.agora.io/education_web/  
- Mac and Windows App: Go to [releases](https://github.com/AgoraIO-Usecase/eEducation/releases) for latest release


<!-- ABOUT THE PROJECT -->
## About The Project

![Product Name Screen Shot][product-screenshot]

e-Education Sample App built with Agora Electron SDK.

- Device Test before class
- Basic video&audio realtime communication
- Basic class control like mute/unmute video/audio/chat
- Whiteboard for realtime visual collaboration
- Screen Sharing
- Text chat rooms
- Recording

### Built With
- [Electron](https://github.com/electron/electron)
- [React](https://github.com/facebook/react)
- [Typescript](https://github.com/microsoft/TypeScript)
- RTC SDK for [Web](https://docs.agora.io/en/Video/API%20Reference/web/index.html) and [Electron](https://github.com/AgoraIO/Electron-SDK)
- RTM for [Web]() and [NodeJS](https://github.com/AgoraIO-Community/Agora-RTM-Nodejs)
- [Recording Server](https://github.com/AgoraIO/Basic-Recording/tree/release/2.3.3/On-Premise-Recording-Nodejs)


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

To build and run the sample application, get an App ID:
1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Save the **App ID** from the Dashboard for later use.
4. Generate a temp **Access Token** (valid for 24 hours) from dashboard page with given channel name, save for later use.

### Installation

1. Enter your APP ID and other env config in .env under each folder
2. Run `npm install` to install dependencies and `npm run start` (usually) to start an application. (You can traverse Readmes under each folder for detail.)

### Project Structure
- education_web  
Web client based on a list of Agora RTM/Media SDK (JS) and React.
- education_electron  
Mac and Windows Client based on Agora RTM SDK (JS) and Media SDK (NodeJs based on c++ addon), React and Electron.  
- education_server  
Sentry server based on Agora RTM SDK (NodeJS based on c++ addon) to accept and solve command message and do in-memory-cache.  
- whiteboard\_server (Will be merged into education_server)  
RESTFul gateway for Herewhite whiteboard service.  
- recording_server (Go to [this repo](https://github.com/AgoraIO/Basic-Recording/tree/release/2.3.3/On-Premise-Recording-Nodejs) for detail.)

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.


<!-- MARKDOWN LINKS & IMAGES -->
[build-shield]: https://img.shields.io/travis/AgoraIO-Usecase/eEducation/master.svg?style=flat-square
[build-url]: https://travis-ci.org/AgoraIO-Usecase/eEducation
[license-shield]: https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-url]: https://choosealicense.com/licenses/mit
[product-screenshot]: ./screenshot.png
