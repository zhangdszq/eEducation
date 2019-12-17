import React, { useState, useMemo, useEffect, useRef, createContext, useContext } from 'react';
import { RootStore } from '../store';
import { ActionType, UserRole } from '../reducers/types';
import NetlessWhiteboard from '../utils/netless-whiteboard-client'
import { Room, SceneState, RoomState } from 'white-web-sdk';
import GlobalStorage from '../reducers/custom-storage';
import { Subject } from 'rxjs';
import { Map } from 'immutable';
import {isEmpty, get} from 'lodash';

interface SceneFile {
  name: string
  type: string
}

export interface CustomScene {
  path: string
  rootPath: string
  file: SceneFile
  type: string
  current: boolean
  currentPage: number
  totalPage: number
}

export interface SceneResource {
  path: string
  rootPath: string
  file: SceneFile
}

const pathName = (path: string): string => {
  const reg = /\/([^\/]*)\//g;
  reg.exec(path);
  if (RegExp.$1 === "aria") {
      return "";
  } else {
      return RegExp.$1;
  }
}

export interface NetlessState {
  scenes: Map<string, CustomScene>
  currentScenePath: string
  currentHeight: number
  currentWidth: number
  dirs: SceneResource[]
  activeDir: number
  zoomRadio: number
  scale: number
}

const defaultState: NetlessState = {
  scenes: Map<string, CustomScene>(),
  currentScenePath: '',
  currentHeight: 0,
  currentWidth: 0,
  dirs: [],
  activeDir: 0,
  zoomRadio: 0,
  scale: 0,
  ...GlobalStorage.read('mediaDirs'),
}

class NetlessStateManager {
  private subject: Subject<NetlessState> | null;
  public state: NetlessState | null;

  constructor() {
    this.subject = null;
    this.state = null;
  }

  initialize() {
    this.subject = new Subject<NetlessState>();

    this.state = {
      ...defaultState,
    };
    this.subject.next(this.state);
  }

  subscribe(setState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(setState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this.subject = null;
  }

  commit (state: NetlessState) {
    this.subject && this.subject.next(state);
  }

  updateState(roomState: RoomState, file?: SceneFile) {
    if (!this.state) return;
    const path = roomState.sceneState.scenePath;
    const ppt = roomState.sceneState.scenes[0].ppt;
    const type = isEmpty(ppt) ? 'static' : 'dynamic';
    const currentPage = roomState.sceneState.index;
    const totalPage = roomState.sceneState.scenes.length;

    if (type !== 'dynamic') {
      this.state = {
        ...this.state,
        currentHeight: 0,
        currentWidth: 0
      }
    } else {
      this.state = {
        ...this.state,
        currentHeight: get(ppt, 'height', 0),
        currentWidth: get(ppt, 'width', 0)
      }
    }

    const _dirPath = pathName(path);
    const dirPath = _dirPath === "" ? "/init" : `/${_dirPath}`;

    const scenes = this.state.scenes.update(dirPath, (value: CustomScene) => {
      const sceneFile: SceneFile = {
        name: 'whiteboard',
        type: 'whiteboard'
      }
      if (file && dirPath !== "/init") {
        sceneFile.name = file.name;
        sceneFile.type = file.type;
      }

      const result = {
        ...value,
        path: dirPath,
        type: type ? type : 'static',
        currentPage,
        totalPage,
      }
      if (!value || isEmpty(value.file)) {
        result.file = sceneFile;
      }
      if (!value || isEmpty(value.rootPath)) {
        result.rootPath = roomState.sceneState.scenePath
      }
      return result;
    });

    const _dirs: SceneResource[] = [];
    scenes.forEach((it: CustomScene) => {
      _dirs.push({
        path: it.path,
        rootPath: it.rootPath,
        file: it.file
      });
    });

    const currentDirIndex = _dirs.findIndex((it: SceneResource) => it.path === dirPath);

    this.state = {
      ...this.state,
      scenes: scenes,
      currentScenePath: dirPath,
      dirs: _dirs,
      activeDir: currentDirIndex !== -1 ? currentDirIndex : 0
    }
    this.commit(this.state);
  }

  setCurrentScene(dirPath: string) {
    if (!this.state) return;

    const currentDirIndex = this.state.dirs.findIndex((it: SceneResource) => it.path === dirPath);
    this.state = {
      ...this.state,
      currentScenePath: dirPath,
      activeDir: currentDirIndex !== -1 ? currentDirIndex : 0
    }
    this.commit(this.state);
  }

  updateSceneState(sceneState: SceneState) {
    if (!this.state) return;

    const path = sceneState.scenePath;
    const currentPage = sceneState.index;
    const totalPage = sceneState.scenes.length;
    const _dirPath = pathName(path);
    const dirPath = _dirPath === "" ? "/init" : `/${_dirPath}`;

    const scenes = this.state.scenes.update(dirPath, (value) => {
      return {
        ...value,
        currentPage,
        totalPage,
      }
    });

    this.state = {
      ...this.state,
      scenes,
    }

    this.commit(this.state);
  }

  updateScale(scale: number) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      scale: scale
    }
    
