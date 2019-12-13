import React, { useState, useEffect, useRef } from 'react';
import Icon from './icon';
import SettingCard from '../components/setting-card';
import './nav.scss';
import Button from './custom-button';
import * as moment from 'moment';
import { useRootContext } from '../store';
import { useAgoraSDK } from '../hooks/use-agora-sdk';
import { ClassState } from '../reducers/types';
import { useHistory } from 'react-router';
import { NetworkQualityEvaluation } from '../utils/helper';
import { useGlobalContext } from '../containers/global-container';
import { usePlatform } from '../containers/platform-container';
import AgoraWebClient from '../utils/agora-rtc-client';
import { AgoraElectronClient } from '../utils/agora-electron-client';

interface NavProps {
  delay: string
  network: string
  cpu: string
  role: string
  roomName: string
  time: number
  showSetting: boolean
  classState: boolean
  onCardConfirm: (type: string) => void
  handleClick: (type: string) => void
}

export function Nav ({
  delay,
  network,
  cpu,
  role,
  roomName,
  time,
  handleClick,
  showSetting,
  classState,
  onCardConfirm,
}: NavProps) {

  const {platform, NavBtn} = usePlatform();
    
  const handleFinish = (evt: any) => {
    onCardConfirm('setting');
  }

  return (
    <>
    <div className="nav-container">
      <div className="class-title">
        <span className="room-name">{roomName}</span>
        {role === 'teacher' ? 
          <Button className={`nav-button ${classState ? "stop" : "start"}`} name={classState ? "Class end" : "Class start"} onClick={(evt: any) => {
            handleClick("classState")
          }} /> : null}
      </div>
      <div className="network-state">
        {platform === 'web' ? <span className="net-field">Delay: <span className="net-field-value">{delay}</span></span> : null}
        {/* <span className="net-field">Packet Loss Rate: <span className="net-field-value">{lossPacket}</span></span> */}
        <span className="net-field">Network: <span className="net-field-value">{network}</span></span>
        {platform === 'electron' ? <span className="net-field">CPU: <span className="net-field-value">{cpu}</span></span> : null}
      </div>
      <div className="menu">
        <div className="timer">
          <Icon className="icon-time" disable />
          <span className="time">{moment.utc(time).format('HH:mm:ss')}</span>
        </div>
        <span className="menu-split" />
        <div className={platform === 'web' ? "btn-group" : 'electron-btn-group' }>
          {platform  === 'web' ? <Icon className="icon-setting" onClick={(evt: any) => {
            handleClick("setting");
          }}/> : null}
          <Icon className="icon-exit" onClick={(evt: any) => {
            handleClick("exit");
          }} />
        </div>
        <NavBtn />
      </div>
    </div>
    {showSetting ? 
      <SettingCard className="internal-card"
        handleFinish={handleFinish} /> : null
    }
    </>

  )
}

export default function NavContainer() {
  const history = useHistory();
  const {store} = useRootContext();
  const {
    showDialog,
    removeDialog,
  } = useGlobalContext();

  const {
    platform
  } = usePlatform();

  const {
    exitAll,
    rtcClient
  } = useAgoraSDK();

  const ref = useRef<boolean>(false);

  const [time, updateTime] = useState<number>(0);

  const [timer, setTimer] = useState<any>(null);

  const calcDuration = (time: number) => {
    return setInterval(() => {
      !ref.current && updateTime(+Date.now() - time);
    }, 150, time)
  }

  const [card, setCard] = useState<boolean>(false);

  const [rtt, updateRtt] = useState<number>(0);
  const [quality, updateQuality] = useState<string>('unknown');
  const [cpuUsage, updateCpuUsage] = useState<number>(0);

  useEffect(() => {
    return () => {
      ref.current = true;
      if (timer) {
        clearInterval(timer);
        setTimer(null);
      }
    }
  }, []);

  useEffect(() => {
    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      webClient.rtc.on('watch-rtt', (rtt: number) => {
        !ref.current && updateRtt(rtt);
      });
      webClient.rtc.on('network-quality', (evt: any) => {
        const quality = NetworkQualityEvaluation(evt);
        !ref.current && updateQuality(quality);
      })
      return () => {
        webClient.rtc.off('watch-rtt', () => {});
        webClient.rtc.off('network-quality', () => {});
      }
    }
    if (platform === 'electron') {
      const nativeClient = rtcClient as AgoraElectronClient;
      nativeClient.on('rtcStats', ({cpuTotalUsage}: any) => {
        !ref.current && updateCpuUsage(cpuTotalUsage);
      });
      nativeClient.on('networkquality', (
        uid: number,
        txquality: number,
        rxquality: number) => {
        if (uid === 0) {
          const quality = NetworkQualityEvaluation({
            downlinkNetworkQuality: rxquality,
            uplinkNetworkQuality: txquality,
          });
          !ref.current && updateQuality(quality);
        }
      })

      return () => {
        nativeClient.off('rtcStats', () => {});
        nativeClient.off('networkquality', () => {});
        nativeClient.off('audioquality', () => {});
      }
    }
  }, [rtcClient]);

  useEffect(() => {
    if (store.room.classState === ClassState.STARTED
      && timer === null) {
        const now: number = +Date.now();
        setTimer(calcDuration(now));
    }
    if (timer && store.room.classState === ClassState.CLOSED) {
      clearInterval(timer);
      setTimer(null);
    }
  }, [store.room]);

  const updateClassState = () => {
    if (store.global.rtmClient) {
      const class_state: number = store.room.classState === ClassState.CLOSED ? 1 : 0;
      store.global.rtmClient.updateChannelAttrs(store, {
        class_state
      })
      .then(() => {
        console.log("update teacher ");
      })
      .catch((err: any) => {
        console.warn(err);
      })
    }
  };

  const handleClick = (type: string) => {
    if (type === 'setting') {
      setCard(true);
    } else if (type === 'exit') {
      showDialog({
        type: 'exitRoom',
        desc: 'Are U sure to exit the classroom?'
      });
    } else if (type === 'classState') {
      updateClassState();
    }
  }

  const handleCardConfirm = (type: string) => {
    switch (type) {
      case 'setting':
        setCard(false);
        return;
      case 'exitRoom':
        removeDialog();
        exitAll().then(() => {
        }).catch(console.warn)
          .finally(() => {
            history.push('/');
          })
        return;
    }
  }

  return (
    <Nav 
      role={store.user.role}
      roomName={store.room.room}
      classState={Boolean(store.room.classState)}
      delay={`${rtt}ms`}
      time={time}
      network={`${quality}`}
      cpu={`${cpuUsage}%`}
      showSetting={card}
      onCardConfirm={handleCardConfirm}
      handleClick={handleClick}
    />
  )
}