import React, {useState} from 'react';
import ChatPanel from './chat/panel';
import StudentList from './student-list';
import useChatText from '../hooks/use-chat-text';

export default function Roomboard (props: any) {
  const {
    role, list, value,
    messages, sendMessage, handleChange
  } = useChatText();

  const [active, setActive] = useState('chatroom');
  const [visible, setVisible] = useState(true);

  const toggleCollapse = (evt: any) => {
    setVisible(!visible);
  }

  return (
    <>
    <div className={`${visible ? "icon-collapse-off" : "icon-collapse-on" } fixed`} onClick={toggleCollapse}></div>
    {visible ? 
    <div className={`small-class chat-board`}>
      <div className="menu">
        <div onClick={() => { setActive('chatroom') }} className={`item ${active === 'chatroom' ? 'active' : ''}`}>Chatroom</div>
        <div onClick={() => { setActive('studentList') }} className={`item ${active === 'studentList' ? 'active' : ''}`}>Student List</div>
      </div>
      {
        active === 'chatroom' ?
        <ChatPanel
          messages={messages}
          value={value}
          sendMessage={sendMessage}
          handleChange={handleChange} />
        :
        <StudentList
          role={role}
          list={list}
        />
      }
    </div>
    : null}
    </>
  )
}