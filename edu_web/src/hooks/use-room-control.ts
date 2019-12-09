import { SHARE_ID } from './../utils/agora-rtc-client';
import { useHistory } from "react-router";
import { useEffect, useState, useMemo } from "react";
import { useRootContext } from "../store";
import { UserRole } from "../reducers/types";

export const roomTypes = [
  {value: 0, text: 'One-on-One', path: 'one-to-one'},
  {value: 1, text: 'Small Class', path: 'small-class'},
  {value: 2, text: 'Large Class', path: 'big-class'},
];

const useRoomControl = () => {
  const {store} = useRootContext();
  const history = useHistory();
  const [exit, setExit] = useState<boolean>(false);

  useEffect(() => {
    if (exit) {
      history.push('/');
    }
  }, [exit]);

  const handleConfirm = (evt: any) => {
    setExit(true);
  }

  const timerState = useMemo(() => {
    return store.global.timerState;
  }, [store.global.timerState]);

  const role = useMemo(() => {
    return store.user.role;
  }, [store.user.role]);

  const roomName = useMemo(() => {
    return store.room.room;
  }, [store.room.room]);

  const visibleSettingDialog = false;

  const classState = useMemo(() => {
    return store.room.classState;
  }, [store.room.classState]);

  const screenSharing = useMemo(() => {
    return store.global.screenSharing;
  }, [store.global.screenSharing]);

  const updateScreenSharedId = async () => {
      if (store.user.role === UserRole.teacher && store.global.rtmClient) {
        const sharedId = SHARE_ID;
        await store.global.rtmClient.updateChannelAttrs(store, {
          shared_uid: sharedId
        })
      }
  }
  
  return {
    handleConfirm,
    timerState,
    role,
    roomName,
    visibleSettingDialog,
    classState,
    screenSharing,
    updateScreenSharedId
  }
};
export default useRoomControl;