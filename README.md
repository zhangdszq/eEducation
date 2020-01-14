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
    <a href="#demos">View Demo</a>
    ·
    <a href="https://github.com/AgoraIO-Usecase/eEducation/issues">Report Bug</a>
    ·
    <a href="https://github.com/AgoraIO-Usecase/eEducation/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
## Table of Contents
* [Demos](#demos)
* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)

## Demos
  * [Android](./education_Android/AgoraEducation/README.md)
  * [iOS](./education_iOS/README.md)
  * [Web & Electron](./education_web/README.md)

## About The Project

e-Education Sample App built with Agora Electron SDK.

- Device Test before class
- Basic video&audio realtime communication
- Basic class control like mute/unmute video/audio/chat
- Whiteboard for realtime visual collaboration
- Screen Sharing
- Text chat rooms
- Recording & Replaying


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

To build and run the sample application, get an App ID:
1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Save the **App ID** from the Dashboard for later use.
4. Generate a temp **Access Token** (valid for 24 hours) from dashboard page with given channel name, save for later use.

### Project Structure
- education_Android
  Android client based on a list of Agora RTM/Media SDK, for more [details](./education_Android/AgoraEducation)
- education_iOS
  iOS client based on a list of Agora RTM/Media SDK, for more [details](./education_iOS)
- education_web
  Web & Electron client based on a list of Agora RTM/Media SDK [details](./education_web)

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
