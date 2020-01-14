import React, { useState, useEffect, useRef } from 'react';
import { Theme, FormControl } from '@material-ui/core';
import {makeStyles} from '@material-ui/core/styles';
import Button from '../components/custom-button';
import RoleRadio from '../components/role-radio';
import Icon from '../components/icon';
import FormInput from '../components/form-input';
import FormSelect from '../components/form-select';
import { isElectron } from '../utils/platform';
import { usePlatform } from '../containers/platform-container';
import {useHistory} from 'react-router-dom';
import { roomStore } from '../stores/room';
import { genUid } from '../utils/helper';
import MD5 from 'js-md5';
import { globalStore } from '../stores/global';

export const roomTypes = [
  {value: 0, text: 'One-to-One', path: 'one-to-one'},
  {value: 1, text: 'Small Class', path: 'small-class'},
  {value: 2, text: 'Large Class', path: 'big-class'},
];

const useStyles = makeStyles ((theme: Theme) => ({
  formControl: {
    minWidth: '240px',
    maxWidth: '240px',
  }
}));

type SessionInfo = {
  roomName: string
  roomType: number
  yourName: string
  role: string
}

const defaultState: SessionInfo = {
  roomName: '',
  roomType: 0,
  role: '',
  yourName: '',
}

function HomePage() {
  const classes = useStyles();

  const history = useHistory();

  const handleSetting = (evt: any) => {
    history.push({pathname: `/device_test`});
  }

  const {
    HomeBtn
  } = usePlatform();

  const ref = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      ref.current = true;
    }
  }, []);

  const [session, setSessionInfo] = useState<SessionInfo>(defaultState);

  const [required, setRequired] = useState<any>({} as any);

  const handleSubmit = () => {
    if (!session.roomName) {
      setRequired({...required, roomName: 'missing room name'});
      return;
    }

    if (!session.yourName) {
      setRequired({...required, yourName: 'missing your name'});
      return;
    }

    if (!session.role) {
      setRequired({...required, role: 'missing role'});
      return;
    }

    if (!roomTypes[session.roomType]) return;
    const path = roomTypes[session.roomType].path
    const payload = {
      uid: genUid(),
      rid: `${session.roomType}${MD5(session.roomName)}`,
      role: session.role,
      roomName: session.roomName,
      roomType: session.roomType,
      video: 1,
      audio: 1,
      chat: 1,
      account: session.yourName,
      token: '',
      boardId: '',
      linkId: 0,
      sharedId: 0,
      lockBoard: 0,
    }
    ref.current = true;
    globalStore.showLoading();
    roomStore.loginAndJoin(payload).then(() => {
      roomStore.updateSessionInfo(payload);
      history.push(`/classroom/${path}`);
    }).catch((err: any) => {
      if (err.reason) {
        globalStore.showToast({
          type: 'rtmClient',
          message: err.reason
        })
      } else {
        globalStore.showToast({
          type: 'rtmClient',
          message: 'login failure, please checkout ur network'
        })
      }
      console.warn(err);
    })
    .finally(() => {
        ref.current = false;
        globalStore.stopLoading();
    })
  }

  return (
    <div className={`flex-container ${isElectron ? 'draggable' : 'home-cover-web' }`}>
      {isElectron ? null : 
      <div className="web-menu">
        <div className="web-menu-container">
          <div className="short-title">
            <span className="title">Agora Education</span>
            <span className="subtitle">Powered by agora.io</span>
          </div>
          <Icon className="icon-setting" onClick={handleSetting}/>
        </div>
      </div>
      }
      <div className="custom-card">
        <div className="flex-item cover">
          {isElectron ? 
          <>
          <div className="short-title">
            <span className="title">Agora Education</span>
            <span className="subtitle">Powered by agora.io</span>
          </div>
          <div className="cover-placeholder"></div>
          </>
          : <div className="cover-placeholder-web"></div>
          }
        </div>
        <div className="flex-item card">
          <div className="position-top card-menu">
            <HomeBtn handleSetting={handleSetting}/>
          </div>
          <div className="position-content flex-direction-column">
            <FormControl className={classes.formControl}>
              <FormInput Label={"Room Name"} value={session.roomName} onChange={
                (val: string) => {
                  setSessionInfo({
                    ...session,
                    roomName: val
                  });
                }}
                requiredText={required.roomName}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormInput Label={"Your Name"} value={session.yourName} onChange={
                (val: string) => {
                  setSessionInfo({
                    ...session,
                    yourName: val
                  });
                }}
                requiredText={required.yourName}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={"Room Type"}
                value={session.roomType}
                onChange={(evt: any) => {
                  setSessionInfo({
                    ...session,
                    roomType: evt.target.value
                  });
                }}
                items={roomTypes}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <RoleRadio value={session.role} onChange={(evt: any) => {
                 setSessionInfo({
                   ...session,
                   role: evt.target.value
                 });
              }} requiredText={required.role}></RoleRadio>
            </FormControl>
            <Button name={"Join"} onClick={handleSubmit}/>
          </div>
        </div>
      </div>
    </div>
  )
}
export default React.memo(HomePage);