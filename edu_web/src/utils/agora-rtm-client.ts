import AgoraRtm from 'agora-rtm-sdk';
import EventEmitter from 'events';
import * as _ from 'lodash';
import { resolveRootState, UserAttrs, resolveMessage } from './helper';
import { RootState } from '../reducers/initialize-state';
import { UserRole } from '../reducers/types';

export enum RoomMessage {
  muteAudio = 101,
  unmuteAudio = 102,
  muteVideo = 103,
  unmuteVideo = 104,
  applyCoVideo = 105,
  acceptCoVideo = 106,
  rejectCoVideo = 107,
  cancelCoVideo = 108,
  muteChat = 109,
  unmuteChat = 110
}

export enum OperateType {
  mute = 'mute',
  unmute = 'unmute',
  apply = 'apply',
  accept = 'accept',
  reject = 'reject',
  cancel = 'cancel',
}

export enum Resource {
  audio = 'audio',
  video = 'video',
  chat = 'chat',
  coVideo = 'co-video'
}

export interface MessageBody {
  cmd: RoomMessage
  text?: string
}

function canJoin(args: {teacherInfo: {[key: string]: string}, role: string, channelCount: number, roomType: number}) {
  const result = {
    permitted: true,
    reason: ''
  }
  const {teacherInfo, roomType, channelCount, role} = args;
  const channelCountLimit = [2, 17, 17];

  let maximum = channelCountLimit[roomType];
  if (channelCount >= maximum) {
    result.permitted = false;
    result.reason = 'The number of students and teacher have reached upper limit';
  }

  console.log('[rtm-client] canJoin: args: ', args);
  if (role === 'teacher') {
    const isOnline = teacherInfo[Object.keys(teacherInfo)[0]];
    if (isOnline) {
      result.permitted = false;
      result.reason = 'Teacher already existed';
    }
    return result;
  }

  if (role === 'student') {
    // let studentMaximum = maximum-1;
    if (channelCount+1 > maximum) {
      result.permitted = false;
      result.reason = 'Student have reached upper limit';
      return result;
    }
  }

  console.log(" channelCount ", channelCount, maximum, result);

  return result;
}

export default class AgoraRTMClient {

  private _bus: EventEmitter;
  public _currentChannel: any;
  public _currentChannelName: string | any;
  private _channels: any;
  private _client: any;
  private _channelAttrsKey: string | any;

  public static _instance?: AgoraRTMClient = undefined;

  constructor (appId: string) {
    this._bus = new EventEmitter();
    this._channels = {};
    this._currentChannel = null;
    this._currentChannelName = null;
    this._channelAttrsKey = null;
    this.createClient(appId);
  }

  public removeAllListeners(): any {
    this._bus.removeAllListeners();
  }

  createClient (appId: string) {
    this._client = AgoraRtm.createInstance(appId, { enableLogUpload: false });
    AgoraRTMClient._instance = this._client;
  }

  destroy (): void {
    for (let channel of Object.keys(this._channels)) {
      this._channels[channel].removeAllListeners();
      this._channels[channel] = null;
    }
    this._currentChannel = null;
    this._currentChannelName = null;
    this._client.removeAllListeners();
    this._client = null;
    AgoraRTMClient._instance = undefined;
  }

  on(evtName: string, cb: (args: any) => void) {
    if (evtName === 'MessageFromPeer') {
      console.log(evtName, 'MessageFromPeer');
    }
    this._bus.on(evtName, cb);
  }

  async login (uid: string) {
    this._client.on("ConnectionStateChanged", (newState: string, reason: string) => {
      this._bus.emit("ConnectionStateChanged", {newState, reason});
    });
    this._client.on("MessageFromPeer", (message: any, peerId: string, props: any) => {
      this._bus.emit("MessageFromPeer", {message, peerId, props});
    });
    await this._client.login({uid});
    return
  }

  async logout () {
    await this._client.logout();
    return;
  }

  async join (channel: string) {
    const _channel = this._client.createChannel(channel);
    this._channels[channel] = _channel;
    this._currentChannel = this._channels[channel];
    this._currentChannelName = channel;
    _channel.on('ChannelMessage', (message: string, memberId: string) => {
      this._bus.emit('ChannelMessage', {message, memberId});
    });

    _channel.on('MemberJoined', (memberId: string) => {
      this._bus.emit('MemberJoined', memberId);
    });

    _channel.on('MemberLeft', (memberId: string) => {
      this._bus.emit('MemberLeft', memberId);
    });

    _channel.on('MemberCountUpdated', (count: number) => {
      this._bus.emit('MemberCountUpdated', count);
    })

    _channel.on('AttributesUpdated', (attributes: any) => {
      this._bus.emit('AttributesUpdated', attributes);
    });
    await _channel.join();
    return;
  }

