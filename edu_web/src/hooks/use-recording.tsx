import React from 'react';
import { Subject } from 'rxjs';
import { Map } from 'immutable';
import { AgoraFetch } from '../utils/fetch';
import { APP_ID } from '../utils/agora-rtc-client';
import { get, isEmpty} from 'lodash';
import GlobalStorage from '../reducers/custom-storage';

export const RECORDING_ID = 1;

const RECORDING_SERVICE_URL = '/v1/';

const mode = 'individual';

const API_URL = RECORDING_SERVICE_URL.replace('%s', APP_ID);

const customerId = process.env.REACT_APP_AGORA_CUSTOMER_ID;
const customerCertificate = process.env.REACT_APP_AGORA_CUSTOMER_CERTIFICATE;
const plainCredentails = `${customerId}:${customerCertificate}`;
const AuthorizationKey = btoa(plainCredentails);

const storageConfig = {
  vendor: get(process, 'env.REACT_APP_AGORA_VENDOR', 2),
  region: get(process, 'env.REACT_APP_AGORA_REGION', 0),
  bucket: get(process, 'env.REACT_APP_AGORA_BUCKET'),
  accessKey: get(process, 'env.REACT_APP_AGORA_ACCESSKEY'),
  secretKey: get(process, 'env.REACT_APP_AGORA_SECRETKEY'),
}

type RecordingState = {
  recording: boolean
  startTime: number
  endTime: number
  roomUUID: string
  roomToken: string
  rid: string
  recordId: string
  resourceId: string
  resourceStatus: string
}

const defaultState: RecordingState = {
  recording: false,
  startTime: 0,
  endTime: 0,
  roomUUID: '',
  roomToken: '',
  rid: '',
  resourceId: '',
  resourceStatus: '',
  ...GlobalStorage.read("classRecording")
}

class RecordingController {
  private subject: Subject<RecordingState> | null;
  public state: RecordingState | null;
  public recordingConfig: any = {};
  public storageConfig: any = {};

  constructor() {
    this.subject = null;
    this.state = null;
  }

  initialize() {
    this.subject = new Subject<RecordingState>();

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
    this.clearStorage();
    this.subject && this.subject.unsubscribe();
    this.subject = null;
  }

  commit (state: RecordingState) {
    this.subject && this.subject.next(state);
  }

  updateRoom(uuid: string, rid: string) {
    if(!this.state) return;
    this.state = {
      ...this.state,
      roomUUID: uuid,
      rid,
    }
    this.commit(this.state);
  }

  clearStorage () {
    if (!this.state) return;
    this.state = {
      startTime: 0,
      endTime: 0,
      roomUUID: '',
      recordId: '',
      resourceId: '',
      recording: false,
      resourceStatus: 'end',
      rid: '',
      roomToken: '',
    }
    // GlobalStorage.save('classRecording', this.state);
  }

  clearRecording(): any {
    if (!this.state) return

    const endTime = this.state.endTime;
    const startTime = this.state.startTime;
    const roomUUID = this.state.roomUUID;
    // const {endTime, startTime, roomUUID} = this.state;
    this.state = {
      ...this.state,
      endTime: 0,
      startTime: 0,
      recording: false,
    }

    this.commit(this.state);

    return {endTime, startTime, roomUUID};
  }

  updateRecording(recording: boolean) {
    if (!this.state) return;
    const timeType = recording === true ? 'startTime' : 'endTime';
    if (recording === true) {
      this.state = {
        ...this.state,
        startTime: +Date.now(),
        recording: true,
      }
    } else {
      this.state = {
        ...this.state,
        endTime: +Date.now(),
        recording: false,
      }
    }
    this.commit(this.state);
  }

