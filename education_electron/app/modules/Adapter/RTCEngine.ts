/**
 * RTCEngine for e-Education based on Agora Web SDK 2.5.1 which
 * provide methods for holding a class without concentration
 * on original SDK.
 */

import AgoraRtcEngine from 'agora-electron-sdk';
import {RTCEngineConfig, Mode, VideoProfiles, ClientRole} from './types';
import { createLogger } from "../../utils";

const rtcEngineLog = createLogger("[RTCEngine]", "#fff", "#13c2c2", true);

class RTCEngine {
  private appId: string;
  public config: RTCEngineConfig;
  public client: AgoraRtcEngine;
  public isSharing: boolean;

  public constructor(appId: string) {
    this.client = new AgoraRtcEngine();
    this.appId = appId;
    this.config = {
      channel: "",
      shareId: 2,
      mode: Mode.LIVE,
      role: ClientRole.STUDENT,
      streamId: -1
    };
  }

  public initialize = (config: RTCEngineConfig) => {
    if (!this.client) {
      this.client = new AgoraRtcEngine();
    }
    this.config = Object.assign({}, this.config, config);
    rtcEngineLog(
      `RTCEngine initialized with config ${JSON.stringify(this.config)}`
    );
    this.client.initialize(this.appId);
    const client = this.client
    const isAudience = this.config.role === ClientRole.AUDIENCE
    client.setChannelProfile(1)
    client.setClientRole(isAudience ? 2 : 1, '');
    client.enableWebSdkInteroperability(true)
    // turn on UC mode introduced since 2.3.3
    client.setParameters('{"rtc.force_unified_communication_mode":true}')
    // no longer needed in v2.4
    // client.setAudioProfile(0, 1);
    // client.setParameters('{"che.audio.live_for_comm":true}');
    // client.setParameters('{"che.audio.enable.agc":false}');
    // client.setParameters('{"che.video.moreFecSchemeEnable":true}');
    if (!isAudience) {
      client.enableDualStreamMode(true);
      client.enableVideo();
      client.enableLocalVideo(true);
    }
  };

  public release() {
    if (this.client) {
      this.stopScreenShare()
      this.client.release()
      this.client = null;
    }
  }

  public join = (
    token?: string | null,
    constraints?: {
      videoProfile: VideoProfiles;
    }
  ) => {
    const { videoProfile = VideoProfiles.STANDARD } =
      constraints || {};
    // get related state
    const { channel, streamId, role } = this.config;

    const isAudience = role === ClientRole.AUDIENCE;

    if (!isAudience) {
      this.client.setVideoProfile(videoProfile as any, false);
    }
    this.client.joinChannel(token, channel, '', streamId)
  };

  public leave = () => {
    if (this.client) {
      this.client.leaveChannel();
      this.client.removeAllListeners();
    }
  };

  public startScreenShare = (token: string | null, windowId: number, rect = {x: 0, y: 0, width: 0, height: 0}, param = {width: 0, height: 0, bitrate: 500, frameRate: 15}) => {
    return new Promise((resolve, reject) => {
      this.client.videoSourceInitialize(this.appId);
      this.client.videoSourceSetChannelProfile(1);
      this.client.videoSourceEnableWebSdkInteroperability(true)
      // to adjust render dimension to optimize performance
      this.client.setVideoRenderDimension(3, this.config.shareId, 1280, 960);
      this.client.videoSourceJoin(token, this.config.channel, '', this.config.shareId);
      this.client.once('videoSourceJoinedSuccess', (uid: number) => {
        this.isSharing = true;
        this.client.videosourceStartScreenCaptureByWindow(windowId, rect, param);
        this.client.videoSourceSetVideoProfile(50, false);
        this.client.startScreenCapturePreview();
        resolve(uid)
      });
    })
  };

  public stopScreenShare = () => {
    if (this.isSharing) {
      try {
        this.client.videoSourceLeave();
        this.client.videoSourceRelease();
      } finally {
        this.isSharing = false;
      }
    }
  };
}

export default RTCEngine;
