const {ipcRenderer: ipc} = require('electron');

const AgoraRtcEngine = require('agora-electron-sdk').default;

const child_process = require('child_process')

const {promisify} = require('util')

const path = require('path');
const fs = require('fs');

const platform = process.platform

const rtcEngine = new AgoraRtcEngine();

window.rtcEngine = rtcEngine;
window.ipc = ipc;
window.path = path;

window.child_process = child_process

window.os_platform = platform

window.openPrivacyForCaptureScreen = () => window.child_process.execSync(`open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"`)

const AdmZip = require('adm-zip');

window.ipc.on('appPath', (event, args) => {
  const appPath = args[0];
  const logPath = path.join(appPath, `log`, `agora_sdk.log`)
  const dstPath = path.join(appPath, `log`, `agora_sdk.log.zip`)
  window.dstPath = dstPath;
  window.logPath = logPath;
  window.videoSourceLogPath = args[1];
})

const doGzip = async () => {
  const zip = new AdmZip();
  zip.addLocalFile(window.logPath)
  // if (window.videoSourceLogPath) {
  zip.addLocalFile(window.videoSourceLogPath)
  // }
  zip.writeZip(window.dstPath)
  return promisify(fs.readFile)(window.dstPath)
}

window.doGzip = doGzip;
