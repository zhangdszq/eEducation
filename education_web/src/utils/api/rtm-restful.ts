import {get, isEmpty} from 'lodash';
import { AgoraFetch } from '../fetch';
import GlobalStorage from '../custom-storage';

const isDev = process.env.NODE_ENV !== 'production' ? true : false;
const url = isDev ? `${window.location.protocol}//${window.location.host}/dev/v2/project/%s/rtm` : process.env.REACT_APP_AGORA_RTM_SERVICE_ENDPOINT as string;
const PREFIX = url.replace('%s', process.env.REACT_APP_AGORA_APP_ID as string);

type queryChannelMessage = {
  rid: string,
  startTime: string,
  endTime: string
}

type AgoraChannelMessage = {
  dst: string
  message_type: string
  ms: number
  payload: string
  src: string
}

export class RTMRestful {
  startTime: number
  endTime: number
  source: string
  destination: string
  customerId: string
  appSecret: string
  totalCount: number
  offset: number
  limit: number

  constructor(customerId: string, appSecret: string) {
    this.startTime = 0
    this.endTime = 0
    this.source = ''
    this.destination = ''
    this.customerId = customerId
    this.appSecret = appSecret
    this.totalCount = 0
    this.offset = 0
    this.limit = 100
    // this.agoraAppId = appId
  }

  private basicAuthorization(): string {
    const plainCredentials = `${this.customerId}:${this.appSecret}`;
    return `Basic ${btoa(plainCredentials)}`;
  }

  async fetchChannelMessageCount({rid, startTime, endTime}: queryChannelMessage) {
    const response: Response = await AgoraFetch(`${PREFIX}/message/history/count?destination=${rid}&start_time=${startTime}&end_time=${endTime}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.basicAuthorization(),
      },
    });
    const json = await response.json();
    const count = get(json, 'count');
    this.totalCount = count;
    this.offset = 0;
    this.limit = 100;
    return count;
  }

  async fetchChannelMessages({
    rid, startTime, endTime
  }: queryChannelMessage): Promise<AgoraChannelMessage[]> {
    const responseA: Response = await AgoraFetch(`${PREFIX}/message/history/query`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.basicAuthorization(),
      },
      body: JSON.stringify({
          filter: {
            source: "",
            destination: rid,
            start_time: startTime,
            end_time: endTime
          },
          offset: this.offset,
          limit: this.limit,
          order: "asc"
        })
    });
    const jsonA = await responseA.json();
    const location = get(jsonA, 'location');
    if (isEmpty(location)) {
      throw `location from agora rtm endpoint must be present`
    }
    const respB = await AgoraFetch(`${PREFIX}/message/history/query/${location.replace('~/rtm/message/history/query/', '')}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.basicAuthorization(),
      },
    });
    const jsonB = await respB.json();
    const messages = get(jsonB, 'messages');
    return messages;
  }

  async getAllChannelMessages(params: queryChannelMessage) {
    let count = await this.fetchChannelMessageCount(params);
    if (count === 0) {
      return {
        count: 0,
        messages: []
      }
    }
    let totalCount = this.totalCount;
    let channelMessages: AgoraChannelMessage[] = [];
    while (totalCount > 0) {
      const messages = await this.fetchChannelMessages(params);
      channelMessages = channelMessages.concat(...messages);
      if (totalCount >= messages.length) {
        totalCount = totalCount - messages.length;
        this.offset = channelMessages.length;
        this.limit = 100;
      }
    }
    console.log("getAllChannelMessages, channelMessages: ", channelMessages);
    GlobalStorage.save('channelMessages', channelMessages);
    return GlobalStorage.read('channelMessages');
  }
}

//@ts-ignore
window.RTMRestful = new RTMRestful(process.env.REACT_APP_AGORA_CUSTOMER_ID as string, process.env.REACT_APP_AGORA_CUSTOMER_CERTIFICATE as string);