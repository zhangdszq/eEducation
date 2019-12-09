import React, { useMemo, useCallback, useRef } from 'react';
import { useRootContext } from '../store';
import { AgoraStream, User, AgoraMediaStream } from '../reducers/types';
import { RoomMessage } from '../utils/agora-rtm-client';
import {  } from '../utils/helper';
import { SHARE_ID } from '../utils/agora-rtc-client';
import _ from 'lodash';

export default function useStream() {
  const { store } = useRootContext();

  const { teacher, students, sharedStream, currentHost }: {
    teacher: AgoraMediaStream | undefined,
    students: AgoraMediaStream[],
    sharedStream: AgoraMediaStream | undefined,
    currentHost: AgoraMediaStream | undefined
  } = useMemo(() => {
    const { room, user } = store;
    const me = room.users.find((it: User) => it.id === user.id);
    const teacher = room.users.find((it: User) => it.role === 'teacher');
    let _teacherStream: AgoraMediaStream | undefined;
    let _studentsStream: AgoraMediaStream[] = [];
    let _currentHost: AgoraMediaStream | undefined;
    let _sharedStream: AgoraMediaStream | undefined;

    // when rtm login and students not empty
    if (user.id && room.users.count() && me) {
      const teacherInfo = room.users.find((it: User) => it.role === 'teacher');
      const peerUsers = room.users.filter((it: User) => it.id !== user.id);

      const currentStreamID = (me.id);
      // when current host user is teacher
      if (teacherInfo && teacherInfo.id === me.id && store.global.localStream) {
        _teacherStream = {
          ...store.global.localStream,
          id: teacherInfo.id,
          account: teacherInfo.account,
          video: Boolean(teacherInfo.video),
          audio: Boolean(teacherInfo.audio),
        }
      }

      // when current user is not teacher
      if (teacherInfo && teacherInfo.id !== me.id) {
        const _stream = store.global.remoteStreams.get(`${(teacherInfo.id)}`)
        if (_stream) {
          _teacherStream = {
            ..._stream,
            id: teacherInfo.id,
            account: teacherInfo.account,
            video: Boolean(teacherInfo.video),
            audio: Boolean(teacherInfo.audio),
          }
        }
      }

      // when current host is not teacher
      if (me && me.role === 'student' && store.global.localStream) {
        _studentsStream.push({
          ...store.global.localStream,
          id: me.id,
          account: me.account,
          audio: Boolean(me.audio),
          video: Boolean(me.video)
        })
      }
      peerUsers.forEach((it: User) => {
        const stream = store.global.remoteStreams.get(`${(it.id)}`);
        if (stream) {
          const exist = _studentsStream.find((it: AgoraMediaStream) => it.streamID === stream.streamID);
          if (exist) return true;
          if (_teacherStream && _teacherStream.streamID === stream.streamID) return true;
          const _tmpStream = {
            ...stream,
            id: it.id,
            account: it.account,
            video: Boolean(it.video),
            audio: Boolean(it.audio),
          }
          _studentsStream.push(_tmpStream);
        }
      })

      // when screen share is local
      if (store.global.sharedStream) {
        _sharedStream = {
          ...store.global.sharedStream,
          id: me.id,
          account: '',
          video: true,
          audio: true,
        }
      }

      // when current user is host
      if (store.room.linkId) {
        if (store.room.linkId === +me.id) {
          if (store.global.localStream) {
            _currentHost = {
              ...me,
              ...store.global.localStream,
              id: me.id,
              video: Boolean(me.video),
              audio: Boolean(me.audio),
              account: me.account,
            }
          }
        } else {
          const remoteStream = store.global.remoteStreams.get(`${store.room.linkId}`);
          const peerUser = remoteStream && peerUsers.get(`${remoteStream.streamID}`);
          if (remoteStream && peerUser) {
            _currentHost = {
              ...peerUser,
              ...remoteStream,
              id: peerUser.id,
              video: Boolean(peerUser.video),
              audio: Boolean(peerUser.audio),
              account: peerUser.account,
            }
          }
        }
      }
    }

    if (!_sharedStream && teacher) {
      const sharedStream = store.global.remoteStreams.get(`${SHARE_ID}`);
      if (sharedStream) {
        _sharedStream = {
          ...sharedStream,
          id: teacher.id,
          account: '',
          video: true,
          audio: true,
        }
      }
    }

    return {
      teacher: _teacherStream,
      students: _studentsStream,
      sharedStream: _sharedStream,
      currentHost: _currentHost
    }
  }, [
    store.global.sharedStream,
    store.global.localStream,
    store.global.remoteStreams,
    store.room.users, store.room.sharedId, store.room.linkId]);

  const ref = useRef<any>(false);

  const onPlayerClick = async (type: string, streamID: number, uid: string) => {
    console.log("click ", type, streamID, uid);
    if (!ref.current && store.user && store.user.id && store.global.rtmClient) {
      const me: User | undefined = store.room.users.get(store.user.id);
      if (me) {
        try {
          let key: string = `${uid}`;
          let val: any = {};
          if (store.user.role === 'teacher') {
            if (uid === store.user.id && store.global.localStream) {
              key = 'teacher';
              val = {
                [`${key}`]: {
                  ...me,
                }
              }
            } else {
              const remoteUser: any = store.room.users.get(`${key}`);
              if (remoteUser) {
                const body = {
                  cmd: 0,
                }

                // @ts-ignore
                const mediaState: number = remoteUser[type];
                if (type === 'audio') {
                  body.cmd = mediaState ? RoomMessage.muteAudio : RoomMessage.unmuteAudio;
                }
                if (type === 'video') {
                  body.cmd = mediaState ? RoomMessage.muteVideo : RoomMessage.unmuteVideo;
                }
                if (type === 'chat') {
                  body.cmd = mediaState ? RoomMessage.muteChat : RoomMessage.unmuteChat;
                }
                await store.global.rtmClient.sendPeerMessage(uid, body);
                return true;
              }
            }
          } else {
            if (uid === store.user.id && store.global.localStream) {
              key = `${uid}`;
              val = {
                [`${key}`]: {
                  ...me,
                }
              }
            }
          }
          if (type === 'audio') {
            val[`${key}`].audio = +!Boolean(val[`${key}`].audio)
          }
          if (type === 'video') {
            val[`${key}`].video = +!Boolean(val[`${key}`].video)
          }
          if (type === 'chat') {
            val[`${key}`].chat = +!Boolean(val[`${key}`].chat)
          }
          await store.global.rtmClient.updateChannelAttrs(store, {
            ...val[`${key}`]
          });
        } catch (err) {
          throw err;
        } finally {
          ref.current = false;
        }
      }
    }
  };

  return {
    teacher,
    students,
    sharedStream,
    currentHost,
    onPlayerClick,
  }
}