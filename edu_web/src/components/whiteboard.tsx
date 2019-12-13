import React, {useEffect, forwardRef} from 'react';
import './whiteboard.scss';
import { Room } from 'white-web-sdk';
import { recording } from '../hooks/use-recording';
import { useRootContext } from '../store';

interface WhiteBoardProps {
  room: Room
}

export default function Whiteboard ({
  room,
}: WhiteBoardProps) {

  const {store} = useRootContext();
  useEffect(() => {
    if (!room || !store.room.rid) return;
    // if (room) {
    room.bindHtmlElement(document.getElementById('whiteboard') as HTMLDivElement);
    const whiteboard = document.getElementById('whiteboard') as HTMLDivElement
    if (whiteboard) {
      recording.updateRoom(room.uuid, store.room.rid);
      window.addEventListener("resize", (evt: any) => {
        room.moveCamera({centerX: 0, centerY: 0});
        room.refreshViewSize();
      });
      return () => {
        window.removeEventListener("resize", (evt: any) => {});
      }
    }
    // }
  }, [room, store.room.rid])

  return (
    <div className="whiteboard">
      <div id="whiteboard" className="whiteboard-canvas"></div>
    </div>
  )
}