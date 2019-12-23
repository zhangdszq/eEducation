import { RoomMessage } from './agora-rtm-client';
import * as _ from 'lodash';
import OSS from 'ali-oss';

export interface OSSConfig {
  accessKeyId: string,
  accessKeySecret: string,
  region: string,
  bucket: string,
  folder: string,
}

export const ossConfig: OSSConfig = {
  "accessKeyId": process.env.REACT_APP_AGORA_OSS_BUCKET_KEY as string,
  "accessKeySecret": process.env.REACT_APP_AGORA_OSS_BUCKET_SECRET as string,
  "bucket": process.env.REACT_APP_AGORA_OSS_BUCKET_NAME as string,
  "region": process.env.REACT_APP_AGORA_OSS_BUCKET_REGION as string,
  "folder": process.env.REACT_APP_AGORA_OSS_BUCKET_FOLDER as string
}

export const ossClient = new OSS(ossConfig);

console.log("[upload-btn] ", ossConfig, ossClient);

export function resolveMessage(peerId: string, { cmd, text }: { cmd: number, text?: string }) {
  let type = '';
  switch (cmd) {
    case RoomMessage.acceptCoVideo:
      type = 'accept co-video'
      break;
    case RoomMessage.rejectCoVideo:
      type = 'reject co-video'
      break;
    case RoomMessage.cancelCoVideo:
      type = 'cancel co-video'
      break;
    case RoomMessage.applyCoVideo:
      type = 'apply co-video'
      break;
    case RoomMessage.muteVideo:
      type = 'mute video'
      break;
    case RoomMessage.muteAudio:
      type = 'mute audio'
      break;
    case RoomMessage.unmuteAudio:
      type = 'unmute audio'
      break;
    case RoomMessage.unmuteVideo:
      type = 'unmute video'
      break;
    default:
      return console.warn(`[RoomMessage] unknown type, from peerId: ${peerId}`);
  }
  console.log(`[RoomMessage] [${type}] from peerId: ${peerId}`)
}

export interface UserAttrs {
  uid: string
  account: string
  role: string
  audio: number
  video: number
  chat: number
  whiteboard_uid?: string
  link_uid?: number
  shared_uid?: number
  mute_chat?: number
  class_state?: number
}

export function resolveMediaState(body: any) {
  const cmd: number = body.cmd;
  const mediaState = {
    key: 'unknown',
    val: -1,
  }
  switch (cmd) {
    case RoomMessage.muteVideo:
      mediaState.key = 'video'
      mediaState.val = 0
      break
    case RoomMessage.unmuteVideo:
      mediaState.key = 'video'
      mediaState.val = 1
      break
    case RoomMessage.muteAudio:
      mediaState.key = 'audio'
      mediaState.val = 0
      break
    case RoomMessage.unmuteAudio:
      mediaState.key = 'audio'
      mediaState.val = 1
      break
    case RoomMessage.muteChat:
      mediaState.key = 'chat'
      mediaState.val = 0
      break
    case RoomMessage.unmuteChat:
      mediaState.key = 'chat'
      mediaState.val = 1
      break
    default:
      console.warn("[rtm-message] unknown message protocol");
  }
  return mediaState;
}

export function genUid(): string {
  const id = +Date.now() % 1000000;
  return id.toString();
}

export function jsonParse(json: string) {
  try {
    return JSON.parse(json);
  } catch (err) {
    return {};
  }
}

export function resolvePeerMessage(text: string) {
  const body = jsonParse(text);
  return body;
}

export function resolveChannelAttrs(json: object) {
  const teacherJson = jsonParse(_.get(json, 'teacher.value'));
  const room: any = {
    class_state: 0,
    link_uid: 0,
    shared_uid: 0,
    mute_chat: 0,
    whiteboard_uid: 0
  }
  if (teacherJson) {
    for (let key of Object.keys(teacherJson)) {
      if (['class_state', 'link_uid', 'shared_uid', 'mute_chat', 'whiteboard_uid'].indexOf(key) !== -1
        && teacherJson[key] !== undefined
        && teacherJson[key] !== '') {
        room[key] = teacherJson[key];
      }
    }
  }
  const students = [];
  for (let key of Object.keys(json)) {
    if (key === 'teacher') continue;
    const student = jsonParse(_.get(json, `${key}.value`));
    if (student && Object.keys(student).length) {
      student.uid = key;
      students.push(student);
    }
  }
  const accounts = [];
  if (teacherJson && Object.keys(teacherJson).length) {
    accounts.push({
      role: 'teacher',
      account: teacherJson.account,
      uid: teacherJson.uid,
      video: +teacherJson.video,
      audio: +teacherJson.audio,
      chat: +teacherJson.chat,
      link_uid: teacherJson.link_uid,
      shared_uid: teacherJson.shared_uid,
      whiteboard_uid: teacherJson.whiteboard_uid,
    });
  }
  for (let student of students) {
    accounts.push({
      role: 'student',
      account: student.account,
      uid: student.uid,
      video: +student.video,
      audio: +student.audio,
      chat: +student.chat,
      link_uid: student.link_uid,
      shared_uid: student.shared_uid,
      whiteboard_uid: student.whiteboard_uid,
    });
  }
  return {
    teacher: teacherJson,
    students: students,
    accounts,
    room,
  };
}

const level = [
  'unknown',
  'excellent',
  'good',
  'poor',
  'bad',
  'very bad',
  'down'
];

export function NetworkQualityEvaluation(evt: { downlinkNetworkQuality: number, uplinkNetworkQuality: number }) {
  let defaultQuality = 'unknown';
  const val = Math.max(evt.downlinkNetworkQuality, evt.uplinkNetworkQuality);
  return level[val] ? level[val] : defaultQuality;
}

export function btoa(input: any) {
  let keyStr =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  let output = "";
  let chr1, chr2, chr3, enc1, enc2, enc3, enc4;
  let i = 0;

  while (i < input.length) {
    chr1 = input[i++];
    chr2 = i < input.length ? input[i++] : Number.NaN; // Not sure if the index
    chr3 = i < input.length ? input[i++] : Number.NaN; // checks are needed here

    enc1 = chr1 >> 2;
    enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
    enc4 = chr3 & 63;

    if (isNaN(chr2)) {
      enc3 = enc4 = 64;
    } else if (isNaN(chr3)) {
      enc4 = 64;
    }
    output +=
      keyStr.charAt(enc1) +
      keyStr.charAt(enc2) +
      keyStr.charAt(enc3) +
      keyStr.charAt(enc4);
  }
  return output;
}