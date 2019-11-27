import React from 'react';
import './index.scss';
interface MessageProps {
  nickname: string
  content: string
  sender?: boolean
}

export default function (props: MessageProps) {
  return (
    <div className={`message ${props.sender ? 'sent': 'receive'}`}>
      <div className="nickname">
        {props.nickname}
      </div>
      <div className="content">
        {props.content}
      </div>
    </div>
  )
} 