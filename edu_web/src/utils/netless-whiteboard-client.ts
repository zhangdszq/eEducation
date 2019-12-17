import { EventEmitter } from 'events';
import "white-web-sdk/style/index.css";
import { WhiteWebSdk, Room, DeviceType, PlayerCallbacks, ReplayRoomParams } from 'white-web-sdk';
import {get} from 'lodash';
import { isElectron } from './platform';
// import {AgoraFetch as fetch} from './fetch';

const whiteboardSdkToken = process.env.REACT_APP_NETLESS_APP_TOKEN;
const url = `${process.env.REACT_APP_NETLESS_APP_API_ENTRY}${whiteboardSdkToken}`;
const joinUrl = `${process.env.REACT_APP_NETLESS_APP_JOIN_API}${whiteboardSdkToken}`;

type NetlessRoomArgs = {
  name: string
  limit: number
  mode: string
}

export class NetlessApi {

  public client: WhiteWebSdk;

  constructor () {
    this.client = new WhiteWebSdk({
      deviceType: DeviceType.Desktop, handToolKey: " "
    });
  }

  async applyRoom (uuid?: string, rid?: string) {
    if (uuid) {
      let res = await this.sendJoinRoom(uuid, rid);
      console.log("[white] send join request", res, uuid);
      return res;
    }
    let res = await this.sendCreateRoom({name: rid ? rid : `${+Date.now()}`, limit: 100, mode: 'historied'});
    console.log("[white] send create request", res);
    return res;
  }

  async join (_uuid: string, _rid?: string): Promise<Room> {
    let {uuid, roomToken} = await this.applyRoom(_uuid, _rid);
    console.log("[white] send join websocket with uuid", uuid, _uuid, roomToken);
    return await this.client.joinRoom({
      uuid,
      roomToken,
      disableBezier: true,
    }, {
      onPhaseChanged: phase => {

      },
      onRoomStateChanged: modifyState => {

      },
      onDisconnectWithError: error => {

      },
      onKickedWithReason: reason => {

      },
      onKeyDown: event => {

      },
      onKeyUp: event => {

      },
      onHandToolActive: active => {

      },
      onPPTLoadProgress: (uuid: string, progress: number) => {

      }
    });
  }

  async sendCreateRoom ({name, limit, mode}: NetlessRoomArgs) {
    let response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name,
        limit,
        mode
      })
    });
    let json = await response.json();
    console.log('[White] sendCreateRoom: create room', json);
    return {
      uuid: get(json, 'msg.room.uuid'),
      roomToken: get(json, 'msg.roomToken')
    }
  }

  async sendJoinRoom (uuid: string, rid?: string): Promise<any> {
    let response = await fetch(
      `${joinUrl}&uuid=${uuid}`, {
        method: 'POST',
        headers: {
          "content-type": "application/json",
        },
        // body: JSON.stringify({
        //   name: `${Date.now()}`,
        //   limit: 100,
        //   // mode: 'historied'
        // })
      }
    );
    let json = await response.json();
    console.log('[White] sendJoinRoom: send join room', json);
    return {
      uuid: uuid,
      roomToken: get(json, 'msg.roomToken')
    }
  }

  async replayRoom(args: ReplayRoomParams, callback: PlayerCallbacks) {
    let retrying;
    do {
      try {
        let result = await this.client.replayRoom({
          beginTimestamp: args.beginTimestamp,
          duration: args.duration,
          room: args.room,
          roomToken: args.roomToken
        }, callback);
        retrying = false;
        return result;
      } catch (err) {
        retrying = true;
      }
    } while (retrying);
  }
}

export const apiClient = new NetlessApi();

export default class NetlessWhiteboardClient {

  public static ins: NetlessWhiteboardClient | any;
  public room: Room | any;

  public _bus: EventEmitter;

  constructor() {
    this._bus = new EventEmitter();
    this.room = null;
  }

  public on(evt: string, cb: (evt: any) => void) {
    this._bus.on(evt, cb);
  }

  async init({whiteboard_uid, rid}: {whiteboard_uid: string, rid: string}) {
    let { uuid, roomToken } = await apiClient.applyRoom(whiteboard_uid, rid);
    this.room = await apiClient.client.joinRoom({
      uuid,
      roomToken,
      disableBezier: true,
    }, {
      onPhaseChanged: phase => {

      },
      onRoomStateChanged: modifyState => {
        console.log("state ", modifyState);
        if (modifyState.zoomScale) {
          this._bus.emit("scaleChanged", modifyState.zoomScale);
        }
        if (modifyState.sceneState) {
          const newSceneState = modifyState.sceneState;
          this._bus.emit("sceneChanged", newSceneState);
        }
      },
      onDisconnectWithError: error => {

      },
      onKickedWithReason: reason => {

      },
      onKeyDown: event => {

      },
      onKeyUp: event => {

      },
      onHandToolActive: active => {

      },
      onPPTLoadProgress: (uuid: string, progress: number) => {

      }
    });
    return this.room;
  }

  async destroy() {
    if (this.room) {
      await this.room.disconnect();
    }
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