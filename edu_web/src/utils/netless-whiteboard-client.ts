import { EventEmitter } from 'events';
import "white-web-sdk/style/index.css";
import { WhiteWebSdk, Room } from 'white-web-sdk';

const whiteboardSdkToken = process.env.REACT_APP_NETLESS_APP_TOKEN;
const url = `${process.env.REACT_APP_NETLESS_APP_API_ENTRY}${whiteboardSdkToken}`;
const joinUrl = `${process.env.REACT_APP_NETLESS_APP_JOIN_API}${whiteboardSdkToken}`;

export default class NetlessWhiteboardClient {

  public static ins: NetlessWhiteboardClient | any;
  public room: Room | any;

  public _bus: EventEmitter;

  constructor() {
    this._bus = new EventEmitter();
  }

  public on(evt: string, cb: (evt: any) => void) {
    this._bus.on(evt, cb);
  }

  async init(params: any) {
    const whiteWebSdk = new WhiteWebSdk({
      urlInterrupter: url => url,
    });
    let uuid = '';
    let roomToken = '';
    let api = url;
    const body: any = {
      method: 'POST',
      headers: {
        "content-type": "application/json",
      }
    }
    if (params.whiteboard_uid) {
      uuid = params.whiteboard_uid;
      api = `${joinUrl}&uuid=${uuid}`
    } else {
      body.body = JSON.stringify({
        name: params.rid,
        limit: 100
      })
    }
    let response = await fetch(api, body);
    let json = await response.json();
    if (!uuid) uuid = json.msg.room.uuid;
    roomToken = json.msg.roomToken;
    this.room = await whiteWebSdk.joinRoom({
      uuid,
      roomToken,
      disableBezier: true
    }, {
      onRoomStateChanged: (modifyState) => {
        // 只有发生改变的字段，才存在
        // if (modifyRoomState.globalState) {
        //   // 完整的 globalState 
        //   const newGlobalState = modifyRoomState.globalState;
        // }
        // if (modifyRoomState.memberState) {
        //   const newMemberState = modifyRoomState.memberState;
        // }
        if (modifyState.sceneState) {
          const newSceneState = modifyState.sceneState;
          this._bus.emit("sceneChanged", newSceneState);
        }
        // if (modifyRoomState.broadcastState) {
        //   const broadcastState = modifyRoomState.broadcastState;
        // }
      },
      // 白板连接状态改变, 具体状态如下:
      onPhaseChanged: function (phase) {
        // "connecting",
        // "connected",
        // "reconnecting",
        // "disconnecting",
        // "disconnected",
      },
    });
    return this.room;
  }

  async destroy() {
    await this.room.disconnect();
    this._bus.removeAllListeners();
  }

  static async init(params: any) {
    let ins = new NetlessWhiteboardClient();
    let res = await ins.init(params);
    this.ins = ins;
    return res;
  }

  static async destroy() {
    await this.ins.destroy();
  }

}