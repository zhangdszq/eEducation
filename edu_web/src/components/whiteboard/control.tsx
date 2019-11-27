import React, { useState } from 'react';
import Icon from '../icon';
import { NoticeProps } from '../../reducers/initialize-state';
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
  applyLive?: boolean
  current: string
  currentPage: number
  totalPage: number
  role: string
  notice?: NoticeProps
  onClick: (evt: any, type: string) => void
}

export default function Control({
  sharing,
  applyLive,
  current,
  currentPage,
  totalPage,
  onClick,
  role,
  notice,
}: ControlProps) {
  // const {store, methods} = useStore();

  const [recording, setRecording] = useState<boolean>(false);
  // const [applyLive, setApplyLive] = useState<boolean>(false);

  const handleRecording = (evt: any) => {
    setRecording(!recording);
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
            {/* <ControlItem
          name={recording ? 'stop_recording' : 'recording'}
          onClick={handleRecording}
          active={false}
        /> */}
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
              name={applyLive ? 'hands_up_end' : 'hands_up'}
              onClick={onClick}
              active={false}
              text={applyLive ? 'stop' : ''}
            />
          </>
         :null}
      </div>

    </div>
  )
}