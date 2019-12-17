import { APP_ID } from './agora-rtc-client';
import EventEmitter from 'events';
import { btoa } from './helper';
import { AgoraStream } from '../reducers/types';
// @ts-ignore
const AgoraRtcEngine = window.rtcEngine;

if (AgoraRtcEngine) {
  AgoraRtcEngine.initialize(APP_ID);
  AgoraRtcEngine.setChannelProfile(1);
  AgoraRtcEngine.enableVideo();
  AgoraRtcEngine.enableAudio();
  AgoraRtcEngine.enableWebSdkInteroperability(true);
  AgoraRtcEngine.setVideoProfile(43, false);
}

const SHARE_ID = 7;

export interface Stream {
  uid: number
}

export enum StreamType {
  local,
  remote,
  localVideoSource,
  remoteVideoSource,
}

export class AgoraElectronStream {
  public stream: Stream;
  public playing: boolean = false;
  private domID: string;
  constructor(
    public uid: number = uid,
    public readonly type: StreamType = StreamType.remote,
  ) {
    this.domID = '';
    this.stream = {
      uid: this.uid,
    }
  }
}

export interface ElectronStreamSpec {
  streamID: number
  microphoneId?: string
  cameraId?: string
  speakerId?: string
  speakerVolume?: number
}

export class AgoraElectronClient {

  public joined: boolean;
  private readonly bus: EventEmitter;
  public localUid: number;
  public rid: string;
  public readonly rtcEngine: any
  public published: boolean;
  public shared: boolean;

  constructor() {
    this.rtcEngine = AgoraRtcEngine;
    this.published = false;
    this.localUid = 0;
    this.joined = false;
    this.shared = false;
    this.rid = '';
    this.bus = new EventEmitter();
  }

  private isLocal(uid: number) {
    return this.localUid === uid;
  }

  createStream ({streamID, microphoneId, cameraId, speakerId, speakerVolume}: ElectronStreamSpec) {
    if (microphoneId) {
      const res = this.rtcEngine.setAudioRecordingDevice(microphoneId);
      res !== 0 && console.warn(`[createStream] set microphone: ${microphoneId} failed`);
    }

    if (cameraId) {
      const res = this.rtcEngine.setVideoDevice(cameraId);
      res !== 0 && console.warn(`[createStream] set cameraId: ${cameraId} failed`);
    }

    if (speakerId) {
      const res = this.rtcEngine.setAudioPlaybackDevice(speakerId);
      res !== 0 && console.warn(`[creaetStream] set speakerId: ${speakerId}`);
    }

    if (speakerVolume) {
      const res = this.rtcEngine.setAudioPlaybackVolume(speakerVolume);
      res !== 0 && console.warn(`[creaetStream] set setAudioPlaybackVolume: ${speakerVolume}`);
    }

    return new AgoraElectronStream(streamID, streamID !== SHARE_ID ? StreamType.local : StreamType.localVideoSource);
  }

  private readonly events: string[] = [
    'joinedchannel',
    'userjoined',
    'removestream',
    'leavechannel',
    'audiodevicestatechanged',
    'videodevicestatechanged',
    'error',
    'executefailed',
    'rtcStats',
    'networkquality',
    'audioquality',
  ]

  joinChannel(uid: number, channel: string, dual: boolean): number {
    this.localUid = uid;
    this.rid = channel;
    const rtcEngine = this.rtcEngine;
    const events = [
      // 'joinedchannel',
      // 'userjoined',
      // 'removestream',
      'leavechannel',
      'error',
      'executefailed',
      'rtcStats',
      'networkquality',
      'audioquality',
    ]
    for (let event of events) {
      rtcEngine.on(event, (...args: any[]) => {
        this.bus.emit(event, ...args);
      })
    }
    rtcEngine.on('joinedchannel', (channel: string, uid: number) => {
      const stream = new AgoraElectronStream(uid, uid !== SHARE_ID ? StreamType.local : StreamType.localVideoSource);
      this.bus.emit('stream-published', {stream});
    })
    rtcEngine.on('userjoined', (uid: number) => {
      const stream = new AgoraElectronStream(uid, uid !== SHARE_ID ? StreamType.remote : StreamType.remoteVideoSource);
      this.bus.emit('stream-subscribed', {stream});
    })
    rtcEngine.on('removestream', (uid: number) => {
      this.bus.emit('stream-removed', {uid});
    })
    if (dual) {
      rtcEngine.enableDualStreamMode(true);
    }
    // default role is audience
    this.rtcEngine.setClientRole(2);
    let res = this.rtcEngine.joinChannel('', channel, '', this.localUid);
    if(res === 0) {
      this.joined = true;
    }
    return res;
  }

