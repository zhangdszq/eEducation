import AgoraRTMClient from "../utils/agora-rtm-client";
import AgoraRTCClient from "../utils/agora-rtc-client";
import NetlessWhiteboardClient from '../utils/netless-whiteboard-client';
import { MediaInfo, ToastProps } from "./initialize-state";

export enum ActionType {
  LOADING,
  ADD_ME,
  REMOVE_ME,
  ADD_USER,
  REMOVE_USER,
  UPDATE_USER,
  CLEAR_USERS,
  ADD_MESSAGE,
  REMOVE_MESSAGE,
  CLEAR_MESSAGES,
  MUTE_AUDIO,
  MUTE_VIDEO,
  MUTE_CHAT,
  MUTE_ALL,
  UNMUTE_AUDIO,
  UNMUTE_VIDEO,
  UNMUTE_CHAT,
  UNMUTE_ALL,
  ADD_LOCAL_STREAM,
  REMOVE_LOCAL_STREAM,
  REMOVE_STREAM,
  CLEAR_STREAMS,
  ADD_RTC_CLIENT,
  REMOVE_RTC_CLIENT,
  ADD_SHARE_RTC_CLIENT,
  REMOVE_SHARE_RTC_CLIENT,
  ADD_RTM_CLIENT,
  REMOVE_RTM_CLIENT,
  UPDATE_CAN_PASS,
  TOGGLE_DIALOG,
  TOGGLE_CARD,
  ADD_CARD,
  REMOVE_CARD,
  ADD_DIALOG,
  REMOVE_DIALOG,
  UPDATE_CLASS_STATE,
  UPDATE_CHANNEL_ATTRS,
  UPDATE_TEACHER_UID,
  UPDATE_WHITEBOARD_UID,
  UPDATE_SHARED_UID,
  UPDATE_LINK_UID,
  UPDATE_WHITEBOARD_CONNECT_STATE,
  ADD_WHITEBOARD,
  REMOVE_WHITEBOARD,
  CLEAR_STATE,
  UPDATE_WHITEBOARD_PAGINATION,
  SAVE_MEDIA,
  ADD_REMOTE_STREAM,
  REMOVE_REMOTE_STREAM,
  ADD_SHARED_STREAM,
  REMOVE_SHARED_STREAM,
  UPDATE_LOCAL_MEDIA_STATE,
  ACCEPT_APPLY,
  UPDATE_SCREEN_SHARING,
  UPDATE_NETWORK_QUALITY,
  UPDATE_RTT,
  UPDATE_QUALITY,
  REMOVE_ALL_REMOTE_STREAMS,
  UPDATE_APPLY,
  NOTICE,
  ADD_TOAST,
}

export interface Dialog {
  visible: boolean
  type: string,
  desc: string
}

export enum ChannelMessageType {
  mute,
  unmute
}

export enum ChannelMediaResource {
  video = 'video',
  audio = 'audio',
  chat = 'chat',
  all = 'all'
}

export type ChannelMessage = {
  type: ChannelMessageType
  resource: ChannelMediaResource
}

export interface ChatMessage {
  account: string
  text: string
  ts: number
  id: string
}

export interface LoginInfo {
  id: string
  roomName: string
  userName: string
  role: UserRole
  roomType: RoomType
}

export interface TeacherInfo {
  uid: string
  account: string
  mute_chat: number
  shared_uid: number
  link_uid: number
  whiteboard_uid: string
  class_state: number
  video: number
  audio: number
  chat: number
}

export interface StudentInfo {
  uid: string
  account: string
  video: number
  audio: number
  chat: number
}

type RegisterAction =
  | {
    type: ActionType.ADD_ME
    payload: LoginInfo
  }
  | {
    type: ActionType.REMOVE_ME
  }

