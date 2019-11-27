import { BizError, ChatMessage, RoomType, User, ClassState, UserRole, Dialog } from './types';
import { List, Map } from 'immutable';
import GlobalStorage from './custom-storage';
import AgoraRTMClient from '../utils/agora-rtm-client';
import AgoraRTCClient from '../utils/agora-rtc-client';
import NetlessWhiteboardClient from '../utils/netless-whiteboard-client';

export interface RoomState {
  rid: string
  room: string
  hasPwd: number
  users: Map<string, User>
  type: RoomType
  whiteboardId: string
  sharedId: number
  muteChat: number
  classState: ClassState
}

export interface UserState {
  account: string
  id: string
  streamID: number
  hasPwd: number
  video: number
  audio: number
  chat: number
  role: UserRole
  whiteboardId: string
}

export interface MediaInfo {
  camera: number
  microphone: number
  speaker: number
  cameraId: string
  microphoneId: string
  speakerId: string
  speakerVolume: number
}

export interface GlobalState {
  loading: boolean
  errors: Map<string, BizError>
  rtmClient?: AgoraRTMClient
  rtcClient?: AgoraRTCClient
  shareClient?: AgoraRTCClient
  localStream?: any
  sharedStream?: any
  messages: List<ChatMessage>
  remoteStreams: Map<string, any>
  timerState?: number
  canPass: boolean
  whiteboard: {
    client?: NetlessWhiteboardClient
    state: string
    current: number
    total: number
  }
  indicators: {
    quality: string
    rtt: number
    cpu: number
  }
  mediaInfo: MediaInfo
  linkId: string
  screenSharing: boolean
}

export interface NoticeProps {
  reason: string
  text?: string
}

export interface ToastProps {
  message: string
  type: string
}

export interface UIState {
  dialog: Dialog
  apply: boolean
  notice: NoticeProps
  toast: ToastProps
}

export interface RootState {
  room: RoomState
  user: UserState
  global: GlobalState
  ui: UIState
};

export const defaultGlobalState: GlobalState = {
  loading: false,
  errors: Map<string, BizError>(),
  rtmClient: undefined,
  rtcClient: undefined,
  shareClient: undefined,
  messages: List<ChatMessage>(),
  timerState: undefined,
  localStream: undefined,
  sharedStream: undefined,
  remoteStreams: Map<string, any>(),
  canPass: Boolean(GlobalStorage.read('pass')),
  whiteboard: {
    state: '',
    client: undefined,
    current: 1,
    total: 1
  },
  mediaInfo: {
    camera: 0,
    microphone: 0,
    speaker: 0,
    cameraId: '',
    speakerId: '',
    microphoneId: '',
    speakerVolume: 100
  },
  screenSharing: false,
  indicators: {
    quality: 'unknown',
    rtt: 0,
    cpu: 0,
  },
  linkId: '',
}

export const defaultRoomState: RoomState = {
  rid: '',
  type: RoomType.OneToOne,
  room: '',
  hasPwd: 0,
  whiteboardId: '',
  sharedId: 0,
  muteChat: 0,
  users: Map<string, User>(),
  classState: ClassState.CLOSED,
}

export const defaultUserState: UserState = {
  account: '',
  id: '',
  streamID: 0,
  video: 1,
  audio: 1,
  chat: 1,
  hasPwd: 0,
  role: UserRole.none,
  whiteboardId: '',
}

export const defaultUIState: UIState = {
  dialog: {
    visible: false,
    type: '',
    desc: ''
  },
  apply: false,
  notice: {
    reason: '',
  },
  toast: {
    message: '',
    type: '',
  }
}