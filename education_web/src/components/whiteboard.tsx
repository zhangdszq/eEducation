import React, {useEffect} from 'react';
import './whiteboard.scss';
import { Room } from 'white-web-sdk';
import { whiteboard } from '../stores/whiteboard';
import { t } from '../utils/i18n';
import { Progress } from '../components/progress/progress';
interface WhiteBoardProps {
  room: Room
  className: string
  loading: boolean
}

export default function Whiteboard ({
  room,
  className,
  loading
}: WhiteBoardProps) {

  useEffect(() => {
    if (!room) return;
    room.bindHtmlElement(document.getElementById('whiteboard') as HTMLDivElement);
    const $whiteboard = document.getElementById('whiteboard') as HTMLDivElement
    whiteboard.updateRoomState();
    if ($whiteboard) {
      window.addEventListener("resize", (evt: any) => {
        console.log("loading",whiteboard.state.loading);
        if (!whiteboard.state.loading) {
          room.moveCamera({centerX: 0, centerY: 0});
          room.refreshViewSize();           
        }
      });
      return () => {
        window.removeEventListener("resize", (evt: any) => {});
      }
    }
  }, [room])

  return (
    <div className="whiteboard">
      { loading ? <Progress title={t("whiteboard.loading")}></Progress> : null}
      <div id="whiteboard" className={`whiteboard-canvas ${className}`}></div>
    </div>
  )
}