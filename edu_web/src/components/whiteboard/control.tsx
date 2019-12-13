import React, { useState, useEffect, useRef } from 'react';
import Icon from '../icon';
import { NoticeProps } from '../../reducers/initialize-state';
import { recording, useRecording } from '../../hooks/use-recording';
import { useRootContext } from '../../store';
import { useHistory } from 'react-router';
import { ActionType } from '../../reducers/types';
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

  const history = useHistory();

  const recordingState = useRecording();
  const {store, dispatch} = useRootContext();

  const lock = useRef<boolean>(false);

  const handleRecording = (evt: any) => {
    if (lock.current
      || !recording
      || !recording.state 
      || !store.room.rid
      || !store.user.id) return;
    evt.preventDefault();

    if (recording.state.recording) {
      recording.stopRecording();
      if (recording.state.endTime 
        && recording.state.startTime) {
        const {endTime, startTime, roomUUID} = recording.clearRecording();
        if (store.global.rtmClient) {
          store.global.rtmClient.sendChannelMessage(JSON.stringify({
            account: store.user.account,
            link: `/replay/${roomUUID}/${startTime}/${endTime}`
          })).then(() => {
            const message = {
              account: store.user.account,
              id: store.user.id,
              link: `/replay/${roomUUID}/${startTime}/${endTime}`,
              text: '',
              ts: +Date.now()
            }
            dispatch({type: ActionType.ADD_MESSAGE, message});
            console.log('send replay link success');
          }).catch(console.warn);
        }
        return;
      }
    } else {
      recording.startRecording();
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
              name={recordingState.recording ? 'stop_recording' : 'recording'}
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