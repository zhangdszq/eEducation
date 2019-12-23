import { platform } from './../utils/platform';
import { AgoraElectronClient } from './../utils/agora-electron-client';
import { ChatMessage, AgoraStream } from '../utils/types';
import {Subject} from 'rxjs';
import {Map, Set, List} from 'immutable';
import AgoraRTMClient, { RoomMessage } from '../utils/agora-rtm-client';
import {globalStore} from './global';
import AgoraWebClient from '../utils/agora-rtc-client';
import {get} from 'lodash';
import { isElectron } from '../utils/platform';
import GlobalStorage from '../utils/custom-storage';
import { whiteboard } from './whiteboard';

function canJoin({onlineStatus, roomType, channelCount, role}: {onlineStatus: any, role: string, channelCount: number, roomType: number}) {
  const result = {
    permitted: true,
    reason: ''
  }
  const channelCountLimit = [2, 17, 17];

  let maximum = channelCountLimit[roomType];
  if (channelCount >= maximum) {
    result.permitted = false;
    result.reason = 'The number of students and teacher have reached upper limit';
    return result;
  }

  const teacher = get(onlineStatus, 'teacher', false);
  const totalCount: number = get(onlineStatus, 'totalCount', 0);

  console.log("teacher, totalCount", teacher, totalCount);
  console.log(" channelCount ", channelCount, maximum, result);


  if (role === 'teacher') {
    const isOnline = teacher;
    if (isOnline) {
      result.permitted = false;
      result.reason = 'Teacher already existed';
      return result;
    }
  }

  if (role === 'student') {
    if (totalCount+1 > maximum) {
      result.permitted = false;
      result.reason = 'Student have reached upper limit';
      return result;
    }
  }

  return result;
}


export interface AgoraUser {
  uid: string
  account: string
  role: string
  video: number
  audio: number
  chat: number
  boardId: string // whiteboard_uuid
  sharedId: number // shared_uid
  linkId: number // link_uid
}

export interface ClassState {
  rid: string
  roomName: string
  teacherId: string
  roomType: number
  boardId: string // whiteboard_uuid
  sharedId: number // shared_uid
  linkId: number // link_uid
  courseState: number 
  muteChat: number
}

type RtcState = {
  published: boolean
  joined: boolean
  users: Set<number>
  shared: boolean
  localStream: AgoraMediaStream | null
  localSharedStream: AgoraMediaStream | null
  remoteStreams: Map<number, AgoraMediaStream>
}

export type MediaDeviceState = {
  microphoneId: string
  speakerId: string
  cameraId: string
  speakerVolume: number
  camera: number
  microphone: number
  speaker: number
}

export type SessionInfo = {
  uid: string
  rid: string
  account: string
  roomName: string
  roomType: number
  role: string
}

export type RtmState = {
  joined: boolean
  memberCount: number
}

export type RoomState = {
  rtmLock: boolean
  me: AgoraUser
  users: Map<string, AgoraUser>
  course: ClassState
  applyUid: number
  rtc: RtcState
  rtm: RtmState
  mediaDevice: MediaDeviceState
  messages: List<ChatMessage>
}

export type AgoraMediaStream = {
  streamID: number
  stream?: any
}

export class RoomMedia {
  roomStore(payload: { uid: string; rid: string; role: string; roomName: string; roomType: number; video: number; audio: number; chat: number; account: string; token: string; boardId: string; linkId: number; sharedId: number; }, arg1: boolean) {
    throw new Error("Method not implemented.");
  }
  private subject: Subject<RoomState> | null;
  public state: RoomState;
  public rtmClient: AgoraRTMClient = new AgoraRTMClient();
  public rtcClient: AgoraWebClient | AgoraElectronClient = isElectron ? new AgoraElectronClient () : new AgoraWebClient();
  public readonly defaultState: RoomState = {
    rtmLock: false,
    me: {} as AgoraUser,
    users: Map<string, AgoraUser>(),
    applyUid: 0,
    rtm: {
      joined: false,
      memberCount: 0,
    },
    rtc: {
      published: false,
      joined: false,
      shared: false,
      users: Set<number>(),
      localStream: null,
      localSharedStream: null,
      remoteStreams: Map<number, AgoraMediaStream>(),
    },
    course: {
      teacherId: '',
      boardId: '',
      sharedId: 0,
      linkId: 0,
      courseState: 0,
      muteChat: 0,
      rid: '',
      roomName: '',
      roomType: 0,
    },
    mediaDevice: {
      microphoneId: '',
      speakerId: '',
      cameraId: '',
      speakerVolume: 100,
      camera: 0,
      speaker: 0,
      microphone: 0
    },
    messages: List<ChatMessage>(),
  }

  private applyLock: number = 0;

