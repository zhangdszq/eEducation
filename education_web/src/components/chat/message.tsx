import React from 'react';
import './index.scss';
import { Link } from 'react-router-dom';
import { useRoomState } from '../../containers/root-container';
interface MessageProps {
  nickname: string
  content: string
  link?: string
  sender?: boolean
}

export const Message: React.FC<MessageProps> = ({
  nickname,
  content,
  link,
  sender
}) => {

  const roomState = useRoomState();

  const text = React.useMemo(() => {
    if (link && roomState.course.rid) {
      return (
        <Link to={`${link}?rid=${roomState.course.rid}`} target="_blank">course recording</Link>
      )
    }
    return link ? link : content;
  }, [content, link, roomState.course.rid])

  return (
  <div className={`message ${sender ? 'sent': 'receive'}`}>
    <div className="nickname">
      {nickname}
    </div>
    <div className="content">
      {text}
    </div>
  </div>
  )
}