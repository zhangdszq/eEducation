import React, {useEffect, FunctionComponent, useState} from 'react';
import AgoraRtcEngine from 'agora-electron-sdk';
// import {Spin} from 'antd'
import {createLogger} from '../../utils'
import './index.scss'

const playerLog = createLogger('[StreamPlayer]', 'white', 'black', true)

export interface NativeStreamPlayerProps {
  stream: {
    local: boolean,
    share: boolean,
    id: number
  };
  name?: string;
  rtcClient: AgoraRtcEngine;
  className?: string;
}

const NativeStreamPlayer: FunctionComponent<NativeStreamPlayerProps> = props => {
  // const [loading, setLoading] = useState(true);
  const {stream, rtcClient, name} = props;
  useEffect(() => {
    const dom = document.querySelector(`#video-${stream.id}`)
    playerLog(`Playing stream: id ${stream.id} local ${stream.local} remote ${stream.share}`)
    if (!stream.local) {
      rtcClient.subscribe(stream.id, dom as HTMLElement);
      if (stream.share) {
        playerLog('Set Content Mode to fit')
        // @ts-ignore
        rtcClient.setupViewContentMode('videosource', 1)
        rtcClient.setupViewContentMode(stream.id, 1)
      }
    } else if (stream.share) {
      rtcClient.setupLocalVideoSource(dom as HTMLElement);
      playerLog('Set Content Mode to fit')
      // @ts-ignore
      rtcClient.setupViewContentMode('videosource', 1)
      rtcClient.setupViewContentMode(stream.id, 1)
    } else {
      rtcClient.setupLocalVideo(dom as HTMLElement);
    }
    // const renderer = rtcClient.streams.get(String(stream.id));
    // if (renderer) {
    //   // @ts-ignore
    //   renderer.event.on('ready', () => {
    //     setLoading(true)
    //   })
    // }

  }, [0]);

  return (
    <div className={`window-item ${props.className || ''}`}>
      {/* {loading && (<Spin className="loading"/>)} */}
      <div className="video-item" id={`video-${stream.id}`}></div>
      <div className="video-label">{name || ''}</div>
    </div>
  )
}

export default NativeStreamPlayer;