import React, { useMemo, FunctionComponent, useState, Fragment, useEffect } from 'react';
import { RoomWhiteboard, Room } from "white-react-sdk";
import "white-web-sdk/style/index.css";
import { Spin, Pagination } from "antd";
import NativeStreamPlayer from "../../components/NativeStreamPlayer";

import Toolbar from "./Toolbar";
import WhiteboardAPI from "./whiteboard.api";
import WindowPicker from "./WindowPicker";
import encode from './Base64Encode'

interface WhiteboardComponentProps {
  floatButtonGroup?: Element[];
  onStartScreenShare: (windowId: number) => void;
  onStopScreenShare: () => any;
  role: ClientRole;
  shareStream?: any;
  // channel: string;
  uuid: string;
  roomToken: string;
  rtcClient: any
}

const WhiteboardComponent: FunctionComponent<
  WhiteboardComponentProps
> = props => {
  const [room, setRoom] = useState<Room|null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPage, setTotalPage] = useState(1);
  const [windowList, setWindowList] = useState([])

  useEffect(() => {
    subscribeWhiteboardEvents();
    if (props.uuid && props.roomToken) {
      WhiteboardAPI.join(props.uuid, props.roomToken)
    }
    // initWhiteboard(props.channel, props.uuid);

    return () => {
      WhiteboardAPI.removeAllListeners();
    }
  }, [props.uuid, props.roomToken])

  const setMemberState = (action: any) => {
    if (!room) {
      return;
    }
    room.setMemberState(action);
  };

  const onAddPage = () => {
    if (!room) {
      return;
    }
    const newPageIndex = totalPage + 1;
    const newTotalPage = totalPage + 1;
    setCurrentPage(newPageIndex);
    setTotalPage(newTotalPage);
    room.putScenes('/', [{}], newPageIndex - 1);
    const currentScene = room.state.sceneState.scenes[newPageIndex - 1]
    room.setScenePath('/'+currentScene.name);
  };

  const onChangePage = (index: number) => {
    if (!room) {
      return;
    }
    setCurrentPage(index);
    const currentScene = room.state.sceneState.scenes[index - 1]
    room.setScenePath('/'+currentScene.name);
  };

  const handleShareScreen = () => {
    if (props.shareStream) {
      props.onStopScreenShare();
    } else {
      const windowInfoList = props.rtcClient.getScreenWindowsInfo();
      const windowList = windowInfoList.map((item: any) => {
        return {
          ownerName: item.ownerName,
          name: item.name,
          windowId: item.windowId,
          image: encode(item.image)
        }
      })
      setWindowList(windowList)
    }
  };

  const handleSelectScreen = (windowId: number) => {
    setWindowList([])
    props.onStartScreenShare(windowId)
  }



  const subscribeWhiteboardEvents = () => {
    WhiteboardAPI.on("whiteStateChanged", (args: any) => {
      const { readyState, room } = args;
      setRoom(room)
    });
    WhiteboardAPI.on("roomStateChanged", (modifyState: any) => {
      if (modifyState.globalState) {
        // globalState changed
        return;
      }
      if (modifyState.memberState) {
        // memberState changed
        // let newMemberState = modifyState.memberState;
        return;
      }
      if (modifyState.broadcastState) {
        // broadcastState changed
        // let broadcastState = modifyState.broadcastState;
        return;
      }
      if (modifyState.sceneState) {
        let newSceneState = modifyState.sceneState;
        let currentSceneIndex = newSceneState.index;
        let currentScenesCount = newSceneState.scenes.length;
        setCurrentPage(currentSceneIndex+1)
        setTotalPage(currentScenesCount)
        return;
      }
    });
  };

  return (
    <div className="board-container">
      {/* whiteboard  */}
      <div
        className="board"
        id="whiteboard"
        style={{ display: props.shareStream ? "none" : "block" }}
      >
        {/* intializing mask */}
        {!room ? (
          <div className="board-mask">
            <Spin />
          </div>
        ) : (
          <Fragment>
            <div
              style={{
                display: props.role === 0 ? "flex" : "none"
              }}
              className="board-mask"
            />
            <RoomWhiteboard
              room={room}
              style={{ width: "100%", height: "100vh" }}
            />
            <div className="pagination">
              <Pagination
                defaultCurrent={1}
                current={currentPage}
                total={totalPage}
                pageSize={1}
                onChange={onChangePage}
              />
            </div>
          </Fragment>
        )}
      </div>

      {/* shareboard */}
      {props.shareStream && <NativeStreamPlayer className="board" rtcClient={props.rtcClient} stream={props.shareStream}/>}

      {/* toolbar */}
      {props.role !== 0  && (
        <Toolbar
          tools={{share: props.role === 2}}
          onChangeMemberState={setMemberState}
          readyState={ Boolean(room) }
          onAddPage={onAddPage}
          onSwitchScreenShare={handleShareScreen}
        />
      )}

      {/* window picker */}
      {windowList.length && (
        <WindowPicker windowList={windowList} onCancel={() => {setWindowList([])}} onSubmit={handleSelectScreen} />
      )}

      {/* additional float button */}
      <div className="float-button-group">{props.floatButtonGroup}</div>
    </div>
  );
};

export default WhiteboardComponent