  public windowId: number = 0;
  private _attrs: any = {};

  constructor() {
    this.subject = null;
    this.state = this.defaultState;
  }

  initialize() {
    this.subject = new Subject<RoomState>();
    this.state = {
      ...this.defaultState,
      ...GlobalStorage.read('agora_room'),
    }
    this._attrs = {};
    this.applyLock = 0;
    this.subject.next(this.state);
  }

  get applyUid () {
    return this.applyLock;
  }

  subscribe(updateState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(updateState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this._attrs = {};
    this.subject = null;
  }

  commit (state: RoomState) {
    this.subject && this.subject.next(state);
  }

  updateState(rootState: RoomState) {
    this.state = {
      ...this.state,
      ...rootState,
    }
    this.commit(this.state);
  }

  isTeacher(peerId: string) {
    if (!peerId) return false;
    const user = this.state.users.get(peerId)
    if (!user) return false;
    if (user.role === 'teacher') return true;
    return false;
  }

  isStudent (peerId: string) {
    if (!peerId) return false;
    const user = this.state.users.get(peerId);
    if (!user) return false;
    if (user.role === 'student') return true;
    return false;
  }

  addLocalStream(stream: AgoraStream) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localStream: stream
      }
    }
    this.commit(this.state);
  }

  removeLocalStream() {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localStream: null,
        localSharedStream: null
      }
    }
    this.commit(this.state);
  }

  addLocalSharedStream(stream: any) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localSharedStream: stream
      }
    }
    this.commit(this.state);
  }

  removeLocalSharedStream() {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        localSharedStream: null
      }
    }
    this.commit(this.state);
  }

  addPeerUser(uid: number) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        users: this.state.rtc.users.add(uid),
      }
    }
    this.commit(this.state);
  }

  removePeerUser(uid: number) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        users: this.state.rtc.users.delete(uid),
      }
    }
    this.commit(this.state);
  }

  addRemoteStream(stream: AgoraStream) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        remoteStreams: this.state.rtc.remoteStreams.set(stream.streamID, stream)
      }
    }
    this.commit(this.state);
  }

  removeRemoteStream(uid: number) {
    const remoteStream = this.state.rtc.remoteStreams.get(uid);
    if (platform === 'web') {
      if (remoteStream && remoteStream.stream && remoteStream.stream.isPlaying) {
        remoteStream.stream.isPlaying() && remoteStream.stream.stop();
      }
    }


    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        remoteStreams: this.state.rtc.remoteStreams.delete(uid)
      }
    }
  }

  updateMemberCount(count: number) {
    this.state = {
      ...this.state,
      rtm: {
        ...this.state.rtm,
        memberCount: count,
      }
    }
    this.commit(this.state);
  }

  updateRtc(newState: any) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        ...newState,
      }
    }
    this.commit(this.state);
  }

  updateDevice(state: MediaDeviceState) {
    this.state = {
      ...this.state,
      mediaDevice: state
    }
    this.commit(this.state);
  }

  async handlePeerMessage(cmd: RoomMessage, peerId: string) {
    if (!peerId) return console.warn('state is not assigned');
    const myUid = this.state.me.uid;
    // student follow teacher peer message
    if (!this.isTeacher(myUid) && this.isTeacher(peerId)) {

      const me = this.state.me;
      switch(cmd) {
        case RoomMessage.muteChat: {
          return await this.updateMe({...me, chat: 0});
        }
        case RoomMessage.muteAudio: {
          return await this.updateMe({...me, audio: 0});
        }
        case RoomMessage.muteVideo: {
          return await this.updateMe({...me, video: 0});
        }
        case RoomMessage.unmuteAudio: {
          return await this.updateMe({...me, audio: 1});
        }
        case RoomMessage.unmuteVideo: {
          return await this.updateMe({...me, video: 1});
        }
        case RoomMessage.unmuteChat: {
          return await this.updateMe({...me, chat: 1});
        }
        case RoomMessage.acceptCoVideo: {
          globalStore.showToast({
            type: 'co-video',
            message: 'teacher already accept co-video'
          });
          return;
        }
        case RoomMessage.rejectCoVideo: {
          globalStore.showToast({
            type: 'co-video',
            message: 'teacher already rejected co-video'
          });
          return;
        }
        case RoomMessage.cancelCoVideo: {
          globalStore.showToast({
            type: 'co-video',
            message: 'teacher already canceled co-video'
          });
          return;
        }
        default:
      }
      return;
    }

    // when i m teacher & received student message
    if (this.isTeacher(myUid) && this.isStudent(peerId)) {
      switch(cmd) {
        case RoomMessage.applyCoVideo: {
          // WARN: LOCK
          if (this.state.course.linkId) {
            return console.warn('already received apply id: ', this.applyLock);
          }
          const applyUser = roomStore.state.users.get(`${peerId}`);
          if (applyUser) {
            this.applyLock = +peerId;
            console.log("applyUid: ", this.applyLock);
            this.state = {
              ...this.state,
              applyUid: this.applyLock,
            }
            this.commit(this.state);
            globalStore.showNotice({
              reason: 'peer_hands_up',
              text: `"${applyUser.account}" wants to interact with you`
            });
          }
          return;
        }
        case RoomMessage.cancelCoVideo: {
          // WARN: LOCK
          if (!this.applyLock) return;
          roomStore.updateCourseLinkUid(0).then(() => {
          }).catch(console.warn);

          globalStore.showToast({
            type: 'co-video',
            message: 'student canceled co-video'
          });
          return;
        }
        default:
      }
      return;
    }
  }

  async mute(uid: string, type: string) {
    const me = this.state.me;
    if (me.uid === `${uid}`) {
      if (type === 'audio') {
        await this.updateAttrsBy(me.uid, {
          audio: 0
        });
      }
      if (type === 'video') {
        await this.updateAttrsBy(me.uid, {
          video: 0
        });
      }
      if (type === 'chat') {
        await this.updateAttrsBy(me.uid, {
          chat: 0
        });
      }
    }
    else if (me.role === 'teacher') {
      if (type === 'audio') {
        await this.rtmClient.sendPeerMessage(`${uid}`, {cmd: RoomMessage.muteAudio});
      }
      if (type === 'video') {
        await this.rtmClient.sendPeerMessage(`${uid}`, {cmd: RoomMessage.muteVideo});
      }
      if (type === 'chat') {
        await this.rtmClient.sendPeerMessage(`${uid}`, {cmd: RoomMessage.muteChat});
      }
    }
  }

  async unmute(uid: string, type: string) {
    const me = this.state.me;
    if (me.uid === `${uid}`) {
      if (type === 'audio') {
        await this.updateAttrsBy(me.uid, {
          audio: 1
        });
      }
      if (type === 'video') {
        await this.updateAttrsBy(me.uid, {
          video: 1
        });
      }
      if (type === 'chat') {
        await this.updateAttrsBy(me.uid, {
          chat: 1
        });
      }
    }
    else if (me.role === 'teacher') {
      if (type === 'audio') {
        await this.rtmClient.sendPeerMessage(`${uid}`, {cmd: RoomMessage.unmuteAudio});
      }
      if (type === 'video') {
        await this.rtmClient.sendPeerMessage(`${uid}`, {cmd: RoomMessage.unmuteVideo});
      }
      if (type === 'chat') {
        await this.rtmClient.sendPeerMessage(`${uid}`, {cmd: RoomMessage.unmuteChat});
      }
    }
  }

  async loginAndJoin(payload: any, pass: boolean = false) {
    const {roomType, role, uid, rid, token } = payload;
    await this.rtmClient.login(uid, token);
    const channelMemberCount = await this.rtmClient.getChannelMemberCount([rid]);
    const channelCount = channelMemberCount[rid];
    let accounts = await this.rtmClient.getChannelAttributeBy(rid);
    const onlineStatus = await this.rtmClient.queryOnlineStatusBy(accounts);
    const argsJoin = {
      channelCount,
      onlineStatus,
      role,
      accounts,
      roomType
    };
    const result = pass === false ? canJoin(argsJoin) : {permitted: true, reason: ''};
    if (result.permitted) {
      let res = await this.rtmClient.join(rid);
      this.state = {
        ...this.state,
        rtm: {
          ...this.state.rtm,
          joined: true
        }
      }
      await this.updateMe(payload);
      this.commit(this.state);
      return;
    }
    await this.rtmClient.logout();
    throw {
      type: 'not_permitted',
      reason: result.reason
    }
  }

  setRTCJoined(joined: boolean) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        joined
      }
    }
    this.commit(this.state);
  }

  async updateCourseLinkUid(linkId: number) {
    const me = this.state.me;
    console.log("me: link_uid", me, linkId);
    let res = await this.updateAttrsBy(me.uid, {
      link_uid: linkId
    })
    // let res = await this.updateMe({...me, linkId: linkId});
    this.applyLock = linkId;
    return res;
  }

  updateChannelMessage(msg: ChatMessage) {
    this.state = {
      ...this.state,
      messages: this.state.messages.push(msg)
    };

    this.commit(this.state);
  }

  async updateAttrsBy(uid: string, attr: any) {
    console.log("updateAttrsBy#attrs ", attr);
    const user = this.state.users.get(uid);
    if (!user) return;
    const key = user.role === 'teacher' ? 'teacher' : uid;
    const attrs = {
      uid: user.uid,
      whiteboard_uid: user.boardId,
      link_uid: user.linkId,
      shared_uid: user.sharedId,
      account: user.account,
      video: user.video,
      audio: user.audio,
      chat: user.chat,
    }
    if (user.role === 'teacher') {
      Object.assign(attrs, {
        mute_chat: this.state.course.muteChat,
        class_state: this.state.course.courseState,
        whiteboard_uid: this.state.course.boardId,
        link_uid: this.state.course.linkId,
        shared_uid: this.state.course.sharedId,
      })
    }
    if (attr) {
      Object.assign(attrs, attr);
    }
    console.log("updateAttrsBy#attrs 2 ", attrs);
    let res = await this.rtmClient.updateChannelAttrsByKey(key, attrs);
    return res;
  }

  async updateMe(user: any) {
    const {role, uid, account, rid, video, audio, chat, boardId, linkId, sharedId, muteChat} = user;
    const key = role === 'teacher' ? 'teacher' : uid;
    const me = this.state.me;
    const attrs = {
      uid: me.uid,
      account: me.account,
      chat: me.chat,
      video: me.video,
      audio: me.audio
    }
    Object.assign(attrs, {
      uid,
      account,
      video,
      audio,
      chat,
      whiteboard_uid: boardId,
      link_uid: linkId,
      shared_uid: sharedId
    });
    if (role === 'teacher') {
      const class_state = get(user, 'courseState', this.state.course.courseState);
      const whiteboard_uid = get(user, 'boardId', this.state.course.boardId);
      const mute_chat = get(user, 'muteChat', this.state.course.muteChat);
      const shared_uid = get(user, 'sharedId', this.state.course.sharedId);
      const link_uid = get(user, 'linkId', this.state.course.linkId);
      Object.assign(attrs, {
       mute_chat,
       class_state,
       whiteboard_uid,
       link_uid,
       shared_uid,
      })
    }
    console.log("update channel Attrs by key >>>> ", key, " attrs " , attrs);
    let res = await this.rtmClient.updateChannelAttrsByKey(key, attrs);
    return res;
  }

  updateRoomAttrs ({teacher, accounts, room}: any) {
    console.log("[rtm-attributes], room:  ", room, " teacher: ", teacher, "accounts ", accounts);
    const users = accounts.reduce((acc: Map<string, AgoraUser>, it: any) => {
      return acc.set(it.uid, {
        role: it.role,
        account: it.account,
        uid: it.uid,
        video: it.video,
        audio: it.audio,
        chat: it.chat,
        boardId: it.whiteboard_uid,
        sharedId: it.shared_uid,
        linkId: it.link_uid
      });
    }, Map<string, AgoraUser>());

    const me = this.state.me;

    if (users.get(me.uid)) {
      Object.assign(me, users.get(me.uid));
    }

    if (me.role === 'teacher') {
      Object.assign(me, {
        linkId: room.link_uid,
        boardId: room.whiteboard_uid,
      })
    }

    const newClassState: ClassState = {} as ClassState;
    Object.assign(newClassState, {
      teacherId: get(teacher, 'uid', 0),
      linkId: room.link_uid,
      boardId: room.whiteboard_uid,
      courseState: room.class_state,
      muteChat: room.mute_chat,
    })

    
    console.log("... me", this.state.me);
    console.log("... this.state.me", me);

    this.state = {
      ...this.state,
      users,
      me: {
        ...this.state.me,
        ...me,
      },
      course: {
        ...this.state.course,
        ...newClassState
      }
    }
    this.commit(this.state);
  }

  updateSessionInfo (info: any) {
    this.state = {
      ...this.state,
      course: {
        ...this.state.course,
        rid: info.rid,
        roomName: info.roomName,
        roomType: info.roomType
      },
      me: {
        ...this.state.me,
        account: info.account,
        uid: info.uid,
        role: info.role,
        video: info.video,
        audio: info.audio,
        chat: info.chat,
        linkId: info.linkId,
        sharedId: info.sharedId,
        boardId: info.boardId,
      }
    }
    this.commit(this.state);
  }

  async exitAll() {
    try {
      await this.rtmClient.exit();
      await this.rtcClient.exit();
    } catch(err) {
      console.warn(err);
    } finally {
      this.state = {
        ...this.defaultState
      }
      this.commit(this.state);
      console.log("reset room>>>");
      GlobalStorage.clear('agora_room');
    }
  }

  setScreenShare(shared: boolean) {
    this.state = {
      ...this.state,
      rtc: {
        ...this.state.rtc,
        shared,
      }
    }
    this.commit(this.state);
  }
}

export const roomStore = new RoomMedia();

//@ts-ignore
window.roomStore = roomStore;