  play(uid: number, dom: Element, videosource?: boolean) {
    const rtcEngine = this.rtcEngine;
    const local = this.isLocal(uid);
    if (videosource) {
      if (local) {
        rtcEngine.setupLocalVideoSource(dom)
        rtcEngine.setupViewContentMode('videosource', 1);
        rtcEngine.setupViewContentMode(String(SHARE_ID), 1);
      } else {
        rtcEngine.subscribe(uid, dom)
        rtcEngine.setupViewContentMode('videosource', 1);
        rtcEngine.setupViewContentMode(String(SHARE_ID), 1);
      }
    } else {
      if (local) {
        this.rtcEngine.setupLocalVideo(dom);
      } else {
        this.rtcEngine.subscribe(uid, dom)
        this.rtcEngine.setupViewContentMode(uid, 1);
      }
    }
  }

  stop(uid: number, dom: Element) {
    this.rtcEngine.destroyRenderView(uid, dom, (err: any) => {console.warn(err.message)});
  }

  leave() {
    const result = this.rtcEngine.leaveChannel();
    this.joined = false;
    this.localUid = 0;
    this.rid = '';
    return result;
  }

  on(name: string, cb: (...args: any[]) => void) {
    this.bus.on(name, cb);
  }

  off(name: string, cb: (...args: any[]) => void) {
    this.bus.off(name, cb);
  }

  destroyClient() {
    for (let event of this.events) {
      this.rtcEngine.off(event, () => {});
    }
    this.bus.removeAllListeners();
  }

  getScreenShareWindows() {
    return this.rtcEngine.getScreenWindowsInfo()
      .map((item: any) => ({
        ownerName: item.ownerName,
        name: item.name,
        windowId: item.windowId,
        image: btoa(item.image)
      }));
  }

  async startScreenShare(windowId: number, rect = {x: 0, y: 0, width: 0, height: 0}, param = {width: 0, height: 0, bitrate: 500, frameRate: 15}): Promise<AgoraElectronStream> {
    console.log("[native] start screen share");
    const shareClient = this.rtcEngine;
    return new Promise((resolve, reject) => {
      shareClient.videoSourceInitialize(APP_ID);
      shareClient.videoSourceSetChannelProfile(1);
      shareClient.videoSourceEnableWebSdkInteroperability(true);
      // shareClient.setVideoRenderDimension(3, SHARE_ID, 1280, 960);
      shareClient.videoSourceSetVideoProfile(50, false);
      // to adjust render dimension to optimize performance
      console.log("[electron-debug] SHARE_ID", SHARE_ID);
      shareClient.videoSourceJoin(null, this.rid, '', SHARE_ID);
      shareClient.once('videoSourceJoinedSuccess', (uid: number) => {
        console.log("[electron-debug] videoSource Joined", uid);
        this.shared = true;
        // shareClient.startScreenCapture2(windowId, 15, rect, 0);
        shareClient.videoSourceStartScreenCaptureByWindow(windowId, {x: 0, y: 0, width: 0, height: 0}, {width: 0, height: 0, bitrate: 500, frameRate: 15});
        shareClient.startScreenCapturePreview();
        // shareClient.videoSourceSetVideoProfile(43, false);
        // shareClient.startScreenCapture2(windowId, 15, rect, 0);
        // shareClient.startScreenCapturePreview();
        const electronStream = new AgoraElectronStream(uid, StreamType.localVideoSource);
        resolve(electronStream);
        shareClient.off('videoSourceJoinedSuccess', () => {});
      });

      setTimeout(() => {
        reject();
      }, 5000);
    })
  }

  async stopScreenShare() {
    if (this.shared) {
      try {
        console.log("[native] stop screen share");
        this.rtcEngine.videoSourceLeave();
        this.rtcEngine.videoSourceRelease();
      } finally {
        this.shared = false;
      }
    }
  }

  exit () {
    this.leave();
    this.destroyClient();
  }

  publish() {
    this.published = true;
    const res = this.rtcEngine.setClientRole(1);
    return res;
  }

  unpublish() {
    this.published = false;
    const res = this.rtcEngine.setClientRole(2);
    return res;
  }
}

export const nativeRTCClient = new AgoraElectronClient();