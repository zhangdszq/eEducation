
import React, { useMemo, createContext, useRef, useEffect, useContext, useState } from 'react';
import { useRootContext } from './../store';
import { UserState, GlobalState } from './../reducers/initialize-state';
import AgoraRTMClient, { RoomMessage } from '../utils/agora-rtm-client';
import { ActionType, LoginInfo, User, UserRole } from '../reducers/types';
import AgoraRTCClient, { APP_ID, SHARE_ID } from '../utils/agora-rtc-client';
import { resolveChannelAttrs, jsonParse, resolvePeerMessage, resolveMediaState, resolveMessage } from '../utils/helper';
import { MediaInfo, RoomState } from '../reducers/initialize-state';
import { Map } from 'immutable';
import { useLocation, useHistory } from 'react-router';
import useToast from './use-toast';

export interface InitRTCProps {
  media: MediaInfo
  publish: boolean
  dual?: boolean
}

export interface AgoraSDKInvoke {
  users: Map<string, User>
  room: RoomState
  user: UserState
  global: GlobalState
  canPass: boolean
  rtcClient: AgoraRTCClient | undefined
  shareClient: AgoraRTCClient | undefined
  rtmClient: AgoraRTMClient | undefined
  sharedStream: any
  screenSharing: boolean

  showDialog: (val: {type: string, desc: string}) => void
  removeDialog: () => void
  addMe: (login: LoginInfo) => void

  addRtcClient: (client: AgoraRTCClient) => void
  removeRtcClient: () => void
  addRtmClient: (client: AgoraRTMClient) => void
  removeRtmClient: () => void
  addRemoteStream: (stream: any) => void
  removeRemoteStream: (streamID: number) => void
  addLocalStream: (stream: any) => void
  removeLocalStream: () => void
  addLocalSharedStream: (stream: any) => void
  removeLocalSharedStream: () => void
  exitRTC: () => Promise<any>
  exitShareRTC: () => Promise<any>
  exitRTM: () => Promise<any>
  exitAll: () => Promise<any>
  initRTC: (props: InitRTCProps) => Promise<any>
  reInitRTC: (props: InitRTCProps) => Promise<any>
  initRTM: () => Promise<any>
  initShareRTC: () => Promise<any>
  onApplyConfirm: () => Promise<any>
  onRejectApply: () => Promise<any>
  onCloseConfirm: () => Promise<any>
  onCancelClose: () => Promise<any>
  updateGlobalLinkId: (peerId: string) => void
}

export const AgoraSDKContext = createContext({} as AgoraSDKInvoke);

export const useAgoraSDK = () => useContext(AgoraSDKContext);