  async acquire() {

    if (!this.state) return;

    const {rid} = this.state;

    const ACQUIRE_API = `${API_URL}acquire`;

    const body = JSON.stringify({
      cname: rid,
      uid: `${RECORDING_ID}`,
      clientRequest: {}
    })

    const input = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `${AuthorizationKey}`
      },
      body
    }

    const response = await AgoraFetch(ACQUIRE_API, input);
    const json = await response.json();
    const _resourceId = get(json, 'resourceId', '');
    this.state = {
      ...this.state,
      rid: rid,
      resourceId: _resourceId,
      resourceStatus: 'acquire',
    }
    this.commit(this.state);
    if (isEmpty(_resourceId)) {
      throw new Error("acquire resource error");
    }
  }

  async query () {
    if (!this.state) return;
    const { resourceId, recordId }= this.state;

    const QUERY_URL = `${API_URL}resourceid/${resourceId}/sid/${recordId}/mode/${mode}/query`;
    const input = {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `${AuthorizationKey}`
      },
    }
    const response = await AgoraFetch(QUERY_URL, input);
    let json = await response.json();

    const _resourceId = get(json, 'resourceId', '');
    if (isEmpty(_resourceId)) {
      throw new Error("query resource error");
    }

    this.state = {
      ...this.state,
      resourceId: _resourceId,
      resourceStatus: 'query',
    }
    
    this.commit(this.state);
  }

  async start(uid: string) {

    if (!this.state) return;

    const {resourceId, recordId, rid} = this.state;
    if (!resourceId) {
      throw new Error("call 'acquire' method acquire resource must be success");
    }

    const START_API = `${API_URL}resourceid/${resourceId}/mode/${mode}/start`;
    const response = await AgoraFetch(START_API,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `${AuthorizationKey}`
      },
      body: JSON.stringify({
        cname: rid,
        uid: `${RECORDING_ID}`,
        clientRequest: {
          recordingConfig: {
              subscribeVideoUids: [uid],
              subscribeAudioUids: [uid],
              subscribeUidGroup: 1,
          },
          storageConfig
        }
      })
    });

    const json = await response.json();

    const code: number | null = get(json, 'code', null);

    if (code === 53) {
      return await this.stop();
    }

    const _recordId = get(json, 'sid', '');

    if (isEmpty(_recordId)) {
      await this.stop();
    }

    this.state = {
      ...this.state,
      recordId: _recordId,
      resourceStatus: 'start',
    }

    this.commit(this.state);

  }

  async stop () {
    if(!this.state) return;
    const {resourceId, recordId, rid} = this.state;
  
    const STOP_API = `${API_URL}resourceid/${resourceId}/sid/${recordId}/mode/${mode}/stop`;
    try {
      const response = await AgoraFetch(
        STOP_API,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `${AuthorizationKey}`
          },
          body: JSON.stringify({
            cname: rid,
            uid: `${RECORDING_ID}`,
            clientRequest: {}
          })
        });
      const json = await response.json();
      const fileList = get(json, 'serverResponse.fileList');

      this.state = {
        ...this.state,
        resourceStatus: 'end',
      }
      this.commit(this.state);
      } catch (err) {
        console.warn("stop", err);
      } finally {
      }
  }

  async begin (rid: string, uid: string) {
    await this.acquire();
    await this.start(uid);
  }

  async end () {
    await this.query();
    await this.stop();
  }

  startRecording () {
    if (!this.state) return;
    this.state = {
      ...this.state,
      recording: true,
      startTime: +Date.now(),
    };

    this.commit(this.state);
  }

  stopRecording () {
    if (!this.state) return;

    this.state = {
      ...this.state,
      recording: false,
      endTime: +Date.now(),
    };
    this.commit(this.state);
  }


  async startOrStop (uid: string) {
    if (!this.state) return null;
    const {recording, resourceId, recordId, rid} = this.state;
    if (recording) {
      await this.end();
    } else {
      await this.begin(rid, uid);
    }
  }

  setEndTime(endTime: number) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      endTime
    }
    this.commit(this.state);
  }

  setRoom(uuid: string, token: string, rid: string, startTime: number) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      roomUUID: uuid,
      roomToken: token,
      rid,
      startTime
    }
    this.commit(this.state);
  }
}

export const recording = new RecordingController();

export const RecordingContext = React.createContext({} as RecordingState);

export const useRecording = () => React.useContext(RecordingContext);

export const RecordingProvider: React.FC<any> = ({children}: any) => {

  const [state, setState] = React.useState<RecordingState>(defaultState);

  React.useEffect(() => {
    recording.subscribe((state: any) => {
      setState(state);
    });
    return () => {
      recording.unsubscribe();
    }
  }, []);

  return (
    <RecordingContext.Provider value={state}>
      {children}
    </RecordingContext.Provider>
  )
}