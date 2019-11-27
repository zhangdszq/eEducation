import { useState, useMemo, useEffect, useRef } from 'react';
import { RootStore } from '../store';
import { ActionType, UserRole } from '../reducers/types';
import NetlessWhiteboard from '../utils/netless-whiteboard-client'
import { Room } from 'white-web-sdk';

export default function useNetlessSDK({store, dispatch}: RootStore) {

  const [currentPage, setCurrentPage] = useState<number>(0);
  const [totalPage, setTotalPage] = useState<number>(0);

  const whiteboardClient = useMemo(() => {
    return store.global.whiteboard.client;
  }, [store.global.whiteboard.client]);

  const room: Room = useMemo(() => {
    if (store.global.whiteboard.client) {
      return store.global.whiteboard.client.room;
    }
  }, [store.global.whiteboard.client]);

  useEffect(() => {
    if (room && currentPage === 0 && totalPage === 0) {
      setCurrentPage(room.state.sceneState.index+1);
      setTotalPage(room.state.sceneState.scenes.length);
    }
  }, [room]);

  const ref = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      ref.current = true;
    }
  }, []);

  const addNewPage: any = (evt: any) => {
    room.putScenes('/', [{}], totalPage+1);
    const currentScene = room.state.sceneState.scenes[totalPage];
    room.setScenePath(`/${currentScene.name}`);
  }

  const changePage = (idx: number) => {
    const _idx = idx -1;
    if (_idx < 0 || _idx >= totalPage) return;
    const currentScene = room.state.sceneState.scenes[_idx];
    room.setScenePath('/'+currentScene.name);
  }

  const initWhiteboard = async (id?: string) => {
    if (!store.global.rtmClient || !store.room.rid) {
      return console.warn('initWhiteboard not achieved')
    }
    try {
      const whiteboardUid = id || store.user.whiteboardId;
      dispatch({ type: ActionType.UPDATE_WHITEBOARD_CONNECT_STATE, state: 'start_connecting' });
      const whiteboard = new NetlessWhiteboard();
      whiteboard.on("sceneChanged", (newSceneState: any) => {
        console.log("[netless] current scene state", newSceneState);
        if (ref.current) return;
        setTotalPage(newSceneState.scenes.length);
        setCurrentPage(newSceneState.index+1);
      });
      const room = await whiteboard.init({
        whiteboard_uid: whiteboardUid,
        rid: store.room.rid
      });
      dispatch({ type: ActionType.UPDATE_WHITEBOARD_UID, uid: room.uuid });
      if (store.user.role === UserRole.teacher) {
        await store.global.rtmClient.updateChannelAttrs(store, {
          whiteboard_uid: room.uuid,
        });
      }
      dispatch({ type: ActionType.ADD_WHITEBOARD, client: whiteboard });
    } catch (err) {
      throw err;
    } finally {
      dispatch({ type: ActionType.UPDATE_WHITEBOARD_CONNECT_STATE, state: 'done' });
    }
  };

  const exitWhiteboard = async () => {
    try {
      if (store.global.whiteboard.client) {
        await store.global.whiteboard.client.destroy();
      }
    } catch (err) {
      throw err;
    } finally {
      dispatch({ type: ActionType.REMOVE_WHITEBOARD });
    }
  };

  const reinitWhiteboard = async (id: string) => {
    if (store.global.rtmClient && store.room.rid) {
      try {
        await exitWhiteboard();
        await initWhiteboard(id);
      } catch (err) {
        throw err;
      } finally {
        dispatch({ type: ActionType.UPDATE_WHITEBOARD_CONNECT_STATE, state: 'done' });
      }
    }
  }

  return {
    initWhiteboard,
    exitWhiteboard,
    reinitWhiteboard,
    whiteboardClient,
    currentPage: currentPage,
    totalPage,
    addNewPage,
    changePage,
    room,
  }

}