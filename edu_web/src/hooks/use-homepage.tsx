import React, {useState, useEffect, useRef, useMemo} from 'react';
import {useHistory} from 'react-router';
import useToast from './use-toast';
import { useRootContext } from '../store';
import { useAgoraSDK } from './use-agora-sdk';
import { ActionType, UserRole } from '../reducers/types';
import _ from 'lodash';
import { resolveRoomPath, genUid } from '../utils/helper';


export default function useHomePage() {
  const history = useHistory();
  const {showError} = useToast();
  const {store, dispatch} = useRootContext();
  const ref = useRef<boolean>(false);
  const {initRTM} = useAgoraSDK();
  const rtmClientLock = useRef<any>(false);

  useEffect(() => {
    return () => {
      rtmClientLock.current = true;
      ref.current = true;
    }
  }, [])

  const {rid, id, account, rtmClient} = useMemo(() => {
    return {
      rid: _.get(store, 'room.rid'),
      id: _.get(store, 'user.id'),
      account: _.get(store, 'user.account'),
      rtmClient: _.get(store, 'global.rtmClient')
    }
  }, [store]);

  const [join, setJoin] = useState<boolean>(false);

  useEffect(() => {
    //
    if (!rid || !id || !account || rtmClientLock.current || !join) return;
    rtmClientLock.current = true
    initRTM().then(() => {
      // rtmClient._joined = true;
      history.push({pathname: `/classroom/${resolveRoomPath(store.room.type)}`});
    }).catch((err: any) => {
      setJoin(false);
      err.type === 'not_permitted' && showError(err.reason);
      console.warn('login failured');
      console.warn(err)
    }).finally(() => {
      rtmClientLock.current = false;
      console.log('[rtm-client] signin');
    })
  }, [rid, id, account, rtmClient, join]);

  const [roomName, setRoomName] = useState('');
  const [yourName, setYourName] = useState('');
  const [roomType, setRoomType] = useState(0);

  const [role, setRole] = useState('');

  const [required, setRequired] = useState({
    roomName: '',
    yourName: '',
    role: ''
  });

  const handleClick = (evt: any) => {
    let validProperties = {};
    if (!roomName) {
      validProperties = {...validProperties, roomName: 'Room name is required'};
    }

    if (!yourName) {
      validProperties = {...validProperties, yourName: 'Your name is required'};
    }

    if (!role) {
      validProperties = {...validProperties, role: 'Role is required'};
    }

    if (Object.keys(validProperties).length === 0) {
      const _role: UserRole = UserRole[role as keyof typeof UserRole];
      const id: string = genUid();
      dispatch({type: ActionType.ADD_ME, payload: {userName: yourName, roomName, role: _role, roomType: roomType, id}});
      setJoin(true);
      rtmClientLock.current = false;
    } else {
      setRequired(validProperties as any);
    }
  }

  const handleSetting = (evt: any) => {
    console.log('handle setting');
    history.push({pathname: `/device_test`});
  }

  return {
    handleSetting,
    handleClick,
    roomName,
    yourName,
    roomType,
    setRoomName,
    setRoomType,
    setYourName,
    role,
    setRole,
    setRequired,
    required,
    join,
    setJoin,
    store
  }
}