import EventEmitter from 'events';
import AgoraRTC from 'agora-rtc-sdk';
import { MediaInfo } from '../reducers/initialize-state';

export interface AgoraStreamSpec {
  streamID: number
  video: boolean
  audio: boolean
  mirror?: boolean
  screen?: boolean
  microphoneId?: string
  cameraId?: string
  audioOutput?: {
    volume: number
    deviceId: string // speakerId
  }
}

const streamEvents: string[] = [
  "accessAllowed", 
  "accessDenied",
  "stopScreenSharing",
  "videoTrackEnded",
  "audioTrackEnded",
  "player-status-changed"
];

const clientEvents: string[] = [
  'stream-published',
  'stream-added',
  'stream-removed',
  'stream-subscribed',
  'peer-online',
  'peer-leave',
  'error',
  'network-type-changed',
  'network-quality',
  'exception',
]

export const APP_ID = process.env.REACT_APP_AGORA_APP_ID as string;
export const APP_TOKEN = process.env.REACT_APP_AGORA_APP_TOKEN as string;
export const ENABLE_LOG = process.env.REACT_APP_AGORA_LOG as string === "true";
export const SHARE_ID = 7;
export default class AgoraRTCClient {

  private _bus: EventEmitter;
  public _client: any;
  private _localStream: any;
  private _internalTimer: NodeJS.Timeout | any;
  public _init: boolean;
  private streamID: any;
  public _published: boolean;
  private _channelName: string;

  constructor () {
    this._bus = new EventEmitter();
    this._init = false;
    this._internalTimer = null;
    this._client = AgoraRTC.createClient({mode: 'live', codec: 'h264'});
    this.streamID = null;
    this._published = false;
    this._channelName = '';
  }

  initClient (appId: string) {
    return new Promise((resolve, reject) => {
      this._init === false && this._client.init(appId, () => {
        this._init = true;
        console.log('[rtc-client] init Client', this._init);
        this._internalTimer = setInterval(() => {
          this._client.getTransportStats((stats: any) => {
            const RTT = stats.RTT ? stats.RTT : 0;
            this._bus.emit('watch-rtt', RTT);
          });
        }, 100);
        resolve()
      }, reject);
      for (let evtName of clientEvents) {
        this._client.on(evtName, (evt: any) => {
          this._bus.emit(evtName, evt);
        })
      }
    })
  }

  on(evtName: string, cb: (args: any) => void) {
    this._bus.on(evtName, cb);
  }

  removeAllListeners() {
    if (this._client) {
      for (let evtName of clientEvents) {
        this._client.off(evtName, () => {});
      }
    }
    this._bus.removeAllListeners();
  }

  async publish() {
    return new Promise((resolve, reject) => {
      if (this._published) {
        return resolve();
      }
      this._client.publish(this._localStream, (err: any) => {
        reject(err);
      })
      setTimeout(() => {
        resolve();
        this._published = true;
      }, 300);
    })
  }

  async unpublish() {
    return new Promise((resolve, reject) => {
      if (!this._published) {
        return resolve();
      }
      this._client.unpublish(this._localStream, (err: any) => {
        reject(err);
      })
      setTimeout(() => {
        resolve();
        this._published = false;
      }, 300);
    })
  }

  setRemoteVideoStreamType(stream: any, streamType: number) {
    this._client.setRemoteVideoStreamType(stream, streamType);
  }

  async enableDualStream() {
    return new Promise((resolve, reject) => {
      this._client.enableDualStream(resolve, reject);
    });
  }

  async joinChannel(streamID: number, channel: string, dualStream: boolean) {
    await this.join(streamID, channel);
    dualStream && await this.enableDualStream();
    this._channelName = channel;
    this.streamID = streamID;
  }

  async publishStream(data: any) {
    const streamID = this.streamID;
    await this.createStream({
      ...data,
      streamID
    });
    await this.publish();
  }

  async unpublishStream() {
    await this.unpublish();
    this.clearLocalStream();
  }

  clearLocalStream () {
    if(this._localStream) {
      // for (let stream of streamEvents) {
      //   this._localStream.off(stream, () => {});
      // }
      if (this._localStream.isPlaying()) {
        this._localStream.stop();
      }
      this._localStream.close();
    }
    this._localStream = null;
  }

