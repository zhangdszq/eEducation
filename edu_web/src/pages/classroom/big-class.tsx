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

export default function BigClass() {
  const {
    value,
    messages,
    sendMessage,
    handleChange,
    role,
    roomName
  } = useChatText();

  const {store, dispatch} = useRootContext();

  const {teacher, currentHost, onPlayerClick} = useStream();

  const {updateGlobalLinkId} = useAgoraSDK();

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
              // dispatch({ type: ActionType.UPDATE_LINK_UID, peerId: store.user.id })
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
              updateGlobalLinkId('');
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
    if (store.user.id && currentHost && store.global.rtmClient && store.global.rtcClient) {
      // when current host is local and teacher is broadcasting
      if (currentHost.id === store.user.id && teacher && !rtmLock.current) {
        rtmLock.current = true
        Promise.all([
          store.global
          .rtmClient
          .sendPeerMessage(`${teacher.id}`,
          {
            cmd: RoomMessage.cancelCoVideo
          }
        ),
          store.global.rtcClient.unpublishStream()
        ])
        .then(() => {
          rtmLock.current = false;
          updateGlobalLinkId('');
        }).catch((err: any) => {
          rtmLock.current = false;
          console.log("[rtm-client] send cancel ", err);
          throw err;
        }).finally(() => {
          dispatch({type: ActionType.REMOVE_LOCAL_STREAM });
        })
      }

      // when teacher
      if (teacher && teacher.id === store.user.id && !rtmLock.current) {
        rtmLock.current = true
        Promise.all([
          // store.global.rtmClient
          // .updateChannelAttrs(store, {link_uid: 0}),
          store.global.rtmClient.sendPeerMessage(`${streamID}`, {
            cmd: RoomMessage.cancelCoVideo
          })
        ])
        .then(() => {
          rtmLock.current = false;
          dispatch({ type: ActionType.UPDATE_APPLY, apply: false });
          updateGlobalLinkId('');
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
              stream={currentHost.stream}
              domId={currentHost.id}
              id={currentHost.id}
              account={currentHost.account}
              handleClick={onPlayerClick}
              close={Boolean(store.global.linkId)}
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
          sendMessage={sendMessage}
          handleChange={handleChange} />
      </div>
    </div>
  )
}