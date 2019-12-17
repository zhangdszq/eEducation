import { RootAction, User } from './reducers/types';
import {RootState} from './reducers/initialize-state';
import React, { useReducer, createContext, Dispatch, useContext, useEffect } from 'react';
import {defaultState, RootReducer} from './reducers/index';
import GlobalStorage from './reducers/custom-storage';
import { HashRouter as Router, useLocation } from 'react-router-dom';
import { isElectron } from './utils/platform';
import {Map} from 'immutable';
import AgoraRTMClient from './utils/agora-rtm-client';

export interface RootStore {
  store: RootState
  dispatch: Dispatch<RootAction>
}

type refStore = {
  users: Map<string, User>
  linkId: number
  rtmClient?: AgoraRTMClient
}

export const refStore: refStore = {
  users: Map<string, User>(),
  linkId: 0,
  rtmClient: undefined,
}

export const RootContext = createContext({} as RootStore);

export const useRootContext = () => useContext(RootContext);

export const useRootObserver = (store: RootState) => {

  useEffect(() => {
    refStore.users = store.room.users;
    refStore.linkId = store.room.linkId;
    GlobalStorage.save('room', store.room);
    // @ts-ignore
    window.room = store.room;
    // @ts-ignore
    window.refStore = refStore;
  }, [store.room]);

  useEffect(() => {
    // console.log('[edu-page] do update user');
    GlobalStorage.save('user', store.user);
    // @ts-ignore
    window.user = store.user;
  }, [store.user]);

  useEffect(() => {
    // @ts-ignore
    window.global = store.global;
    refStore.rtmClient = store.global.rtmClient;
    // @ts-ignore
    window.refStore = refStore;
    // @ts-ignore
    window.remoteStreams = store.global.remoteStreams;
  }, [store.global]);

  useEffect(() => {
    GlobalStorage.save('linkId', store.global.linkId);
  }, [store.global.linkId])

  useEffect(() => {
    GlobalStorage.save('pass', Boolean(store.global.canPass));
  }, [store.global.canPass]);
}

export const StoreContainer: React.FC<any> = ({children}: {children: any}) => {
  const [store, dispatch] = useReducer(RootReducer, defaultState);

  const value: RootStore = {
    store,
    dispatch
  };

  return (
    <Router>
      <RootContext.Provider value={value}>
        {children}
      </RootContext.Provider>
    </Router>
  )
}