import React, {useEffect} from 'react';
import './whiteboard.scss';
import { Room } from 'white-web-sdk';

interface WhiteBoardProps {
  room: Room
}

export default function Whiteboard ({
  room
}: WhiteBoardProps) {

  useEffect(() => {
    if (room) {
      room.bindHtmlElement(document.getElementById('whiteboard') as HTMLDivElement);
    }
  }, [room]);

  return (
    <div className="whiteboard">
      <div id="whiteboard" className="whiteboard-canvas"></div>
    </div>
  )
}