  async leave (channel: string) {
    await this._channels[channel].leave();
  }

  async exit(channel: string) {
    if (this._channelAttrsKey) {
      await this.deleteChannelAttributesByKey();
    }
    await this.leave(channel);
    await this.logout();
  }

  async sendChannelMessage(msg: string) {
    return this._currentChannel.sendMessage({ text: msg });
  }

  async updateChannelAttrs(store: RootState, attrs: any) {
    const key = store.user.role === UserRole.teacher ? 'teacher' : store.user.id
    const userAttrs: UserAttrs = resolveRootState(store);
    return this.updateChannelAttrsByKey(key, {
      [`${key}`]: {
        ...userAttrs,
        ...attrs,
      }
    })
  }

  async updateChannelAttrsByKey (key: string, attrs: any) {
    this._channelAttrsKey = key;
    const channelAttributes: {[key: string]: string} = {}
    if (attrs[this._channelAttrsKey]) {
      // const channelAttrsValue = resolveChannelAttrsByKey(this._channelAttrsKey, attrs[this._channelAttrsKey]);
      channelAttributes[key] = JSON.stringify(attrs[key]);
      // channelAttributes[this._channelAttrsKey] = JSON.stringify(channelAttrsValue);
    }

    console.log("[rtm-client] updateChannelAttrsByKey ", attrs, " key ", key, channelAttributes);
    await this._client.addOrUpdateChannelAttributes(
      this._currentChannelName,
      channelAttributes,
      {enableNotificationToChannelMembers: true});
  }

  async deleteChannelAttributesByKey() {
    await this._client.deleteChannelAttributesByKeys(
      this._currentChannelName,
      [this._channelAttrsKey],
      {enableNotificationToChannelMembers: true}
    );
    console.log("do delete");
    this._channelAttrsKey = null;
    return;
  }

  async getChannelAttrs (): Promise<string> {
    let json = await this._client.getChannelAttributes(this._currentChannelName);
    return JSON.stringify(json);
  }

  async updateRoomAttrs(store: {userAttrs: any, teacher: any, whiteboard: any}) {
    const {userAttrs, teacher, whiteboard} = store;
    let channelAttrs: any = {};
    let updateKey = 'teacher';
    if (userAttrs.role === 'teacher') {
      channelAttrs.teacher = {
        account: userAttrs.account,
        role: userAttrs.role,
        uid: userAttrs.uid,
        ...teacher,
      }
      if (whiteboard.uid !== '') {
        channelAttrs.teacher.whiteboard_uid = whiteboard.uid;
      }
    } else {
      updateKey = `${userAttrs.uid}`;
      channelAttrs[userAttrs.uid] = {
        ...userAttrs
      }
    }
    await this.updateChannelAttrsByKey(updateKey, channelAttrs);
  }

  async getChannelMemberCount(ids: string[]) {
    return this._client.getChannelMemberCount(ids);
  }

  async queryTeacher(channelAttrs: string) {
    let teacherAttrs = _.get(channelAttrs, 'teacher.value')
    let results = {};
    if (teacherAttrs) {
      const teacherUid = `${JSON.parse(teacherAttrs).uid}`;
      if (teacherUid) results = await this._client.queryPeersOnlineStatus([teacherUid]);
    }
    return results;
  }

  async loginAndJoin({roomType, role, id, room}: {roomType: number, role: string, id: string, room: string}, pass: boolean) {
    await this.login(id);
    const channelMemberCount = await this.getChannelMemberCount([room]);
    const channelCount = channelMemberCount[room];
    console.log(" channelMemberCount ", channelMemberCount);
    let channelAttrs = await this._client.getChannelAttributes(room);
    const teacherInfo = await this.queryTeacher(channelAttrs); 
    this._channelAttrsKey = role === 'teacher' ? 'teacher' : id;
    const argsJoin = {
      channelCount,
      teacherInfo,
      role,
      roomType};
    const result = pass === false ? canJoin(argsJoin) : {permitted: true, reason: ''};
    if (result.permitted) {
      await this.join(room);
      return JSON.stringify(channelAttrs);
    }
    await this.logout();
    throw {
      type: 'not_permitted',
      reason: result.reason
    }
  }

  async sendPeerMessage(peerId: string, body: MessageBody) {
    resolveMessage(peerId, body);
    console.log("[rtm-client] send peer message ", peerId, JSON.stringify(body));
    let result = await this._client.sendMessageToPeer({text: JSON.stringify(body)}, peerId);
    return result.hasPeerReceived;
  }
}