type RoomAction =
  | {
    type: ActionType.UPDATE_CLASS_STATE
  }
  | {
    type: ActionType.REMOVE_STREAM
    streamID: number
  }
  | {
    type: ActionType.ADD_LOCAL_STREAM
    stream: any
  }
  | {
    type: ActionType.REMOVE_LOCAL_STREAM
  }
  | {
    type: ActionType.ADD_SHARED_STREAM
    stream: any
  }
  | {
    type: ActionType.REMOVE_SHARED_STREAM
  }
  | {
    type: ActionType.ADD_REMOTE_STREAM
    stream: any
  }
  | {
    type: ActionType.REMOVE_REMOTE_STREAM
    streamID: number
  }
  | {
    type: ActionType.CLEAR_STREAMS
  } 
  | {
    type: ActionType.UPDATE_SCREEN_SHARING
    sharing: boolean
  }
  | {
    type: ActionType.REMOVE_ALL_REMOTE_STREAMS
  }
  | {
    type: ActionType.ADD_DIALOG
    dialog: Dialog
  }
  | {
    type: ActionType.REMOVE_DIALOG
  }
  | {
    type: ActionType.UPDATE_APPLY
    apply: boolean
  }
  | {
    type: ActionType.ADD_TOAST,
    toast: ToastProps
  }

type UserAction =
  | {
    type: ActionType.ADD_USER
    user: User
  }
  | {
    type: ActionType.REMOVE_USER
    user: User
  }
  | {
    type: ActionType.UPDATE_USER
    user: User
  }
  | {
    type: ActionType.CLEAR_USERS
  }

type ChannelAction =
  | {
    type: ActionType.ADD_MESSAGE
    message: ChatMessage
  }
  | {
    type: ActionType.CLEAR_MESSAGES
  }
  | {
    type: ActionType.UPDATE_CHANNEL_ATTRS
    attrs: {
      teacher: any
      students: any[]
      accounts: any[]
      room: any
    }
  }
  | {
    type: ActionType.UPDATE_TEACHER_UID
    uid: number
  }
  | {
    type: ActionType.UPDATE_WHITEBOARD_UID
    uid: string
  }
  | {
    type: ActionType.UPDATE_SHARED_UID
    uid: number
  }


type ClientAction =
  | {
    type: ActionType.ADD_RTM_CLIENT
    client: AgoraRTMClient
  }
  | {
    type: ActionType.REMOVE_RTM_CLIENT
  }
  | {
    type: ActionType.ADD_RTC_CLIENT
    client: AgoraRTCClient
  }
  | {
    type: ActionType.REMOVE_RTC_CLIENT
  }
  | {
    type: ActionType.ADD_SHARE_RTC_CLIENT
    client: AgoraRTCClient
  }
  | {
    type: ActionType.REMOVE_SHARE_RTC_CLIENT
  } | 
  {
    type: ActionType.SAVE_MEDIA
    media: MediaInfo
  }
  | {
    type: ActionType.UPDATE_LOCAL_MEDIA_STATE
    mediaState: {
      key: string
      val: number
    }
    peerId: string
  }
  | {
    type: ActionType.UPDATE_LINK_UID
    peerId: string
  }
  | {
    type: ActionType.ACCEPT_APPLY
    peerId: string
  }
  | {
    type: ActionType.UPDATE_RTT
    rtt: number
  }
  | {
    type: ActionType.UPDATE_QUALITY
    quality: string
  }
  | {
    type: ActionType.NOTICE
    reason: string
    text?: string
  }


type GlobalAction = | {
  type: ActionType.LOADING
  payload: boolean
} | {
  type: ActionType.UPDATE_CAN_PASS
  pass: boolean
} | {
  type: ActionType.CLEAR_STATE
}

type WhiteboardAction = 
| {
  type: ActionType.ADD_WHITEBOARD
  client: NetlessWhiteboardClient
}
| {
  type: ActionType.REMOVE_WHITEBOARD
}
| {
  type: ActionType.UPDATE_WHITEBOARD_CONNECT_STATE
  state: string
}
| {
  type: ActionType.UPDATE_WHITEBOARD_PAGINATION
  current: number
  total: number
}

export type RootAction =
  | GlobalAction
  | RoomAction
  | UserAction
  | RegisterAction
  | ClientAction
  | ChannelAction
  | WhiteboardAction

export interface User {
  role: string
  account: string
  id: string
  video: number
  audio: number
  chat: number
};

export type UserId = string;

export enum RoomType {
  OneToOne = 0,
  SmallClass = 1,
  BigClass = 2
};

export enum ClassState {
  CLOSED = 0,
  STARTED = 1
}

export interface AgoraStream {
  id: string
  streamID: number
  local: boolean
  account?: string
  stream: any
  video?: boolean
  audio?: boolean
  playing?: boolean
}

export enum UserRole {
  none = '',
  teacher = 'teacher',
  student = 'student'
}

export interface BizError {
  title: string
  reason: string
}

export interface RoomDialog {
  visible: boolean
  type: string
  text: string
}