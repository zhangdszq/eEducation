import React from 'react';
import './index.scss';
import { Link } from 'react-router-dom';
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

  const text = React.useMemo(() => {
    if (link) {
      return (
        <Link to={link} target="_blank">course recording</Link>
      )
    }
    return link ? link : content;
  }, [content, link])

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