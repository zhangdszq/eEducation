import React, { useMemo, useEffect, useState, useRef } from 'react';
import Whiteboard from './whiteboard';
import VideoPlayer from '../components/video-player';
import Control from './whiteboard/control';
import { useRootContext } from '../store';
import { ActionType, UserRole } from '../reducers/types';
import useStream from '../hooks/use-streams';
import { useLocation } from 'react-router';
import useNetlessSDK from '../hooks/use-netless-sdk';
import { useAgoraSDK } from '../hooks/use-agora-sdk';
import Tools from './whiteboard/tools';
import { SketchPicker } from 'react-color';
import { usePlatform } from '../containers/platform-container';
import { AgoraElectronClient } from '../utils/agora-electron-client';

interface MediaBoardProps {
  handleClick?: (type: string) => void
  children?: any
}

export default function MediaBoard ({
  handleClick,
  children
}: MediaBoardProps) {
  const {store, dispatch} = useRootContext();
  
  const role = useMemo(() => {
    return store.user.role;
  }, [store.user.role]);

  const {
    initWhiteboard,
    exitWhiteboard,
    reinitWhiteboard,
    currentPage,
    totalPage,
    addNewPage,
    changePage,
    room,
  } = useNetlessSDK({store, dispatch});

  const ref = useRef<any>(false);

  const {
    setShared,
    removeLocalSharedStream,
    setNativeWindowInfo,
    rtcClient
  } = useAgoraSDK();

  const {
    platform
  } = usePlatform();

  const [pageTool, setPageTool] = useState<string>('');

  useEffect(() => {
    ref.current = false;
    return () => {
      ref.current = true;
      exitWhiteboard().then(() => {
      }).catch((err: any) => {
        console.error(err);
      })
    }
  }, []);

  const connect = useRef<string>('disconnected');

  useEffect(() => {
    if (!ref.current
      && connect.current === 'disconnected'
      && store.global.rtmClient
      && store.global.whiteboard.state === '') {
      connect.current = 'connecting'
      initWhiteboard().then(() => {
        connect.current = 'connected'
      }).catch((err: any) => {
        connect.current = 'disconnected'
        console.warn(err);
      })
      return;
    }

    if (!ref.current && connect.current === 'connected'
      && store.global.whiteboard.client
      && store.user.whiteboardId
      && store.room.whiteboardId
      && store.user.whiteboardId !== store.room.whiteboardId
    ) {
      connect.current = 'reconnect'
    }

    if (!ref.current
      && connect.current === 'reconnect' && store.global.whiteboard.state === 'done') {
      connect.current = 'reconnecting';
      reinitWhiteboard(store.room.whiteboardId).then(() => {
        connect.current = 'connected';
      }).catch((err: any) => {
        connect.current = 'disconnected';
        console.warn(err);
      })
    }
  }, [store.global.whiteboard, store.room.whiteboardId, store.global.rtmClient]);

  const {sharedStream} = useStream();

  const share = useRef<any>(null);

  useEffect(() => {
    share.current = null;
    return () => {
      share.current = true;
    }
  }, []);

  const handlePageTool: any = (evt: any, type: string) => {
    setPageTool(type);
    if (type === 'first_page') {
      changePage(1);
    }

    if (type === 'last_page') {
      changePage(totalPage);
    }

    if (type === 'prev_page') {
      changePage(currentPage-1);
    }

    if (type === 'next_page') {
      changePage(currentPage+1);
    }

    if (type === 'screen_sharing') {
      setShared(true);

      if (platform === 'electron') {
        setNativeWindowInfo({
          visible: true,
          items: (rtcClient as AgoraElectronClient).getScreenShareWindows()
        })
      }
    }

    if (type === 'quit_screen_sharing') {
      removeLocalSharedStream();
      setShared(false);
    }

    if (type === 'peer_hands_up') {
      dispatch({type: ActionType.ADD_DIALOG, dialog: {
        visible: true,
        type: 'apply',
        desc: `${store.ui.notice.text}`,
      }})
    }

    if (handleClick) {
      handleClick(type);
    }
  }

  const isHost = useMemo(() => {
    if (store.user.id === store.global.linkId) {
      return true;
    }
    return false;
  }, [store.user.id, store.global.linkId]);
  
  const location = useLocation();

  const showControl: boolean = useMemo(() => {
    if (store.user.role === UserRole.teacher) return true;
    if (location.pathname.match(/big-class/)) {
      if (store.user.role === UserRole.student) {
        return true;
      }
    }
    return false;
  }, [location, store.user.role]);

  useEffect(() => {
    if (location.pathname.match(/big-class/)
    && !store.ui.dialog.visible) {
      setPageTool('');
    }
  }, [location, store.ui.dialog.visible]);


const items = [
  {
    name: 'selector'
  },
  {
    name: 'pencil'
  },
  {
    name: 'text'
  },
  {
    name: 'eraser'
  },
  {
    name: 'color_picker'
  },
  // {
  //   name: 'extra_file'
  // },
  {
    name: 'add'
  }
];

  const toolItems = useMemo(() => {
    return items.filter((item: any) => {
      if (role === 'teacher') return item;
      if (['add'].indexOf(item.name) === -1) {
        return item;
      }
    })
  }, []);

  const [tool, setTool] = useState<string | any>('pencil');

  const [visible, toggleVisible] = useState(false);

  const handleToolClick = (evt: any, name: string) => {
    if (!room) return;
    setTool(name);
    if (name === 'color_picker') {
      toggleVisible(!visible);
      return;
    }
    visible && toggleVisible(false);
    if (name === 'add' && addNewPage) {
      addNewPage();
      return;
    }
    room.setMemberState({currentApplianceName: name});
  }

  const onColorChanged = (color: any) => {
    if (!room) return;
    const {rgb} = color;
    const {r, g, b} = rgb;
    room.setMemberState({
      strokeColor: [r, g, b]
    });
  }
  
  return (
    <div className="media-board">
      {sharedStream ? 
        <VideoPlayer
          id={`${store.room.sharedId}`}
          domId={`shared-${store.room.sharedId}`}
          className={'screen-sharing'}
          streamID={sharedStream.streamID}
          stream={sharedStream.stream}
          video={true}
          audio={true}
          local={sharedStream.local}
        />
        :
        <Whiteboard
          room={room}
        />
      }
      <div className="layer">
        {!sharedStream ? 
        <>
          <Tools
          items={toolItems}
          currentTool={tool}
          handleToolClick={handleToolClick} />
          {visible ?
            <SketchPicker
              color={room.state.memberState.strokeColor}
              onChangeComplete={onColorChanged} />
          : null}
        </> : null}
        {children ? children : null}
      </div>
      { showControl ?
      <Control
        notice={store.ui.notice}
        role={role}
        sharing={Boolean(sharedStream)}
        current={pageTool}
        currentPage={currentPage}
        totalPage={totalPage}
        isHost={isHost}
        onClick={handlePageTool}/> : null }
    </div>
  )
}