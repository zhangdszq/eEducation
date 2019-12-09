import {useEffect, useRef, useMemo} from 'react';
import {useRootContext} from '../store';
import { UserRole } from '../reducers/types';

export default function useChatControl () {

  const lock = useRef<boolean>(false);

  useEffect(() => {
    lock.current = false;
    return () => {
      lock.current = true;
    }
  }, []);

  const {store} = useRootContext();

  const muteControl = useMemo(() => {
    return store.user.role === UserRole.teacher;
  }, [store.user.role]);

  const muteChat: boolean = useMemo(() => {
    return Boolean(store.room.muteChat);
  }, [store.room.muteChat]);

  const chat: boolean = useMemo(() => {
    return Boolean(store.user.chat);
  }, [store.user.chat]);

  const disableChat: boolean = useMemo(() => {
    if (store.user.role !== UserRole.teacher && (muteChat || !chat)) return true;
    return false;
  }, [muteChat, chat, store.user.role]);

  return {
    chat,
    disableChat,
    muteControl,
    muteChat,
    handleMute (type: string) {
      if (!lock.current) {
        if (store.global.rtmClient) {
          lock.current = true;
          console.log("type === mute", type, type === 'mute' ? 1 : 0);
          store.global.rtmClient.updateChannelAttrs(store, {
            mute_chat: type === 'mute' ? 1 : 0
          }).then(() => {
            lock.current = false
            console.log('mute all success');
          }).catch((err: any) => {
            lock.current = false
            console.warn(err);
          })
        }
      }

    }
  }
}