import React, {useRef, useEffect} from 'react';
import VideoPlayer from '../../components/video-player';

import './big-class.scss';
import ChatBoard from '../../components/chat/board';
import MediaBoard from '../../components/mediaboard';
import { useRootContext } from '../../store';
import { ActionType, UserRole } from '../../reducers/types';
import useStream from '../../hooks/use-streams';
import useChatText from '../../hooks/use-chat-text';
import { RoomMessage } from '../../utils/agora-rtm-client';
import { useAgoraSDK } from '../../hooks/use-agora-sdk';
import { usePlatform } from '../../containers/platform-container';
import { AgoraElectronClient } from '../../utils/agora-electron-client';
import AgoraWebClient from '../../utils/agora-rtc-client';

export default function BigClass() {
  const {
    value,
    messages,
    sendMessage,
    handleChange,
    role,
    roomName
  } = useChatText();

  const {platform} = usePlatform();

  const {store, dispatch} = useRootContext();

  const {teacher, currentHost, onPlayerClick} = useStream();

  const {memberCount, rtcClient} = useAgoraSDK();

  const rtmLock = useRef<boolean>(false);
  const lock = useRef<boolean>(false);
  
  useEffect(() => {
    rtmLock.current = false;
    return () => {
      rtmLock.current = true;
      lock.current = true;
    }
  }, []);

  useEffect(() => {
    if (store.global.rtmClient
      && store.user.role === UserRole.teacher
      && store.global.remoteStreams.count()
      && store.global.linkId) {
      const stream = store.global.remoteStreams.get(`${store.global.linkId}`);
      if (!stream)
      lock.current = true;
      store.global.rtmClient.updateChannelAttrs(store, {
        link_id: 0
      }).then(() => {
        lock.current = false;
      }).catch((err: any) => {
        lock.current = false;
        console.warn(err);
      });
    }
  }, [store.global.remoteStreams]);


  const handleClick = (type: string) => {
    if (type === 'hands_up') {
      if (teacher && store.global.rtmClient && store.user.id) {
        if (!rtmLock.current) {
          rtmLock.current = true;
          store.global.rtmClient
          .sendPeerMessage(teacher.id, {cmd: RoomMessage.applyCoVideo})
          .then((result: any) => {
            rtmLock.current = false;
            if (result) {
              console.log(`[co-video] apply success teacherId: ${teacher.id}, me: ${store.user.id}`);
              dispatch({ type: ActionType.UPDATE_APPLY, apply: true});
            }
          })
          .catch((err: any) => {
            rtmLock.current = false;
            console.warn('[co-video] apply failured ', JSON.stringify(err));
          })
        }
      }
    }
  
    if (type === 'hands_up_end') {
      if (teacher && store.global.rtmClient) {
        if (!rtmLock.current) {
          rtmLock.current = true;
          store.global.rtmClient
          .sendPeerMessage(teacher.id, {cmd: RoomMessage.cancelCoVideo})
          .then((result: boolean) => {
            rtmLock.current = false;
            if (result) {
              dispatch({ type: ActionType.UPDATE_APPLY, apply: false });
              console.log(`[co-video] cancel success teacherId: ${teacher.id}, me: ${store.user && store.user.id}`);
            }
          })
          .catch((err: any) => {
            rtmLock.current = false;
            console.warn('[co-video] cancel failured ', JSON.stringify(err));
          });
        }
      }
    }
  }

  // TODO: handleClose
  const handleClose = (type: string, streamID: number) => {
    if (store.user.id && currentHost && store.global.rtmClient) {
      // when current host is local and teacher is broadcasting
      if (currentHost.id === store.user.id && teacher && !rtmLock.current) {


        const quitClient = new Promise((resolve, reject) => {
          if (platform === 'electron') {
            const nativeClient = rtcClient as AgoraElectronClient;
            const val = nativeClient.unpublish();
            if (val >= 0) {
              resolve();
            } else {
              console.warn('quit native client failed');
              reject(val);
            }
          }
          if (platform === 'web') {
            const webClient = rtcClient as AgoraWebClient;
            resolve(webClient.unpublishLocalStream());
          }
        });

        rtmLock.current = true
        Promise.all([
          store.global
            .rtmClient
            .sendPeerMessage(`${teacher.id}`,
            {
              cmd: RoomMessage.cancelCoVideo
            }
          ),
          quitClient
        ])
        .then(() => {
          rtmLock.current = false;
        }).catch((err: any) => {
          rtmLock.current = false;
          console.log("[rtm-client] send cancel ", err);
          throw err;
        }).finally(() => {
          // dispatch({type: ActionType.REMOVE_LOCAL_STREAM });
        })
      }

      // when teacher
      if (teacher && teacher.id === store.user.id && !rtmLock.current) {
        rtmLock.current = true
        Promise.all([
          store.global.rtmClient.sendPeerMessage(`${streamID}`, {
            cmd: RoomMessage.cancelCoVideo
          }),
          store.global.rtmClient.updateChannelAttrs(store, {
            link_uid: 0
          })
        ])
        .then(() => {
          rtmLock.current = false;
          dispatch({ type: ActionType.UPDATE_APPLY, apply: false });
        }).catch((err: any) => {
          rtmLock.current = false;
          console.warn(err);
        })
      }
    }
  }

  return (
    <div className="room-container">
      <div className="live-container">
        <MediaBoard
          handleClick={handleClick}
        >
          <div className="video-container">
          {currentHost ? 
            <VideoPlayer
              role="teacher"
              streamID={currentHost.streamID}
              stream={currentHost.stream}
              domId={currentHost.id}
              id={currentHost.id}
              account={currentHost.account}
              handleClick={onPlayerClick}
              close={store.user.role === UserRole.teacher || store.user.id === currentHost.id}
              handleClose={handleClose}
              video={currentHost.video}
              audio={currentHost.audio}
              local={currentHost.local}
            /> :
            null
          }
        </div>
        </MediaBoard>
      </div>
      <div className="live-board">
        <div className="video-board">
          {teacher ?
            <VideoPlayer
              role="teacher"
              streamID={teacher.streamID}
              stream={teacher.stream}
              domId={teacher.id}
              id={teacher.id}
              account={teacher.account}
              handleClick={onPlayerClick}
              video={teacher.video}
              audio={teacher.audio}
              local={teacher.local}
              /> :
            <VideoPlayer
              role="teacher"
              account={'teacher'}
              streamID={0}
              video={true}
              audio={true}
              />}
        </div>
        <ChatBoard
          name={roomName}
          teacher={role === 'teacher'}
          messages={messages}
          mute={Boolean(store.room.muteChat)}
          value={value}
          roomCount={memberCount}
          sendMessage={sendMessage}
          handleChange={handleChange} />
      </div>
    </div>
  )
}