import React, { useState, useEffect, useRef } from 'react';
import Icon from './icon';
import SettingCard from '../components/setting-card';
import './nav.scss';
import Button from './custom-button';
import { isElectron } from '../utils/platform';
import * as moment from 'moment';
import { useRootContext } from '../store';
import { useAgoraSDK } from '../hooks/use-agora-sdk';
import { ClassState } from '../reducers/types';
import { useHistory } from 'react-router';
import { NetworkQualityEvaluation } from '../utils/helper';

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
        <span className="net-field">Delay: <span className="net-field-value">{delay}</span></span>
        {/* <span className="net-field">Packet Loss Rate: <span className="net-field-value">{lossPacket}</span></span> */}
        <span className="net-field">Network: <span className="net-field-value">{network}</span></span>
        {isElectron ? <span className="net-field">CPU: <span className="net-field-value">{cpu}</span></span> : null}
      </div>
      <div className="menu">
        <div className="timer">
          <Icon className="icon-time" disable />
          <span className="time">{moment.utc(time).format('HH:mm:ss')}</span>
        </div>
        <span className="menu-split" />
        <div className="btn-group">
          <Icon className="icon-setting" onClick={(evt: any) => {
            handleClick("setting");
          }}/>
          <Icon className="icon-exit" onClick={(evt: any) => {
            handleClick("exit");
          }} />
        </div>
        {isElectron ?
        <>
        <span className="menu-split" />
        <div className="menu-group">
          <Icon className="icon-minimum" icon />
          <Icon className="icon-maximum" icon />
          <Icon className="icon-close" icon />
        </div>
        </>
        : null }
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
  const cpu = 0;
  const {
    showDialog,
    removeDialog,
    exitAll,
  } = useAgoraSDK();

  const refTime = useRef<any>('init');

  const [time, updateTime] = useState<number>(0);

  const [timer, setTimer] = useState<any>(null);

  const calcDuration = (time: number) => {
    return setInterval(() => {
      refTime.current === null && updateTime(+Date.now() - time);
    }, 150, time)
  }

  const ref = useRef<boolean>(false);


  const [card, setCard] = useState<boolean>(false);

  const [rtt, updateRtt] = useState<number>(0);
  const [quality, updateQuality] = useState<string>('unknown');

  useEffect(() => {
    refTime.current = null;
    return () => {
      refTime.current = true;
      ref.current = true;
      if (timer) {
        clearInterval(timer);
        setTimer(null);
      }
    }
  }, []);

  useEffect(() => {
    if (store.global.rtcClient) {
      store.global.rtcClient.on('watch-rtt', (rtt: number) => {
        // !ref.current && dispatch({type: ActionType.UPDATE_RTT, rtt});
        !ref.current && updateRtt(rtt);
      });
      store.global.rtcClient.on('network-quality', (evt: any) => {
        const quality = NetworkQualityEvaluation(evt);
        !ref.current && updateQuality(quality);
        // !ref.current && dispatch({type: ActionType.UPDATE_QUALITY, quality});
      });
    }
  }, [store.global.rtcClient]);

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
          // console.log("exit - all");
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
      cpu={`${cpu}%`}
      showSetting={card}
      onCardConfirm={handleCardConfirm}
      handleClick={handleClick}
    />
  )
}