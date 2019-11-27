import React from 'react';
import ChatPanel from './panel';
import { ChatMessage } from '../../reducers/types';
import { List } from 'immutable';

interface ChatBoard {
  name?: string
  messages: List<ChatMessage>
  value: string
  teacher?: boolean
  mute?: boolean
  sendMessage: (evt: any) => void
  handleChange: (evt: any) => void
}

export default function ChatBoard (props: ChatBoard) {
  return (
    <div className="chat-board">
      {props.name ? <div className="chat-roomname">{props.name}</div> : null}
        <ChatPanel
          messages={props.messages}
          value={props.value}
          sendMessage={props.sendMessage}
          handleChange={props.handleChange} />
    </div>
  )
}