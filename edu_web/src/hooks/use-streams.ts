import { useMemo, useCallback, useRef } from 'react';
import { useRootContext } from '../store';
import { AgoraStream, User, UserRole } from '../reducers/types';
import { RoomMessage } from '../utils/agora-rtm-client';
import { resolveStreamID } from '../utils/helper';

type AgoraMediaStream = AgoraStream | undefined;

export default function useStream() {
  const { store } = useRootContext();
  const { teacher, students, sharedStream, currentHost }: {
    teacher: AgoraMediaStream,
    students: AgoraStream[],
    sharedStream: AgoraMediaStream,
    currentHost: AgoraMediaStream
  } = useMemo(() => {
    // console.log("[agora-stream] update stream");
    const { room, user } = store;
    const me = room.users.find((it: User) => it.id === user.id);

    let _teacherStream: AgoraMediaStream | undefined;
    let _studentsStream: AgoraStream[] = [];
    let _currentHost: AgoraMediaStream | undefined;
    let _sharedStream: AgoraMediaStream | undefined;

    // when rtm login and students not empty
    if (user.id && room.users.count() && me) {
      const teacherInfo = room.users.find((it: User) => it.role === 'teacher');
      const peerUsers = room.users.filter((it: User) => it.id !== user.id);

      const currentStreamID = resolveStreamID(me.id);
      // when current host user is teacher
      if (teacherInfo && teacherInfo.id === me.id && store.global.localStream) {
        _teacherStream = {
          id: teacherInfo.id,
          streamID: store.global.localStream.getId(),
          stream: store.global.localStream,
          local: true,
          account: teacherInfo.account,
          video: Boolean(teacherInfo.video),
          audio: Boolean(teacherInfo.audio),
          playing: store.global.localStream.isPlaying()
        }
      }

      // when current user is not teacher
      if (teacherInfo && teacherInfo.id !== me.id) {
        const _stream = store.global.remoteStreams.get(`${resolveStreamID(teacherInfo.id)}`)
        if (_stream) {
          _teacherStream = {
            id: teacherInfo.id,
            streamID: _stream.getId(),
            local: false,
            account: teacherInfo.account,
            stream: _stream,
            video: Boolean(teacherInfo.video),
            audio: Boolean(teacherInfo.audio),
            playing: _stream.isPlaying()
          }
        }
      }

      // when current host is not teacher
      if (me && me.role === 'student' && store.global.localStream) {
        _studentsStream.push({
          id: me.id,
          account: me.account,
          streamID: store.global.localStream.getId(),
          local: true,
          stream: store.global.localStream,
          audio: Boolean(me.audio),
          video: Boolean(me.video)
        })
      }
      peerUsers.forEach((it: User) => {
        const stream = store.global.remoteStreams.get(`${resolveStreamID(it.id)}`);
        if (stream) {
          const exist = _studentsStream.find((it: any) => it.streamID === stream.getId());
          if (exist) return true;
          if (_teacherStream && _teacherStream.streamID === stream.getId()) return true;
          const _tmpStream: AgoraStream = {
            id: it.id,
            streamID: stream.getId(),
            local: false,
            account: it.account,
            stream,
            video: Boolean(it.video),
            audio: Boolean(it.audio),
            playing: stream.isPlaying()
          }
          _studentsStream.push(_tmpStream);
        }
      })
      // peerUsers.forEach((it: User) => {
      //   const stream = store.global.remoteStreams.get(`${resolveStreamID(it.id)}`);
      //   if (stream) {
      //     const exist = _studentsStream.find((it: AgoraStream) => it.id === stream.id);
      //     if (exist) return true;
      //     // exclude remote teacher stream
      //     if (_teacherStream && _teacherStream.id === stream.id) return true;
      //     const _tmpStream: AgoraStream = {
      //       id: it.id,
      //       streamID: stream.getId(),
      //       local: false,
      //       account: it.account,
      //       stream: stream,
      //       video: Boolean(it.video),
      //       audio: Boolean(it.audio),
      //       playing: stream.isPlaying()
      //     }
      //     _studentsStream.push(_tmpStream);
      //   }
      // });

      // when screen share is local
      if (store.global.sharedStream) {
        _sharedStream = {
          id: me.id,
          streamID: store.global.sharedStream.getId(),
          local: true,
          account: '',
          stream: store.global.sharedStream,
          video: Boolean(1),
          audio: Boolean(1),
          playing: store.global.sharedStream.isPlaying()
        }
      }

      if (store.global.linkId) {
        // when current user is host
        if (store.global.linkId === `${resolveStreamID(me.id)}`) {
          if (store.global.localStream) {
            _currentHost = {
              ...me,
              local: true,
              video: Boolean(me.video),
              audio: Boolean(me.audio),
              account: me.account,
              streamID: store.global.localStream.getId(),
              stream: store.global.localStream,
              playing: store.global.localStream.isPlaying(),
            }
          }
        } else {
          const peerUser = peerUsers.find((it: any) => `${resolveStreamID(it.id)}` === store.global.linkId);
          const remoteStream = store.global.remoteStreams.get(`${store.global.linkId}`);
          if (remoteStream && peerUser) {
            _currentHost = {
              ...peerUser,
              local: false,
              video: Boolean(peerUser.video),
              audio: Boolean(peerUser.audio),
              account: peerUser.account,
              streamID: remoteStream.getId(),
              stream: remoteStream,
              playing: remoteStream.isPlaying(),
            }
          }
        }
      }
    }

    if (!_sharedStream && store.room.sharedId) {
      const sharedStream = store.global.remoteStreams.get(`${store.room.sharedId}`);
      const sharedUser = store.room.users.find((it: User) => it.role === UserRole.teacher);
      if (sharedStream && sharedUser) {
        _sharedStream = {
          id: sharedUser.id,
          streamID: sharedStream.getId(),
          local: false,
          account: '',
          stream: sharedStream,
          video: Boolean(1),
          audio: Boolean(1),
          playing: sharedStream.isPlaying()
        }
      }
    }

    return {
      teacher: _teacherStream,
      students: _studentsStream,
      sharedStream: _sharedStream,
      currentHost: _currentHost
    }
  }, [store.global.sharedStream,
  store.global.localStream,
  store.global.remoteStreams,
  store.room.users, store.room.sharedId, store.global.linkId]);

  const deps = [
    store.user,
    store.global.rtmClient,
    teacher,
    students,
    sharedStream,
    currentHost,
    store.room,
  ];

  const ref = useRef<any>(false);

  const onPlayerClick = async (type: string, streamID: number, uid: string) => {
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
                // const mediaVal = remoteUser[`${type}`];
                // const operateType = Boolean(mediaVal) ? OperateType.mute : OperateType.unmute
                // const resource: Resource = Resource[type as keyof typeof Resource];
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

  const onCoVideoClick = useCallback(() => {

  }, deps);

  return {
    teacher,
    students,
    sharedStream,
    currentHost,
    onPlayerClick,
    onCoVideoClick
  }
}