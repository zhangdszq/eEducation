import { RootAction } from './reducers/types';
import {RootState} from './reducers/initialize-state';
import React, { useReducer, createContext, Dispatch, useContext, useEffect } from 'react';
import {defaultState, RootReducer} from './reducers/index';
import GlobalStorage from './reducers/custom-storage';
import { HashRouter as Router, useLocation } from 'react-router-dom';
import { isElectron } from './utils/platform';

export interface RootStore {
  store: RootState
  dispatch: Dispatch<RootAction>
}

export const RootContext = createContext({} as RootStore);

export const useRootContext = () => useContext(RootContext);

export const useRootObserver = (store: RootState) => {

  const location = useLocation();

  useEffect(() => {
    console.log(' [mediaInfo] ', store.global.mediaInfo);
  }, [store.global.mediaInfo]);

  useEffect(() => {
    GlobalStorage.save('room', store.room);
    // console.log('room ', store.room.users);
    // @ts-ignore
    window.room = store.room;
  }, [store.room]);

  useEffect(() => {
    // console.log('[edu-page] do update user');
    GlobalStorage.save('user', store.user);
    // @ts-ignore
    window.user = store.user;
  }, [store.user]);

  useEffect(() => {
    // GlobalStorage.save('user', store.user);
    // console.log(store.global.messages);
    // @ts-ignore
    window.global = store.global;
    // @ts-ignore
    window.remoteStreams = store.global.remoteStreams;
  }, [store.global]);

  useEffect(() => {
    GlobalStorage.save('linkId', store.global.linkId);
  }, [store.global.linkId])

  useEffect(() => {
    // GlobalStorage.save('user', store.user);
    // console.log(store.global.messages);
    // @ts-ignore
    window.ui = store.ui;
  }, [store.ui]);

  useEffect(() => {
    GlobalStorage.save('pass', Boolean(store.global.canPass));
  }, [store.global.canPass]);
}

export const StoreContainer: React.FC<any> = ({children}: {children: any}) => {
  const [store, dispatch] = useReducer(RootReducer, defaultState);
  // @ts-ignore
  window.reducer = {
    store,
    dispatch
  }

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