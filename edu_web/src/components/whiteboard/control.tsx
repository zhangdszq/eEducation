import React, { useRef } from 'react';
import Icon from '../icon';
import { roomStore } from '../../stores/room';
import { whiteboard } from '../../stores/whiteboard';
import moment from 'moment';
import { globalStore } from '../../stores/global';
interface ControlItemProps {
  name: string
  onClick: (evt: any, name: string) => void
  active: boolean
  text?: string
}

const ControlItem = (props: ControlItemProps) => {
  const onClick = (evt: any) => {
    props.onClick(evt, props.name);
  }
  return (
    props.text ?
      <div className={`control-btn control-${props.name}`} onClick={onClick}>
        <div className={`btn-icon ${props.name} ${props.active ? 'active' : ''}`}
          data-name={props.name} />
        <div className="control-text">{props.text}</div>
      </div>
      :
      <Icon
        data={props.name}
        onClick={onClick}
        className={`items ${props.name} ${props.active ? 'active' : ''}`}
      />
  )
}

interface NoticeProps {
  reason: string
  text?: string
}

interface ControlProps {
  sharing: boolean
  isHost?: boolean
  current: string
  currentPage: number
  totalPage: number
  role: string
  notice?: NoticeProps
  onClick: (evt: any, type: string) => void
}

export default function Control({
  sharing,
  isHost,
  current,
  currentPage,
  totalPage,
  onClick,
  role,
  notice,
}: ControlProps) {
  const lock = useRef<boolean>(false);

  const canStop = () => {
    const timeMoment = moment(whiteboard.state.startTime).add(15, 'seconds');
    if (+timeMoment >= +Date.now()) {
      globalStore.showToast({
        type: 'netlessClient',
        message: 'Recording too short, at least 15 seconds'
      })
      return false;
    }
    return true;
  }
  
  const handleRecording = (evt: any, type: string) => {
    const roomState = roomStore.state;
    const me = roomState.me;
    if (lock.current || !me.uid) return;

    if (whiteboard.state.recording) {
      if (!canStop()) return;
      whiteboard.stopRecording();
      if (whiteboard.state.endTime 
        && whiteboard.state.startTime) {
        const {endTime, startTime, roomUUID} = whiteboard.clearRecording();
        roomStore.rtmClient.sendChannelMessage(JSON.stringify({
          account: me.account,
          link: `/replay/${roomUUID}/${startTime}/${endTime}`
        })).then(() => {
          const message = {
            account: me.account,
            id: me.uid,
            link: `/replay/${roomUUID}/${startTime}/${endTime}`,
            text: '',
            ts: +Date.now()
          }
          roomStore.updateChannelMessage(message);
        })
        return;
      }
    } else {
      whiteboard.startRecording();
    }
  }

  return (
    <div className="controls-container">
      <div className="interactive">
        {notice ? 
          <ControlItem name={notice.reason}
            onClick={onClick}
            active={notice.reason === current} />
        : null}
      </div>
      <div className="controls">
        {!sharing && role === 'teacher' ?
          <>
            <ControlItem name={`first_page`}
              active={'first_page' === current}
              onClick={onClick} />
            <ControlItem name={`prev_page`}
              active={'prev_page' === current}
              onClick={onClick} />
            <div className="current_page">
              <span>{currentPage}/{totalPage}</span>
            </div>
            <ControlItem name={`next_page`}
              active={'next_page' === current}
              onClick={onClick} />
            <ControlItem name={`last_page`}
              active={'last_page' === current}
              onClick={onClick} />
            <div className="menu-split" style={{ marginLeft: '7px', marginRight: '7px' }}></div>
          </> : null
        }
        {role === 'teacher' ?
          <>
            <ControlItem
              name={whiteboard.state.recording ? 'stop_recording' : 'recording'}
              onClick={handleRecording}
              active={false}
            />
            <ControlItem
              name={sharing ? 'quit_screen_sharing' : 'screen_sharing'}
              onClick={onClick}
              active={false}
              text={sharing ? 'stop sharing' : ''}
            />
          </> : null }
        {role === 'student' ?
          <>
            <ControlItem
              name={isHost ? 'hands_up_end' : 'hands_up'}
              onClick={onClick}
              active={false}
              text={isHost ? 'stop' : ''}
            />
          </>
         :null}
      </div>

    </div>
  )
}