  async republishStream(data: any) {
    console.log("republishStream start ", data);
    await this.unpublish();
    this.clearLocalStream();
    await this.createStream({
      ...data,
      streamID: this.streamID,
      video: true,
      audio: true,
    });
    await this.publish();
    console.log("republishStream success", data);
  }

  async publishScreenShare(channel: string) {
    await this.initClient(APP_ID);
    console.log("do init rtc screen sharing client");
    await this.createStream({
      streamID: SHARE_ID,
      video: false,
      audio: true,
      screen: true
    });
    await this.join(SHARE_ID, channel);
    await this.publish();
  }

  join (uid: number, channel: string) {
    return new Promise((resolve, reject) => {
      this._client.join(null, channel, +uid, resolve, reject);
    })
  }

  setAudioOutput(speakerId: string) {
    return new Promise((resolve, reject) => {
      this._client.setAudioOutput(speakerId, resolve, reject);
    })
  }

  setAudioVolume(volume: number) {
    return new Promise((resolve, reject) => {
      this._client.setAudioVolume(volume);
    })
  }

  createStream(data: AgoraStreamSpec): Promise<any> {
    this._localStream = AgoraRTC.createStream({...data, mirror: false});
    return new Promise((resolve, reject) => {
      this._localStream.init(() => {
        for (let event of streamEvents) {
          this._localStream.on(event, (args: any[]) => {
            this._bus.emit(event, args);
          });
        }
        if (data.audioOutput && data.audioOutput.deviceId) {
          this.setAudioOutput(data.audioOutput.deviceId).then(() => {
            resolve(this._localStream);
          }).catch((err: any) => {
            reject(err);
          })
        }
        resolve(this._localStream);
      }, (err: any) => {
        reject(err);
      })
    });
  }

  leave () {
    return new Promise((resolve, reject) => {
      this._client.leave(resolve, reject);
    })
  }

  subscribe(stream: any) {
    this._client.subscribe(stream, {video: true, audio: true}, (err: any) => {
      console.log('[rtc-client] subscribe failed: ', JSON.stringify(err));
    });
  }

  destroy (): void {
    console.log('[rtc-client] destroy Client', this.streamID);
    this._internalTimer && clearInterval(this._internalTimer);
    this._internalTimer = null;
    this.removeAllListeners();
    if (this._localStream && this._localStream.isPlaying()) {
      this._localStream.stop();
    }
    this._localStream && this._localStream.close();
    this._localStream = null;
    this._init = false;
    this._channelName = '';
    this.streamID = 0;

  }

  destroyClient(): void {
    if (!this._client) {
      return 
    }
    for (let evtName of clientEvents) {
      this._client.off(evtName, () => {});
    }
    this._client = null;
  }

  async exit () {
    await this.leave();
  }

  async refreshInternal () {
    this._internalTimer && clearInterval(this._internalTimer);
    this._internalTimer = null;
    for (let evtName of clientEvents) {
      this._client.off(evtName, () => {});
    }
    if (this._localStream && this._localStream.isPlaying()) {
      this._localStream.stop();
    }
    this._localStream && this._localStream.close();
    this._localStream = null;
    this._init = false;
  }

  async refresh(data: MediaInfo, published: boolean) {
    const streamID = this.streamID;
    this.refreshInternal();
    await this.leave();
    // await this.prepareStream(data, this._channelName, published, false);
    published && await this.publish();
  }

  getDevices (): Promise<Device[]> {
    return new Promise((resolve, reject) => {
      AgoraRTC.getDevices((devices: any) => {
        const _devices: any[] = [];
        devices.map((item: any) => {
          _devices.push({deviceId: item.deviceId, kind: item.kind, label: item.label});
        })
        resolve(_devices);
      }, (err: any) => {
        reject(err);
      });
    })
  }

  static async initClient (): Promise<any> {
    const instance = new AgoraRTCClient();
    await instance.initClient(APP_ID);
    return instance;
  }

  static async createShareScreen(channel: string): Promise<any> {
    const instance = new AgoraRTCClient();
    await instance.initClient(APP_ID);
    return instance;
  }

  static async getDevices (): Promise<Device[]> {
    const engine = await this.initClient();
    await engine.createStream({
      streamID: 1,
      audio: true,
      video: true,
      microphoneId: '',
      cameraId: ''
    });
    setTimeout(() => {
      engine._localStream.close();
    }, 80);

    return engine.getDevices();
  }
}