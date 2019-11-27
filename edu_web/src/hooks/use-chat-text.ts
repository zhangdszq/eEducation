import { useState, useMemo } from 'react';
import { useRootContext } from '../store';
import { ActionType, User } from '../reducers/types';

export default function useChatText () {
  const {store, dispatch} = useRootContext();
  const [value, setValue] = useState('');

  const roomName = useMemo(() => {
    return store.room.room;
  }, [store.room.room]);

  const role = useMemo(() => {
    return store.user.role;
  }, [store.user.role]);

  const messages = useMemo(() => {
    return store.global.messages;
  }, [store.global.messages]);

  const sendMessage = async (evt: any) => {
    if (store.global.rtmClient && store.user.id) {
      if (!store.user.chat || Boolean(store.room.muteChat)) return console.warn("chat already muted");
      await store.global.rtmClient.sendChannelMessage(JSON.stringify({
        account: store.user.account,
        content: value
      }));
      const message = {
        account: store.user.account,
        id: store.user.id,
        text: value,
        ts: +Date.now()
      }
      dispatch({type: ActionType.ADD_MESSAGE, message});
      setValue('');
    }
  }

  const handleChange = (evt: any) => {
    setValue(evt.target.value.slice(0, 100));
  }
  const list = useMemo(() => {
    if (store.room.users) {
      return store.room.users.toArray()
      .map(([_, user]: [string, User]) => {
        return user;
      })
    }
    return [];
  }, [store.room.users]);

  return {
    list,
    role,
    messages,
    sendMessage,
    value,
    handleChange,
    roomName
  }
}