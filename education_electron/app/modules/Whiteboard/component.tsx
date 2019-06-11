import React, { useMemo, FunctionComponent, useState, Fragment, useEffect } from 'react';
import { RoomWhiteboard } from "white-react-sdk";
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
  const [room, setRoom] = useState<any>(null);
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
    room.insertNewPage(newPageIndex - 1);
    room.setGlobalState({
      currentSceneIndex: newPageIndex - 1
    });
  };

  const onChangePage = (index: number) => {
    if (!room) {
      return;
    }
    setCurrentPage(index);
    room.setGlobalState({
      currentSceneIndex: index - 1
    });
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
        let newGlobalState = modifyState.globalState;
        let currentSceneIndex = newGlobalState.currentSceneIndex;
        if (currentSceneIndex + 1 > totalPage) {
          setCurrentPage(currentSceneIndex + 1)
          setTotalPage(currentSceneIndex + 1)
        } else {
          setCurrentPage(currentSceneIndex + 1)
        }
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