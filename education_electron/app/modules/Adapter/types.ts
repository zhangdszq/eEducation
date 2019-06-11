

import { VIDEO_PROFILE_TYPE, VideoContentHint } from 'agora-electron-sdk/types/Api/native_type';

export enum VideoProfiles {
  LOW = VIDEO_PROFILE_TYPE.VIDEO_PROFILE_LANDSCAPE_180P_4,
  STANDARD = VIDEO_PROFILE_TYPE.VIDEO_PROFILE_LANDSCAPE_480P,
  HIGH = VIDEO_PROFILE_TYPE.VIDEO_PROFILE_LANDSCAPE_720P
}

export enum Mode {
  LIVE = 'live',
  RTC = 'rtc'
}

export enum ClientRole {
  AUDIENCE = 0,
  STUDENT = 1,
  TEACHER = 2
}

export interface RTCEngineConfig {
  channel: string;
  streamId: number
  role: ClientRole;

  // cameraId?: string;
  // microphoneId?: string;
  // videoProfile?: VideoProfiles;
  mode?: Mode;
  shareId?: number;

  [propName: string]: any;
}

export interface SignalConfig {
  channel: string;
  uid: string;
  streamId: number
  name: string;
  role: ClientRole;
}

export type AdapterConfig = SignalConfig & RTCEngineConfig

export interface UserAttr {
  role: ClientRole;
  name: string;
  streamId: number;
  [props: string]: string | number;
}

export interface ChannelAttr {
  isSharing: number;
  isRecording: number;
  shareId: number;
  whiteboardId: string;
  teacherId: string;
  [props: string]: string | number;
}
