import React from 'react';
import VideoPlayer from '../../components/video-player';
import MediaBoard from '../../components/mediaboard';
import ChatBoard from '../../components/chat/board';
import useStream from '../../hooks/use-streams';
import useChatText from '../../hooks/use-chat-text';

export default function OneToOne() {
  const {
    value,
    messages,
    sendMessage,
    handleChange,    
  } = useChatText();

  const {teacher, students, onPlayerClick} = useStream();

  return (
    <div className="room-container">
      <MediaBoard />
      <div className="live-board">
        <div className="video-board">
          {teacher !== undefined ?
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
              domId={'teacher'}
              video
              audio
              />}
          {students[0] ?
            <VideoPlayer
              role="student"
              stream={students[0].stream}
              domId={students[0].id}
              id={students[0].id}
              handleClick={onPlayerClick}
              account={students[0].account}
              video={students[0].video}
              audio={students[0].audio}
              local={students[0].local}
            /> :
            <VideoPlayer
              role="student"
              account={"student"}
              domId={"student"}
              video={false}
              audio={false}
            />}
        </div>
        <ChatBoard
          messages={messages}
          value={value}
          sendMessage={sendMessage}
          handleChange={handleChange}
        />
      </div>
    </div>
  )
}