export function AgoraSDKProvider ({children}: {children: any}) {

  const ref = useRef<boolean>(false);

  const location = useLocation();

  const pathname = useRef<string>(location.pathname);
  const history = useHistory();
  const {showToast, showError} = useToast();

  useEffect(() => {
    return () => {
      ref.current = true;
      pathname.current = '';
    }
  }, []);

  const {store, dispatch} = useRootContext();

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

  const rtcClient = useMemo(() => {
    return global.rtcClient;
  }, [global.rtcClient]);

  const rtmClient = useMemo(() => {
    return global.rtmClient;
  }, [global.rtmClient]);

  const shareClient = useMemo(() => {
    return global.shareClient;
  }, [global.shareClient]);

  const sharedStream = useMemo(() => {
    return global.sharedStream;
  }, [global.sharedStream]);

  const addRemoteStream = (stream: any) => dispatch({
    type: ActionType.ADD_REMOTE_STREAM,
    stream
  })

  const removeRemoteStream = (streamID: number) => dispatch({
    type: ActionType.REMOVE_REMOTE_STREAM,
    streamID
  })

  const addLocalStream = (stream: any) => dispatch({
    type: ActionType.ADD_LOCAL_STREAM,
    stream
  })

  const removeLocalStream = () => dispatch({
    type: ActionType.REMOVE_LOCAL_STREAM
  })

  const addLocalSharedStream = (stream: any) => dispatch({
    type: ActionType.ADD_SHARED_STREAM,
    stream
  })

  const removeLocalSharedStream = () => dispatch({
    type: ActionType.REMOVE_SHARED_STREAM
  })

  const exitRTC = async () => {
    if (rtcClient) {
      try {
        await rtcClient.exit();
      } finally {
        rtcClient.destroy();
        rtcClient.destroyClient();
        dispatch({ type: ActionType.REMOVE_ALL_REMOTE_STREAMS });
        dispatch({ type: ActionType.REMOVE_LOCAL_STREAM });
        dispatch({ type: ActionType.REMOVE_RTC_CLIENT });
      }
    }
  }

  const exitShareRTC = async () => {
    if (shareClient) {
      try {
        console.log("do exit shareClient");
        await shareClient.exit();
      } catch (err) {
        throw err
      } finally {
        shareClient.destroy();
        shareClient.destroyClient();
        dispatch({ type: ActionType.REMOVE_SHARED_STREAM });
        dispatch({ type: ActionType.REMOVE_SHARE_RTC_CLIENT });
      }
    }
  };

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
        dispatch({ type: ActionType.LOADING, payload: false });
      }
    }
  }


  const exitAll = async () => {
    try {
      dispatch({ type: ActionType.LOADING, payload: true });
      if (shareClient) {
        await exitShareRTC();
      }
      await exitRTC();
      await exitRTM();
    } catch (err) {
      throw err;
    } finally {
      dispatch({ type: ActionType.CLEAR_STATE });
      dispatch({ type: ActionType.LOADING, payload: false });
    }
  };

  const initRTC = async ({ media, publish }: InitRTCProps) => {
    try {
      const _rtcClient = new AgoraRTCClient();
      _rtcClient.on('error', (evt: any) => {
        console.log('error evt', evt);
      });
      _rtcClient.on('stream-published', (evt: any) => {
        addLocalStream(evt.stream);
      });
      _rtcClient.on('stream-subscribed', (evt: any) => {
        const streamID = evt.stream.getId();
        // when streamID is not share_id use switch high or low stream in dual stream mode
        if (location.pathname.match(/small-class/) && streamID !== SHARE_ID) {
          if (teacher.current 
            && teacher.current.id === `${streamID}`) {
            _rtcClient.setRemoteVideoStreamType(evt.stream, 0);
            console.log("[dual stream] set high for teacher");
          }
          else {
            _rtcClient.setRemoteVideoStreamType(evt.stream, 1);
            console.log("[dual stream] set low for student");
          }
        }
        addRemoteStream(evt.stream);
      });
      _rtcClient.on('stream-added', (evt: any) => {
        _rtcClient.subscribe(evt.stream);
      });
      _rtcClient.on('stream-removed', (evt: any) => {
        removeRemoteStream(evt.stream.getId());
      });
      _rtcClient.on('peer-online', (evt: any) => {
        // console.log('peer-online evt', evt);
      });
      _rtcClient.on('peer-leave', (evt: any) => {
        removeRemoteStream(evt.uid);
      });
      _rtcClient.on("stream-fallback", ({uid, attr}: any) => {
        const msg = attr === 0 ? 'resume to a&v mode' : 'fallback to audio mode';
        console.info(`stream: ${uid} fallback: ${msg}`);
      })
      await _rtcClient.initClient(APP_ID);
      const dualEnable: boolean = location.pathname.match(/small-class/) ? true : false;
      await _rtcClient.joinChannel(store.user.streamID, store.room.rid, dualEnable);
      if (publish) {
        await _rtcClient.publishStream({
          ...media,
          video: true,
          audio: true
        });
      }

      dispatch({ type: ActionType.ADD_RTC_CLIENT, client: _rtcClient });
    } catch (err) {
      throw err;
    }
  };

  const reInitRTC = async (rtcProps: InitRTCProps) => {
    try {
      dispatch({ type: ActionType.LOADING, payload: true });
      if (shareClient) {
        await exitShareRTC();
      }
      await exitRTC();
      await initRTC(rtcProps);
    } catch (err) {
      throw err
    } finally {
      dispatch({ type: ActionType.LOADING, payload: false });
    }
  }

  const screenSharing = useMemo(() => {
    return store.global.screenSharing;
  }, [store.global.screenSharing])

  const initShareRTC = async () => {
    try {
      dispatch({ type: ActionType.LOADING, payload: true });
      const _shareClient = new AgoraRTCClient();
      _shareClient.on('stopScreenSharing', (evt: any) => {
        dispatch({ type: ActionType.UPDATE_SCREEN_SHARING, sharing: false });
      });
      _shareClient.on('stream-published', (evt: any) => {
        const stream = evt.stream;
        addLocalSharedStream(stream);
      });
      await _shareClient.publishScreenShare(store.room.rid);

      dispatch({ type: ActionType.ADD_SHARE_RTC_CLIENT, client: _shareClient });
    } catch (err) {
      if (err.type === 'error' && err.message === 'NotAllowedError') {
        return err;
      }
      throw err;
    } finally {
      dispatch({ type: ActionType.LOADING, payload: false });
    }
  };

  const showDialog = (val: { type: string, desc: string }) =>
    dispatch({
      type: ActionType.ADD_DIALOG, dialog: {
        visible: true,
        ...val
      }
    });

  const removeDialog = () => dispatch({ type: ActionType.REMOVE_DIALOG })
  const addMe = (login: LoginInfo) => dispatch({ type: ActionType.ADD_ME, payload: login });
  const addRtcClient = (client: AgoraRTCClient) => dispatch({ type: ActionType.ADD_RTC_CLIENT, client });
  const removeRtcClient = () => dispatch({ type: ActionType.REMOVE_RTC_CLIENT });
  const addRtmClient = (client: AgoraRTMClient) => dispatch({ type: ActionType.ADD_RTM_CLIENT, client });
  const removeRtmClient = () => dispatch({ type: ActionType.REMOVE_RTM_CLIENT });

  const isLargeClass = useMemo(() => {
    return location.pathname.match(/big-class/) !== null;
  }, [location]);

  const [applyId, updateApplyId] = useState<string>('');

  useEffect(() => {
    if (!isLargeClass ||
      store.user.role !== UserRole.teacher ||
      store.ui.notice.reason || 
      msgLock.current !== 'processing') return;

    const applyUser = store.room.users.get(`${applyId}`); 

    if (applyUser) {
      dispatch({type: ActionType.NOTICE, reason: 'peer_hands_up', text: `"${applyUser.account}" wants to interact with you`});
    }
  }, [isLargeClass, applyId, store.ui.dialog.visible])

  const linkUid = useRef<string>('');
  const rtmLock = useRef<boolean>(false);
  const msgLock = useRef<string>('ready');
  const rtcLock = useRef<boolean>(false);

  const rtcClientRef = useRef<any>(null);

  useEffect(() => {
    return () => {
      msgLock.current = 'closed'
      linkUid.current = ''
      rtmLock.current = true;
      rtcLock.current = true;
    }
  }, []);

  // @ts-ignore
  window.locks = {
    msgLock,
    linkUid,
    rtmLock,
    rtcLock,
  }

  useEffect(() => {
    // @ts-ignore
    window.ids = {
      applyId,
      linkId: store.global.linkId
    }
  }, [applyId, store.global.linkId]);

  useEffect(() => {
    // if (location.pathname.match(/big-class/)) {
    location.pathname.match(/big-class/) &&console.info("[RoomMessage] is bigclass");
    linkUid.current = '';
    msgLock.current = 'ready';
    rtmLock.current = false;
    rtcLock.current = false;
    updateApplyId('');
    teacher.current = null;
    // }
  }, [location]);

  useEffect(() => {
    rtcClientRef.current = store.global.rtcClient;
  }, [store.global.rtcClient]);

  useEffect(() => {
    if (!store.global.linkId) {
      updateApplyId('');
      linkUid.current = '';
      msgLock.current = 'ready';
      return;
    }
    linkUid.current = store.global.linkId;
  }, [store.global.linkId]);

  const updateGlobalLinkId = (peerId: string) => dispatch({type: ActionType.UPDATE_LINK_UID, peerId})

  useEffect(() => {
    if (location.pathname.match(/big-class/) && linkUid.current) {
      console.log("linkUid changed ", linkUid.current);
      if (store.user.role === UserRole.teacher) {
        const stream = store.global.remoteStreams.get(linkUid.current);
        console.log("stream changed", stream, linkUid.current);
        if (stream && !store.global.linkId) {
          updateGlobalLinkId(linkUid.current);
        }
        if (!stream) {
          updateGlobalLinkId('');
        }
      }
    }
  }, [store.global.remoteStreams]);

  const canApply = (): boolean => {
    if (rtmLock.current || msgLock.current !== 'processing') {
      return false;
    }
    return true;
  }

  const onApplyConfirm = async () => {
    if (!rtmClient || !canApply()) return;
    try {
      rtmLock.current = true
      await rtmClient.sendPeerMessage(applyId, {
        cmd: RoomMessage.acceptCoVideo
      });
      msgLock.current = 'processing';
      removeDialog();
      dispatch({type: ActionType.NOTICE, reason: ''});
      linkUid.current = applyId;
    } catch(err) {
      throw err;
    } finally {
      rtmLock.current = false;
    }
  }

  const onRejectApply = async () => {
    if (!rtmClient || !canApply()) return;
    try {
      rtmLock.current = true;
      await rtmClient.sendPeerMessage(applyId,{
        cmd: RoomMessage.rejectCoVideo
      })
      removeDialog();
      updateApplyId('');
      dispatch({type: ActionType.NOTICE, reason: ''});
      msgLock.current = 'ready';
      linkUid.current = '';
    } catch(err) {
      throw err;
    } finally {
      rtmLock.current = false;
    }
  }


  const onCloseConfirm = async () => {
    updateGlobalLinkId('');
  }

  const onCancelClose = async () => {

  }

  const initRTM = async () => {
      try {
        dispatch({ type: ActionType.LOADING, payload: true });
        const rtmClient = new AgoraRTMClient(APP_ID);
        rtmClient.on('ConnectionStateChanged', ({ newState, reason }: { newState: string, reason: string }) => {
          console.log(`newState: ${newState} reason: ${reason}`);
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
          // @ts-ignore
          window.body = body
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
          console.log('[MessageFromPeer] body, ', pathname.current, largeClass, cmd, peerId, linkUid.current, applyId);
  
          if (largeClass
            && [RoomMessage.applyCoVideo,
              RoomMessage.acceptCoVideo,
              RoomMessage.rejectCoVideo,
              RoomMessage.cancelCoVideo].indexOf(body.cmd) !== -1) {
            console.log("store.global.linkId", store.global.linkId, body);
            // when received accept msg
            if (RoomMessage.acceptCoVideo === body.cmd) {
              msgLock.current = 'processing';
              showToast({
                message: `U can interactive with teacher now.`,
                type: 'notice'
              })
              updateGlobalLinkId(store.user.id);
            }
            console.log('[rtm-client] apply message received, msgLock: ', msgLock.current, ' user role: ', store.user.role);
            if (store.user.role === UserRole.teacher && msgLock.current !== 'ready') {
              console.warn('msgLock.current is not ready', msgLock.current);
              return ;
            }
            console.log('[rtm-client] msgLock.current is ready, current: ', msgLock.current, linkUid.current);
            if (store.user.role === UserRole.teacher) {
              if (cmd === RoomMessage.applyCoVideo && !linkUid.current) {
                linkUid.current = peerId;
                updateApplyId(peerId);
                msgLock.current = 'processing'
                return;
              }
              if (cmd === RoomMessage.cancelCoVideo) {
                // when teacher receive cancel covideo
                if (
                  store.user.role === UserRole.teacher
                  && linkUid.current
                  && store.global.rtmClient
                  && store.ui.apply === false
                  && store.global.linkId) {
                  updateGlobalLinkId('');
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
                dispatch({ type: ActionType.UPDATE_APPLY, apply: false});
                updateGlobalLinkId('');
              }
              console.log("received cancel message from teacher", rtcClientRef.current, rtcLock.current);
              if (cmd === RoomMessage.cancelCoVideo
                && !rtcLock.current
                && rtcClientRef.current) {
                user && console.warn(`[rtm-message] cancel you interactive apply, By Peer User: ${user.account}, reject your apply`);
                rtcLock.current = true;
                rtcClientRef.current.unpublishStream().then(() => {
                  rtcLock.current = false;
                  updateGlobalLinkId('');
                }).catch((err: any) => {
                  rtcLock.current = false;
                  console.warn(err);
                }).finally(() => {
                  dispatch({type: ActionType.REMOVE_LOCAL_STREAM });
                })
              }
              msgLock.current = 'processing'
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
        });
        rtmClient.on("ChannelMessage", ({ memberId, message }: { message: { text: string }, memberId: string }) => {
          const msg = jsonParse(message.text);
          const chatMessage = {
            account: msg.account,
            text: msg.content,
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
        AgoraRTMClient._instance = undefined;
        throw err;
      } finally {
        dispatch({ type: ActionType.LOADING, payload: false });
      }
    }

  const value = {
    room,
    user,
    global,
    users,
    canPass,
    rtmClient,
    rtcClient,
    shareClient,
    sharedStream,
    addRemoteStream,
    removeRemoteStream,
    addLocalStream,
    removeLocalStream,
    addLocalSharedStream,
    removeLocalSharedStream,
    exitRTC,
    exitShareRTC,
    exitRTM,
    exitAll,
    initRTC,
    reInitRTC,
    screenSharing,
    initShareRTC,
    initRTM,
    showDialog,
    removeDialog,
    addMe,
    addRtcClient,
    removeRtcClient,
    addRtmClient,
    removeRtmClient,
    onApplyConfirm,
    onRejectApply,
    onCloseConfirm,
    onCancelClose,
    updateGlobalLinkId,
  }

  return (
    <AgoraSDKContext.Provider value={value}>
      {children}
    </AgoraSDKContext.Provider>
  )
}