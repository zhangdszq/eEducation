import React, { useMemo, createContext, useRef, useEffect, useContext, useState } from 'react';
import { useRootContext, refStore } from './../store';
import { UserState, GlobalState } from './../reducers/initialize-state';
import AgoraRTMClient, { RoomMessage } from '../utils/agora-rtm-client';
import { ActionType, User, UserRole, AgoraStream } from '../reducers/types';
import { APP_ID, SHARE_ID, AgoraStreamSpec } from '../utils/agora-rtc-client';
import { resolveChannelAttrs, jsonParse, resolvePeerMessage, resolveMediaState, resolveMessage } from '../utils/helper';
import { MediaInfo, RoomState } from '../reducers/initialize-state';
import { Map } from 'immutable';
import { useLocation, useHistory } from 'react-router';
import useToast from './use-toast';
import { useGlobalContext } from '../containers/global-container';
import AgoraWebClient from '../utils/agora-rtc-client';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import { usePlatform } from '../containers/platform-container';

export interface InitRTCProps {
  media: MediaInfo
  publish: boolean
  dual?: boolean
}

export enum ConnectState {
  connect,
  connected,
  disconnected
}
export interface IWindow {
  ownerName: string
  name: string
  windowId: any
  image: string
}

interface ShareWindowInfo {
  visible: boolean
  items: IWindow[]
}
export interface IAgoraSDKContext {
  rtcClient: AgoraWebClient | AgoraElectronClient
  connect: ConnectState
  shareConnect: ConnectState
  setConnect: React.Dispatch<React.SetStateAction<ConnectState>>
  setShareConnect: React.Dispatch<React.SetStateAction<ConnectState>>
  users: Map<string, User>
  room: RoomState
  user: UserState
  global: GlobalState
  canPass: boolean
  rtmClient: AgoraRTMClient | undefined
  screenSharing: boolean
  nativeWindowInfo: ShareWindowInfo
  setNativeWindowInfo:  React.Dispatch<React.SetStateAction<ShareWindowInfo>>
  addRtmClient: (client: AgoraRTMClient) => void
  removeRtmClient: () => void
  addRemoteStream: (stream: any) => void
  removeRemoteStream: (streamID: number) => void
  addLocalStream: (stream: any) => void
  removeLocalStream: () => void
  addLocalSharedStream: (stream: any) => void
  removeLocalSharedStream: () => void
  exitRTM: () => Promise<any>
  exitAll: () => Promise<any>
  initRTM: () => Promise<any>
  onApplyConfirm: () => Promise<any>
  onRejectApply: () => Promise<any>
  onCloseConfirm: () => Promise<any>
  onCancelClose: () => Promise<any>

  devices: any[]
  setDevices: React.Dispatch<React.SetStateAction<any[]>>
  shared: boolean
  setShared: React.Dispatch<React.SetStateAction<boolean>>
  memberCount: number
  setMemberCount: React.Dispatch<React.SetStateAction<number>>
}

export const AgoraSDKContext: React.Context<IAgoraSDKContext> = createContext({} as IAgoraSDKContext);

export const useAgoraSDK = () => useContext(AgoraSDKContext);

