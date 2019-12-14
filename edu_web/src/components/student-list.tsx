import React, { useMemo, useRef } from 'react';
import './student-list.scss';
import Icon from './icon';
import { User, UserRole } from '../reducers/types';
import { useRootContext } from '../store';
import { RoomMessage } from '../utils/agora-rtm-client';

interface CustomIconProps {
  value: boolean
  type: string
  icon: string
  id: string
  onClick: (evt: any, id: string, type: string) => any
}

function CustomIcon ({
  value,
  icon,
  id,
  type,
  onClick
}: CustomIconProps) {
  const handleClick = (evt: any) => {
    onClick(evt, id, type);
  }
  return (
    <div className="items">
        {/* {value ? */}
          <Icon className={`icon-${icon}-${value ? "on" : "off"}`}
            onClick={handleClick}
            />
             {/* : null } */}
    </div>
  )
}

interface StudentListProps {
  list: User[]
  role: UserRole
}

export default function StudentList ({
  list,
  role
}: StudentListProps) {

  const {store} = useRootContext();

  const rtmClient = useMemo(() => {
    return store.global.rtmClient
  }, [store.global.rtmClient]);

  const me = useMemo(() => {
    return store.user;
  }, [store.user]);

  const ref = useRef<any>(null);

  const handleClick = (evt: any, id: string, type: string) => {
    if (rtmClient && me) {
      const targetUser = store.room.users.get(id);
      if (!targetUser) return;

      if (targetUser.id === me.id) {
        if (ref.current === null) {
          if (['chat', 'audio', 'video'].indexOf(type) !== -1) {
            ref.current = true;
            rtmClient.updateChannelAttrs(store, {
              // @ts-ignore
              [`${type}`]: +(!Boolean(targetUser[type])) as number
            }).then(() => {
              ref.current = null;
            }).catch((err: any) => {
              console.warn(err);
              ref.current = null;
            })
          }
        }
      }

      if (role === 'teacher') {
        if (ref.current === null) {
          if (['chat', 'audio', 'video'].indexOf(type) !== -1) {
            ref.current = true;
            const body = {
              cmd: 0,
            }
            // @ts-ignore
            const mediaState: number = targetUser[type];
            if (type === 'audio') {
              body.cmd = mediaState ? RoomMessage.muteAudio : RoomMessage.unmuteAudio
            }
            if (type === 'video') {
              body.cmd = mediaState ? RoomMessage.muteVideo : RoomMessage.unmuteVideo
            }
            if (type === 'chat') {
              body.cmd = mediaState ? RoomMessage.muteChat : RoomMessage.unmuteChat
            }

            rtmClient.sendPeerMessage(id, body).then(() => {
              ref.current = null;
            }).catch((err: any) => {
              console.warn(err);
              ref.current = null;
            })
          }
        }
      }
    }
  }

  return (
    <div className="student-list">
      {list.map((item: User, key: number) => (
        <div key={key} className="item">
          <div className="nickname">{item.account}</div>
          <div className="attrs-group">
            {/* <CustomIcon value={item.attrs.connect} icon="connect" onClick={handleClick} /> */}
            <CustomIcon type="chat" id={item.id} value={Boolean(item.chat)} icon="chat" onClick={handleClick} />
            <CustomIcon type="audio" id={item.id} value={Boolean(item.audio)} icon="audio" onClick={handleClick} />
            <CustomIcon type="video" id={item.id} value={Boolean(item.video)} icon="video" onClick={handleClick} />
          </div>
        </div>
      ))}
    </div>
  )
}