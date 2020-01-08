import React, {useEffect} from 'react';
import './whiteboard.scss';
import { Room } from 'white-web-sdk';
import { whiteboard } from '../stores/whiteboard';
interface WhiteBoardProps {
  room: Room
  className: string
}

export default function Whiteboard ({
  room,
  className,
}: WhiteBoardProps) {

  useEffect(() => {
    if (!room) return;
    room.bindHtmlElement(document.getElementById('whiteboard') as HTMLDivElement);
    const $whiteboard = document.getElementById('whiteboard') as HTMLDivElement
    whiteboard.updateRoomState();
    if ($whiteboard) {
      window.addEventListener("resize", (evt: any) => {
        room.moveCamera({centerX: 0, centerY: 0});
        room.refreshViewSize();
      });
      return () => {
        window.removeEventListener("resize", (evt: any) => {});
      }
    }
  }, [room])

  return (
    <div className="whiteboard">
      {/* {room ? <RoomWhiteboard room={room} className={`whiteboard-canvas ${className}`}/> : null} */}
      <div id="whiteboard" className={`whiteboard-canvas ${className}`}></div>
    </div>
  )
}