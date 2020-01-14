import {get} from 'lodash';
import { WhiteWebSdk, ReplayRoomParams, PlayerCallbacks } from 'white-web-sdk';
import { AgoraFetch } from './fetch';

const createRoomApi = process.env.REACT_APP_NETLESS_APP_API_ENTRY as string;
const joinRoomApi = process.env.REACT_APP_NETLESS_APP_JOIN_API;
const sdkToken = process.env.REACT_APP_NETLESS_APP_TOKEN;


const url = process.env.REACT_APP_AGORA_RECORDING_SERVICE_URL as string;
const PREFIX = url.replace('%s', process.env.REACT_APP_AGORA_APP_ID as string);


export const WhiteboardAPI = {
  async createRoom ({rid, limit, mode}: any) {
    let response = await AgoraFetch(`${createRoomApi}${sdkToken}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: rid,
        limit,
        mode
      })
    });
    let json = await response.json();
    return {
      uuid: get(json, 'msg.room.uuid'),
      roomToken: get(json, 'msg.roomToken')
    }
  },

  async joinRoom (uuid: string, rid?: string): Promise<any> {
    let response = await AgoraFetch(
      `${joinRoomApi}${sdkToken}&uuid=${uuid}`, {
        method: 'POST',
        headers: {
          "content-type": "application/json",
        }
      }
    );
    let json = await response.json();
    return {
      uuid: uuid,
      roomToken: get(json, 'msg.roomToken')
    }
  },

  async replayRoom(client: WhiteWebSdk, args: ReplayRoomParams, callback: PlayerCallbacks) {
    let retrying;
    do {
      try {
        let result = await client.replayRoom({
          beginTimestamp: args.beginTimestamp,
          duration: args.duration,
          room: args.room,
          mediaURL: args.mediaURL,
          roomToken: args.roomToken,
        }, callback);
        retrying = false;
        return result;
      } catch (err) {
        retrying = true;
      }
    } while (retrying);
  }
}

export class RecordOperator {
    private readonly agoraAppId: string;
    private readonly customerId: string;
    private readonly customerCertificate: string;
    private readonly channelName: string;
    private readonly mode: string;
    private readonly recordingConfig: any;
    private readonly storageConfig: any;
    private recordId?: string;
    public resourceId?: string;
    private readonly uid: string;
    private readonly token: string | undefined = undefined;
    public constructor(
        rtcBaseConfig: {
            agoraAppId: string,
            customerId: string,
            customerCertificate: string,
            channelName: string,
            mode: string,
            token: string | undefined,
            uid: string,
        },
        recordingConfig: any,
        storageConfig: any,
        ) {
        this.agoraAppId = rtcBaseConfig.agoraAppId;
        this.customerId = rtcBaseConfig.customerId;
        this.customerCertificate = rtcBaseConfig.customerCertificate;
        this.channelName = rtcBaseConfig.channelName;
        this.recordingConfig = recordingConfig;
        this.storageConfig = storageConfig;
        this.mode = rtcBaseConfig.mode;
        this.uid = rtcBaseConfig.uid;
        this.token = rtcBaseConfig.token;
    }

    public async acquire(): Promise<void> {
      let response = await AgoraFetch(`${PREFIX}/v1/apps/${this.agoraAppId}/cloud_recording/acquire`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: this.basicAuthorization(this.customerId, this.customerCertificate),
        },
        body: JSON.stringify({
          cname: this.channelName,
          uid: this.uid,
          clientRequest: {},
        })
      });
      const res = await response.json();
      if (typeof res.resourceId === "string") {
        this.resourceId = res.resourceId;
      } else {
        throw {
          recordingErr: {
            message: 'acquire recording failed',
          },
          reason: 'resourceId is invalid',
        }
      }
    }

    public async release(): Promise<void> {
        this.resourceId = undefined;
        this.recordId = undefined;
    }


    public async start(): Promise<any> {
      if (this.resourceId === undefined) {
        throw {
          recordingErr: {
            message: 'start recording failed',
          },
          reason: 'resourceId is undefined',
        }
      }
      const response = await AgoraFetch(`${PREFIX}/v1/apps/${this.agoraAppId}/cloud_recording/resourceid/${this.resourceId}/mode/${this.mode}/start`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: this.basicAuthorization(this.customerId, this.customerCertificate),
        },
        body: JSON.stringify({
          cname: this.channelName,
          uid: this.uid,
          clientRequest: {
            token: this.token,
            recordingConfig: this.recordingConfig,
            storageConfig: this.storageConfig,
          },
        })
      });
      const res = await response.json();
      if (typeof res.sid === "string") {
          this.recordId = res.sid;
      } else {
        throw {
          recordingErr: {
            message: 'start recording failed',
          },
          reason: 'recordId is invalid',
        }
      }
      return res;
    }

    public async stop(): Promise<any> {
      if (this.resourceId === undefined) {
        throw {
          recordingErr: {
            message: 'stop recording failed',
          },
          reason: 'resourceId is undefined',
        }
      }
      if (this.recordId === undefined) {
        throw {
          recordingErr: {
            message: 'stop recording failed',
          },
          reason: 'recordId is undefined',
        }
      }
      try {
          const response = await AgoraFetch(`${PREFIX}/v1/apps/${this.agoraAppId}/cloud_recording/resourceid/${this.resourceId}/sid/${this.recordId}/mode/${this.mode}/stop`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: this.basicAuthorization(this.customerId, this.customerCertificate),
            },
            body: JSON.stringify({
              cname: this.channelName,
              uid: this.uid,
              clientRequest: {},
            })
          });
          const json = await response.json();
          return json;
      } catch (err) {
          console.log("stop", err);
      } finally {
          await this.release();
      }
    }

    public async query(): Promise<any> {
        if (this.resourceId === undefined) {
            throw {
              recordingErr: {
                message: 'query recording failed',
              },
              reason: 'resourceId is undefined',
            }
        }
        if (this.recordId === undefined) {
          throw {
            recordingErr: {
              message: 'query recording failed',
            },
            reason: 'recordId is undefined',
          }
        }
        const response = await AgoraFetch(`${PREFIX}/v1/apps/${this.agoraAppId}/cloud_recording/resourceid/${this.resourceId}/sid/${this.recordId}/mode/${this.mode}/query`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            Authorization: this.basicAuthorization(this.customerId, this.customerCertificate),
          },
        })
        const json = await response.json();
        return json;
    }

    private basicAuthorization(appId: string, appSecret: string): string {
        const plainCredentials = `${appId}:${appSecret}`;
        return `Basic ${btoa(plainCredentials)}`;
    }
}