    this.commit(this.state);
  }
}

export const stateManager = new NetlessStateManager();

// @ts-ignore DEBUG
window.stateManager = stateManager;

export const NetlessContext = createContext({} as NetlessState);

export const useNetless = () => useContext(NetlessContext);

export const NetlessProvider: React.FC<{}> = ({children}) => {
  const [state, setState] = useState<NetlessState>(defaultState);

  useEffect(() => {
    stateManager.subscribe((state: NetlessState) => {
      setState(state);
    })
    return () => {
      stateManager.unsubscribe();
      GlobalStorage.save('mediaDirs', {dirs: []});
    }
  }, []);

  useEffect(() => {
    GlobalStorage.save('mediaDirs', {dirs: state.dirs});
  }, [state.dirs]);

  return (
    <NetlessContext.Provider value={state}>
      {children}
    </NetlessContext.Provider>
  )
}

export default function useNetlessSDK({store, dispatch}: RootStore) {

  const netlessContext = useNetless();
  const {currentScenePath, scenes} = netlessContext;

  const current = useMemo(() => {
    return scenes.get(currentScenePath);
  }, [scenes, currentScenePath]);

  const whiteboardClient = useMemo(() => {
    return store.global.whiteboard.client;
  }, [store.global.whiteboard.client]);

  const netlessClient: Room = useMemo(() => {
    if (store.global.whiteboard.client) {
      return store.global.whiteboard.client.room;
    }
  }, [store.global.whiteboard.client]);

  const ref = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      ref.current = true;
    }
  }, []);

  useEffect(() => {
    if (netlessClient) {
      //@ts-ignore
      window.netlessClient = netlessClient;

      if (!ref.current) {
        stateManager.updateState(netlessClient.state);
        // const path = netlessClient.state.sceneState.scenePath;
        // const ppt = netlessClient.state.sceneState.scenes[0].ppt;
        // const type = _.isEmpty(ppt) ? 'static' : 'dynamic';

        // stateManager.setCurrentScene(path, netlessClient.state, type);
      }

    }
  }, [netlessClient]);

  const totalPage = useMemo(() => {
    if (!current) return 0;
    return current.totalPage;
  }, [current]);

  const currentPage = useMemo(() => {
    if (!current) return 0;
    return current.currentPage + 1;
  }, [current]);

  const addNewPage: any = (evt: any) => {
    if (!current) return;
    // const newIndex = netlessClient.state.sceneState.scenes.length;
    const newIndex = netlessClient.state.sceneState.index + 1;
    const scenePath = netlessClient.state.sceneState.scenePath;
    const currentPath = `/${pathName(scenePath)}`;
    netlessClient.putScenes(currentPath, [{}], newIndex);
    netlessClient.setSceneIndex(newIndex);
    console.log(" path ", currentPath, " scenePath ", scenePath, " index ", netlessClient.state.sceneState.index, netlessClient.state.sceneState.scenes.length);
    stateManager.updateState(netlessClient.state);
    // stateManager.setCurrentScene(current.path, netlessClient.state);
  }

  const changePage = (idx: number, force?: boolean) => {
    if (ref.current || !current) return;
    const _idx = idx -1;
    if (_idx < 0 || _idx >= current.totalPage) return;
    if (force) {
      netlessClient.setSceneIndex(_idx);
      stateManager.updateState(netlessClient.state);
      return
    }
    if (current.type === 'dynamic') {
      if (_idx > current.currentPage) {
        netlessClient.pptNextStep();
      } else {
        netlessClient.pptPreviousStep();
      }
    } else {
      netlessClient.setSceneIndex(_idx);
    }
    stateManager.updateState(netlessClient.state);

  }

  const initWhiteboard = async (id?: string) => {
    if (!store.global.rtmClient || !store.room.rid) {
      return console.warn('initWhiteboard not achieved')
    }
    try {
      const whiteboardUid = id || store.user.whiteboardId;
      dispatch({ type: ActionType.UPDATE_WHITEBOARD_CONNECT_STATE, state: 'start_connecting' });
      const whiteboard = new NetlessWhiteboard();
      whiteboard.on('sceneChanged', (newSceneState: SceneState) => {
        console.log("changed ", newSceneState, netlessClient);
        if (ref.current) return;
        stateManager.updateSceneState(newSceneState);
      });
      whiteboard.on('scaleChanged', (zoomScale: number) => {
        if (ref.current) return;
        stateManager.updateScale(zoomScale);
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
    totalPage: totalPage,
    addNewPage,
    changePage,
    room: netlessClient,
    netlessContext,
  }

}