export function AgoraSDKProvider({ children }: React.ComponentProps<any>) {

  const { store, dispatch } = useRootContext();

  const addRemoteStream = (stream: AgoraStream) => dispatch({
    type: ActionType.ADD_REMOTE_STREAM,
    stream
  });

  const removeRemoteStream = (streamID: number) => dispatch({
    type: ActionType.REMOVE_REMOTE_STREAM,
    streamID
  });

  const addLocalStream = (stream: AgoraStream) => dispatch({
    type: ActionType.ADD_LOCAL_STREAM,
    stream
  });

  const removeLocalStream = () => dispatch({
    type: ActionType.REMOVE_LOCAL_STREAM
  });

  const addLocalSharedStream = (stream: AgoraStream) => dispatch({
    type: ActionType.ADD_SHARED_STREAM,
    stream
  });

  const removeLocalSharedStream = () => dispatch({
    type: ActionType.REMOVE_SHARED_STREAM
  });

  const showNotice = (peerId: number) => {
    const applyUser = refStore.users.get(`${peerId}`);
    console.log("appyUser", applyUser, refStore.users);
    if (!applyUser) return;
    dispatch({
      type: ActionType.NOTICE,
      reason: 'peer_hands_up',
      text: `"${applyUser.account}" wants to interact with you`,
    })
  }

  const removeNotice = () => {
    dispatch({
      type: ActionType.NOTICE, reason: ''
    });
    applyUid.current = 0;
  }

  const { platform } = usePlatform();
  const [connect, setConnect] = React.useState<ConnectState>(ConnectState.disconnected);
  const [shareConnect, setShareConnect] = React.useState<ConnectState>(ConnectState.disconnected);
  const location = useLocation();

  const rtcClient = React.useMemo(() => {
    if (platform === 'electron') {
      const electronClient = new AgoraElectronClient();
      return electronClient;
    }
    const webClient = new AgoraWebClient();
    return webClient;
  }, [platform]);

  const rtmClient = useMemo(() => {
    return store.global.rtmClient;
  }, [store.global.rtmClient]);

  const [mediaJoin, updateMediaJoin] = useState<boolean>(rtcClient.joined);

  useEffect(() => {
    if (!location.pathname.match(/classroom/)) return
    console.log("media join", mediaJoin, "pathname", location.pathname);
  }, [mediaJoin, location.pathname]);

  const publishLock = useRef<boolean>(false);

  useEffect(() => {
    if (!location.pathname.match(/big-class/) || store.user.role === UserRole.teacher) return
    if (store.room.linkId) return;
    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      if (!webClient.published) return;
      webClient
        .unpublishLocalStream()
        .then(() => {
          console.log("[smart-client] unpublish local stream");
        }).catch(console.warn)
    }

    if (platform === 'electron') {
      const nativeClient = rtcClient as AgoraElectronClient;
      if (!nativeClient.published) return;
      nativeClient.unpublish();
    }

  }, [store.user.role, rtcClient, location.pathname, store.room.linkId]);

  const canPublish = useMemo(() => {
    return !location.pathname.match(/big-class/) ||
      (location.pathname.match(/big-class/) && 
        (store.user.role === UserRole.teacher ||
          +store.user.id === store.room.linkId));
  }, [store.user.id, store.room.linkId, store.user.role]);

  useEffect(() => {
    // when media join
    if (!location.pathname.match(/classroom/)
      || !store.user.id
      || !store.user.role
      || !store.room.rid) {
      return
    }

    if (platform === 'web' && mediaJoin) {
      const webClient = rtcClient as AgoraWebClient;
      const uid = +store.user.id as number;
      const streamSpec: AgoraStreamSpec = {
        streamID: uid,
        video: true,
        audio: true,
        mirror: true,
        screen: false,
        microphoneId: store.global.mediaInfo.microphoneId,
        cameraId: store.global.mediaInfo.cameraId,
        audioOutput: {
          volume: store.global.mediaInfo.speakerVolume,
          deviceId: store.global.mediaInfo.speakerId
        }
      }
      if (canPublish && !publishLock.current) {
        publishLock.current = true;
        webClient
          .publishLocalStream(streamSpec)
          .then(() => {
            console.log("[smart-client] publish local stream");
          }).catch(console.warn)
          .finally(() => {
            publishLock.current = false;
          })
      }
    }

    if (platform === 'electron' && mediaJoin) {
      const nativeClient = rtcClient as AgoraElectronClient;
      if (canPublish && !publishLock.current) {
        publishLock.current = true;
        nativeClient.publish();
        publishLock.current = false;
      }
    }
  }, [mediaJoin, store.user.id, store.user.role, store.global.mediaInfo, rtcClient, location.pathname, canPublish]);

  const rtc = useRef<boolean>(false);

  useEffect(() => {
    if (!location.pathname.match(/classroom/)) return;
    if (!store.user.id || !store.user.role || !store.room.rid || !rtmClient) return;
    console.log('location.pathname', location.pathname);
    if (rtcClient) {
      if (platform === 'web') {
        const webClient = rtcClient as AgoraWebClient;
        if (webClient.joined) {
          return;
        }
        webClient.rtc.on('error', (evt: any) => {
          console.log('[smart-client] error evt', evt);
        });
        webClient.rtc.on('stream-published', ({ stream }: any) => {
          const _stream = new AgoraStream(stream, stream.getId(), true);
          addLocalStream(_stream)
        });
        webClient.rtc.on('stream-subscribed', ({ stream }: any) => {
          const streamID = stream.getId();
          // when streamID is not share_id use switch high or low stream in dual stream mode
          if (location.pathname.match(/small-class/) && streamID !== SHARE_ID) {
            if (teacher.current
              && teacher.current.id === `${streamID}`) {
              webClient.setRemoteVideoStreamType(stream, 0);
              console.log("[dual stream] set high for teacher");
            }
            else {
              webClient.setRemoteVideoStreamType(stream, 1);
              console.log("[dual stream] set low for student");
            }
          }
          const _stream = new AgoraStream(stream, stream.getId(), false);
          addRemoteStream(_stream);
        });
        webClient.rtc.on('stream-added', ({ stream }: any) => {
          webClient.subscribe(stream);
        });
        webClient.rtc.on('stream-removed', ({ stream }: any) => {
          console.log("[link] trigger stream-removed", stream.getId());
          const id = stream.getId();
          if (id === applyUid.current) {
            removeNotice();
            store.user.role === UserRole.teacher &&
            rtmClient && rtmClient.updateChannelAttrs(store, {
              link_uid: 0
            }).then(() => {
              console.log("update teacher link_uid to 0");
            }).catch(console.warn);
          }
          removeRemoteStream(stream.getId());
        });
        webClient.rtc.on('peer-leave', ({ uid }: any) => {
          console.log("[link] trigger peer-leave", uid);
          if (uid === applyUid.current) {
            removeNotice();
            store.user.role === UserRole.teacher &&
            rtmClient && rtmClient.updateChannelAttrs(store, {
              link_uid: 0
            }).then(() => {
              console.log("update teacher link_uid to 0");
            }).catch(console.warn);
          }
          removeRemoteStream(uid);
        });
        webClient.rtc.on("stream-fallback", ({ uid, attr }: any) => {
          const msg = attr === 0 ? 'resume to a&v mode' : 'fallback to audio mode';
          console.info(`stream: ${uid} fallback: ${msg}`);
        })
        rtc.current = true;
        const enableDual = Boolean(location.pathname.match(/small-class/));
        webClient.joinChannel(
          +store.user.id as number,
          store.room.rid,
          enableDual).then(() => {
            console.log("[agora-demo] join rtc media");
            updateMediaJoin(true);
            rtc.current = false;
          }).catch(console.warn);
        return () => {
          console.log("[agora-demo] remove event listener");
          !rtc.current && webClient.exit().then(() => {
            rtc.current = true;
            console.log("[agora-demo] do remove event listener");
          }).catch(console.warn)
            .finally(() => {
              updateMediaJoin(false);
              removeLocalStream();
            });
        }
      }

      if (platform === 'electron') {
        const nativeClient = rtcClient as AgoraElectronClient;
        if (nativeClient.joined) {
          console.log("[smart-client] electron joined ", nativeClient.joined);
          return;
        }
        nativeClient.on('executefailed', (...args: any[]) => {
          console.log("[native] executefailed", ...args);
        });
        nativeClient.on('error', (evt: any) => {
          console.log('error evt', evt);
        });
        nativeClient.on('stream-published', (evt: any) => {
          const stream = evt.stream;
          const _stream = new AgoraStream(stream, stream.uid, true);
          addLocalStream(_stream);
        });
        nativeClient.on('stream-subscribed', (evt: any) => {
          const stream = evt.stream;
          const _stream = new AgoraStream(stream, stream.uid, false);
          if (location.pathname.match(/small-class/) && stream.uid !== SHARE_ID) {
            if (teacher.current
              && teacher.current.id === `${stream.uid}`) {
              nativeClient.rtcEngine.setRemoteVideoStreamType(stream, 0);
              console.log("[dual stream] set high for teacher");
            }
            else {
              nativeClient.rtcEngine.setRemoteVideoStreamType(stream, 1);
              console.log("[dual stream] set low for student");
            }
          }
          addRemoteStream(_stream);
        });
        nativeClient.on('stream-removed', ({ uid }: any) => {
          if (uid === applyUid.current) {
            removeNotice();
            store.user.role === UserRole.teacher &&
            rtmClient && rtmClient.updateChannelAttrs(store, {
              link_uid: 0
            }).then(() => {
              console.log("update teacher link_uid to 0");
            }).catch(console.warn);
          }
          removeRemoteStream(uid);
        });
        const enableDual = Boolean(location.pathname.match(/small-class/));
        nativeClient.joinChannel(
          +store.user.id as number,
          store.room.rid,
          enableDual,
        );
        updateMediaJoin(true);
        return () => {
          !rtc.current && nativeClient.exit();
          !rtc.current && updateMediaJoin(false);
          !rtc.current && removeLocalStream();
        }
      }
    }
  }, [store.user.id, store.user.role, store.room.rid, location.pathname, rtcClient, rtmClient]);

  const [shared, setShared] = useState<boolean>(false);

  useEffect(() => {
    if (!location.pathname.match(/classroom/)) return;
    if (!shared && platform === 'web') return;
    if (!shared) {
      if (platform === 'electron') {
        const nativeClient = rtcClient as AgoraElectronClient;
        console.log(" nativeClient ", nativeClient.shared);
        nativeClient.shared 
          && nativeClient.stopScreenShare().then(() => {
            removeLocalSharedStream();
          }).catch(console.warn);
        return;
      }
    }

    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      webClient.startScreenShare().then(() => {
        webClient.shareClient.on('stopScreenSharing', (evt: any) => {
          console.log('stop screen share', evt);
          webClient.stopScreenShare().then(() => {
            removeLocalSharedStream();
            setShared(false);
          }).catch(console.warn).finally(() => {
            console.log('[smart-client] stop share');
          })
        })
        const localShareStream = webClient.shareClient._localStream
        const _stream = new AgoraStream(localShareStream, localShareStream.getId(), true);
        addLocalSharedStream(_stream);
      }).catch((err: any) => {
        setShared(false);
        if (err.type === 'error' && err.msg === 'NotAllowedError') {
          showToast({
            message: `You canceled screen sharing`,
            type: 'notice'
          });
        }
        if (err.type === 'error' && err.msg === 'PERMISSION_DENIED') {
          showError(`Screen Sharing Failed: ${err.msg}`);
        }
        console.warn(err);
      }).finally(() => {
        console.log('[smart-client] start share');
      })
      return () => {
        console.log("before shared change", shared);
        shared && webClient.stopScreenShare().then(() => {
          removeLocalSharedStream();
          setShared(false);
        }).catch(console.warn).finally(() => {
          console.log('[smart-client] stop share');
        })
      }
    }
  }, [shared, location.pathname, rtcClient]);

  const [nativeWindowInfo, setNativeWindowInfo] = React.useState<ShareWindowInfo>({
    visible: false,
    items: []
  });

  const { removeDialog } = useGlobalContext();

  const ref = useRef<boolean>(false);

  useEffect(() => {
    window.onbeforeunload = () => {
      dispatch({ type: ActionType.UPDATE_CAN_PASS, pass: true });
    }
    if (!location.pathname.match(/classroom/)) {
      dispatch({ type: ActionType.UPDATE_CAN_PASS, pass: false });
    }
  }, [location]);

  const pathname = useRef<string>(location.pathname);
  const history = useHistory();
  const { showToast, showError } = useToast();

  useEffect(() => {
    return () => {
      ref.current = true;
      pathname.current = '';
    }
  }, []);

  const { room, user, global } = useMemo(() => {
    return store;
  }, [store]);

  const users = useMemo(() => {
    return room.users;
  }, [room.users]);

  const teacher = useRef<any>(null);

  useEffect(() => {
    if (!users.count()) return;
    const _teacher = users.find((it: User) => it.role === UserRole.teacher)
    if (_teacher) {
      teacher.current = _teacher;
    }
  }, [users]);

  useEffect(() => {
    pathname.current = location.pathname
  }, [location]);

  const canPass = useMemo(() => {
    return store.global.canPass;
  }, [store.global.canPass]);

  const exitRTM = async () => {
    if (rtmClient) {
      try {
        dispatch({ type: ActionType.LOADING, payload: true });
        await rtmClient.exit(rtmClient._currentChannelName);
      } catch (err) {
        throw err;
      } finally {
        rtmClient.destroy();
        dispatch({ type: ActionType.REMOVE_RTM_CLIENT });
        console.log('quit rtm client >>>> ');
        dispatch({ type: ActionType.LOADING, payload: false });
      }
    }
  }

  const exitAll = async () => {
    try {
      dispatch({ type: ActionType.LOADING, payload: true });
      await exitRTM();
    } catch (err) {
      throw err;
    } finally {
      dispatch({ type: ActionType.CLEAR_STATE });
      dispatch({ type: ActionType.LOADING, payload: false });
    }
  };

  const screenSharing = useMemo(() => {
    return store.global.screenSharing;
  }, [store.global.screenSharing])

  const addRtmClient = (client: AgoraRTMClient) => dispatch({ type: ActionType.ADD_RTM_CLIENT, client });
  const removeRtmClient = () => dispatch({ type: ActionType.REMOVE_RTM_CLIENT });

  const isLargeClass = useMemo(() => {
    return location.pathname.match(/big-class/) !== null;
  }, [location]);

  const linkUid = useRef<number>(0);
  const applyUid = useRef<number>(0);
  const rtmLock = useRef<boolean>(false);
  const msgLock = useRef<boolean>(false);
  const rtcLock = useRef<boolean>(false);

  const rtcClientRef = useRef<any>(null);

  useEffect(() => {
    return () => {
      msgLock.current = true;
      rtmLock.current = true;
      rtcLock.current = true;
      applyUid.current = 0;
      linkUid.current = 0;
    }
  }, []);

  useEffect(() => {
    if (store.room.linkId) {
      msgLock.current = true;
    } else {
      msgLock.current = false;
      applyUid.current = 0;
    }
  }, [store.room.linkId]);

  const canApply = (): boolean => {
    if (rtmLock.current) {
      return false;
    }
    return true;
  }

  const onApplyConfirm = async () => {
    if (!rtmClient || !canApply()) return;

    console.log(" when apply confirm linkId ", applyUid.current);
    try {
      rtmLock.current = true
      await rtmClient.sendPeerMessage(`${applyUid.current}`, {
        cmd: RoomMessage.acceptCoVideo
      });
      await rtmClient.updateChannelAttrs(store, {
        link_uid: applyUid.current
      });
      removeDialog();
      removeNotice();
    } catch (err) {
      throw err;
    } finally {
      rtmLock.current = false;
    }
  }

  const onRejectApply = async () => {
    if (!rtmClient || !canApply()) return;

    console.log(" when apply confirm linkId ", applyUid.current);
    try {
      rtmLock.current = true;
      await rtmClient.sendPeerMessage(`${applyUid.current}`, {
        cmd: RoomMessage.rejectCoVideo
      })
      applyUid.current = 0;
      removeDialog();
      removeNotice();
    } catch (err) {
      throw err;
    } finally {
      rtmLock.current = false;
    }
  }


  const onCloseConfirm = async () => {
    if (rtmClient) {
      await rtmClient.updateChannelAttrs(store, {
        link_uid: 0
      });
    }
  }

  const onCancelClose = async () => {
    if (rtmClient) {
      await rtmClient.updateChannelAttrs(store, {
        link_uid: 0
      });
    }
  }

  const [memberCount, setMemberCount] = useState<number>(0);

  const initRTM = async () => {
    try {
      dispatch({ type: ActionType.LOADING, payload: true });

      const rtmClient = new AgoraRTMClient(APP_ID);
      rtmClient.on('ConnectionStateChanged', ({ newState, reason }: { newState: string, reason: string }) => {
        console.log(`newState: ${newState} reason: ${reason}`);
        if (reason === 'LOGIN_FAILURE') {
          dispatch({
            type: ActionType.ADD_TOAST, toast: {
              message: "login failure",
              type: "rtmClient"
            }
          });
          exitAll().then(() => {
            console.log("[exit rtm] success");
          }).catch((err: any) => {
            console.warn('[exit rtm]', err);
          }).finally(() => {
            history.push('/');
            console.log("[rtc-client] exit all");
          })
          return;
        }
        if (reason === 'REMOTE_LOGIN' || newState === 'ABORTED') {
          dispatch({
            type: ActionType.ADD_TOAST, toast: {
              message: "kick",
              type: "rtmClient"
            }
          });
          exitAll().then(() => {
            console.log("[exit rtm] success");
          }).catch((err: any) => {
            console.warn('[exit rtm]', err);
          }).finally(() => {
            history.push('/');
            console.log("[rtc-client] exit all");
          })
          console.error('probably kick off by remote side');
        }
      });
      rtmClient.on("MessageFromPeer", ({ message: { text }, peerId, props }: { message: { text: string }, peerId: string, props: any }) => {
        const body = resolvePeerMessage(text);
        resolveMessage(peerId, body);
        const cmd = body.cmd;
        // handle media state
        if ([
          RoomMessage.muteVideo, RoomMessage.muteAudio, RoomMessage.muteChat,
          RoomMessage.unmuteVideo, RoomMessage.unmuteAudio, RoomMessage.unmuteChat
        ].indexOf(cmd) !== -1) {
          const mediaState = resolveMediaState(body);
          dispatch({ type: ActionType.UPDATE_LOCAL_MEDIA_STATE, mediaState, peerId });
        }

        const largeClass = pathname.current.match(/big-class/) !== null;
        // console.log('[MessageFromPeer] body, ', pathname.current, largeClass, cmd, peerId, linkUid.current, applyId);

        if (largeClass
          && [RoomMessage.applyCoVideo,
          RoomMessage.acceptCoVideo,
          RoomMessage.rejectCoVideo,
          RoomMessage.cancelCoVideo].indexOf(body.cmd) !== -1) {
          // when received accept msg
          if (RoomMessage.acceptCoVideo === body.cmd) {
            showToast({
              message: `U can interactive with teacher now.`,
              type: 'notice'
            })
          }
          console.log(`role. ${store.user.role} current applyUid.current`, applyUid.current, " peerId ", peerId, cmd, store.room.users.toJSON());
          if (store.user.role === UserRole.teacher) {
            if (cmd === RoomMessage.applyCoVideo && !applyUid.current && peerId) {
              applyUid.current = +peerId as number;
              showNotice(applyUid.current);
              return;
            }
            if (cmd === RoomMessage.cancelCoVideo) {
              // when teacher receive cancel co-video
              if (refStore.rtmClient
                && refStore.linkId) {
                refStore.rtmClient.updateChannelAttrs(store, {
                  link_uid: 0,
                }).then(() => {
                }).catch(console.warn);
              }
            }
            return;
          }

          const teacher = store.room.users.get(`${peerId}`);
          console.log("teacher ", teacher);
          if (store.user.role === UserRole.student) {
            const user = store.room.users.get(`${peerId}`);
            if (cmd === RoomMessage.rejectCoVideo) {
              user && console.warn(`[rtm-message] reject you interactive apply, By Peer User: ${user.account}, reject your apply`);
              showToast({
                message: `Teacher reject your apply.`,
                type: 'notice'
              })
              dispatch({ type: ActionType.UPDATE_APPLY, apply: false });
            }
            console.log("received cancel message from teacher", rtcClientRef.current, rtcLock.current);
            if (cmd === RoomMessage.cancelCoVideo
              && !rtcLock.current) {
              user && console.warn(`[rtm-message] cancel you interactive apply, By Peer User: ${user.account}, reject your apply`);
              rtcLock.current = true;
            }
          }
        }
      });
      rtmClient.on("AttributesUpdated", (attributes: object) => {
        const channelAttrs = resolveChannelAttrs(attributes);
        dispatch({ type: ActionType.UPDATE_CHANNEL_ATTRS, attrs: channelAttrs });
        console.log('[rtm-client] updated resolved attrs', channelAttrs);
        console.log('[rtm-client] updated origin attributes', attributes);
      });
      rtmClient.on("MemberJoined", (memberId: string) => {
      });
      rtmClient.on("MemberLeft", (memberId: string) => {
      });
      rtmClient.on("MemberCountUpdated", (count: number) => {
        !ref.current && setMemberCount(count);
      });
      rtmClient.on("ChannelMessage", ({ memberId, message }: { message: { text: string }, memberId: string }) => {
        const msg = jsonParse(message.text);
        const chatMessage = {
          account: msg.account,
          text: msg.content,
          link: msg.link,
          ts: +Date.now(),
          id: memberId,
        }
        console.log('[rtm-client] add message', chatMessage);
        dispatch({ type: ActionType.ADD_MESSAGE, message: chatMessage });
      });
      const { type, rid } = room;
      const { role, account, id } = user;
      console.log('[rtm-client] params', {
        roomType: type, room: rid, id, role
      });
      if (!rid || !id) {
        history.push('/');
        return;
      }
      await rtmClient.loginAndJoin({
        roomType: type, room: rid, id, role
      }, canPass);

      const userAttrs = {
        ...user,
        ...room
      };
      await rtmClient.updateChannelAttrs(store, {
        id,
        role,
        audio: user.audio,
        video: user.video,
        chat: user.chat,
      });
      dispatch({ type: ActionType.ADD_USER, user: userAttrs });
      dispatch({ type: ActionType.ADD_RTM_CLIENT, client: rtmClient });
    } catch (err) {
      rtmClient && rtmClient.destroy();
      throw err;
    } finally {
      dispatch({ type: ActionType.LOADING, payload: false });
    }
  }

  const [devices, setDevices] = useState<any[]>([]);

  const value = {
    room,
    user,
    global,
    users,
    canPass,
    rtmClient,
    addRemoteStream,
    removeRemoteStream,
    addLocalStream,
    removeLocalStream,
    addLocalSharedStream,
    removeLocalSharedStream,
    exitRTM,
    exitAll,
    rtcClient,
    connect,
    setConnect,
    shareConnect,
    setShareConnect,
    devices,
    setDevices,
    screenSharing,
    initRTM,
    addRtmClient,
    removeRtmClient,
    onApplyConfirm,
    onRejectApply,
    onCloseConfirm,
    onCancelClose,
    shared,
    setShared,
    memberCount,
    setMemberCount,
    nativeWindowInfo,
    setNativeWindowInfo,
  }

  return (
    <AgoraSDKContext.Provider value={value}>
      {children}
    </AgoraSDKContext.Provider>
  )
}