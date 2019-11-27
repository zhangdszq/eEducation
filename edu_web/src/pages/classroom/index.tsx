import React, { useEffect, useMemo, useRef } from 'react';
import { Switch, Route, Redirect, useHistory, useLocation, useParams } from 'react-router-dom';
import OneToOne from '../classroom/one-to-one';
import SmallClass from '../classroom/small-class';
import BigClass from '../classroom/big-class';
import Nav from '../../components/nav';
import RoomDialog from '../../components/dialog/room';
import AgoraRTMClient from '../../utils/agora-rtm-client';
import { ActionType, UserRole } from '../../reducers/types';
import useToast from '../../hooks/use-toast';
import './room.scss';
import { useRootContext } from '../../store';
import { useAgoraSDK } from '../../hooks/use-agora-sdk';
import useRoomControl from '../../hooks/use-room-control';

function RoomPage({ children, roomType }: any) {
  const history = useHistory();
  const location = useLocation();
  const { showToast, showError } = useToast();
  const { store, dispatch } = useRootContext();
  const ref = useRef<boolean>(false);
  useEffect(() => {
    return () => {
      ref.current = true;
    }
  }, []);
  const {
    rtcClient,
    initRTC,
    rtmClient,
    initRTM,
    exitAll,
    sharedStream,
    removeDialog,
    onApplyConfirm,
    onRejectApply,
    onCloseConfirm,
    onCancelClose,
  } = useAgoraSDK();

  const {
    screenSharing,
    updateScreenSharedId,
  } = useRoomControl();

  useEffect(() => {
    window.onbeforeunload = () => {
      dispatch({ type: ActionType.UPDATE_CAN_PASS, pass: true });
    }
  }, [location]);

  useEffect(() => {
    if (!ref.current
      && AgoraRTMClient._instance === undefined) {
      initRTM()
        .then(() => {
        })
        .catch((err: any) => {
          if (err.type === 'not_permitted') {
            console.warn(err);
            showError(err.reason);
            history.push('/');
          }
          console.warn(err);
        });
    }
  }, []);

  // in big-class only teacher can publish directly, student role as audience
  const publish = useMemo(() => {
    if (!location.pathname.match(/big-class/)) {
      return true;
    }
    if (store.user.role === UserRole.teacher) {
      return true;
    }
    if (store.global.linkId && store.user.id && store.global.linkId === store.user.id) {
      return true;
    }
    return false;
  }, [store.user, location, store.global.linkId]);

  const rtcClientLock = useRef<boolean>(false);

  useEffect(() => {
    if (!ref.current && rtmClient && !rtcClient && !rtcClientLock.current) {
      rtcClientLock.current = true
      initRTC({ publish, media: store.global.mediaInfo })
        .then(() => {
          rtcClientLock.current = false
        }).catch((err: any) => {
          rtcClientLock.current = false
          console.error(err);
        })
    }
  }, [rtmClient]);

  useEffect(() => {
    if (store.user.role !== UserRole.teacher
      && publish
      && !rtcClientLock.current
      && store.global.rtcClient
      && store.global.rtcClient._published === false) {
      rtcClientLock.current = true;
      store.global.rtcClient.publishStream({
        ...store.global.mediaInfo,
        video: true,
        audio: true
      }).then(() => {
        rtcClientLock.current = false;
      }).catch((err: any) => {
        rtcClientLock.current = false;
        console.warn(err);
      })
    }
    if (store.user.role !== UserRole.teacher
      && !publish
      && !rtcClientLock.current
      && store.global.rtcClient
      && store.global.rtcClient._published === true) {
      rtcClientLock.current = true;
      store.global.rtcClient.unpublishStream().then(() => {
        rtcClientLock.current = false;
      }).catch((err: any) => {
        rtcClientLock.current = false;
        console.warn(err);
      }).finally(() => {
        dispatch({ type: ActionType.REMOVE_LOCAL_STREAM });
      })
    }
  }, [publish]);

  const { cameraId, microphoneId, speakerId, speakerVolume } = useMemo(() => {
    return store.global.mediaInfo;
  }, [store.global.mediaInfo]);

  useEffect(() => {
    if (publish && store.global.rtcClient && !rtcClientLock.current) {
      rtcClientLock.current = true;
      dispatch({ type: ActionType.REMOVE_LOCAL_STREAM });
      store.global.rtcClient.republishStream({
        ...store.global.mediaInfo,
        video: true,
        audio: true
      }).then(() => {
        rtcClientLock.current = false;
      }).catch((err: any) => {
        rtcClientLock.current = false;
        console.warn(err);
      })
    }
  }, [cameraId, microphoneId, speakerId, speakerVolume]);

  const handleConfirm = (type: string) => {
    switch (type) {
      case 'exitRoom':
        removeDialog();
        exitAll().then(() => {
        }).catch(console.warn)
          .finally(() => {
            history.push('/');
          })
        return;
      case 'apply':
        onApplyConfirm().then(() => {

        }).catch(console.warn);
        return;
      case 'close':
        onCloseConfirm().then(() => {

        }).catch(console.warn);
        return;
    }
  }

  const handleCancel = (type: string) => {
    switch (type) {
      case 'exitRoom':
        removeDialog();
        return;
      case 'apply':
        onRejectApply().then(() => {

        }).catch(console.warn);
        return;
      case 'close':
        onCancelClose().then(() => {
        }).catch(console.warn);
        return;
    }
  }

  useEffect(() => {
    if (rtmClient && screenSharing === false && sharedStream) {
      dispatch({ type: ActionType.UPDATE_SCREEN_SHARING, sharing: true });
    }
    if (rtmClient && screenSharing && sharedStream) {
      updateScreenSharedId()
        .then(() => {
          console.log('[refactor] screen sharing');
        })
        .catch(() => {
          console.log('[refactor] screen sharing failured');
        })
    }
  }, [rtmClient, screenSharing, sharedStream]);

  const { id, account, video, audio, chat, role } = useMemo(() => {
    return store.user;
  }, [store.user]);

  useEffect(() => {
    if (id && role === UserRole.student && rtmClient) {
      rtmClient.updateChannelAttrs(store, {
        id, account, video, chat, audio
      }
      ).then(() => {
        console.log("update success");
      }).catch((err: any) => {
        console.warn(err);
      });
    }
  }, [id, account, video, audio, chat, role]);

  return (
    <div className={`classroom ${roomType}`}>
      <Nav />
      {children}
      {store.ui.dialog.visible ? <RoomDialog
        type={store.ui.dialog.type}
        onConfirm={handleConfirm}
        onClose={handleCancel}
        visible={store.ui.dialog.visible}
        desc={store.ui.dialog.desc}
      />
        : null
      }
    </div>);
}

export default function () {
  const { roomType } = useParams();
  return (
    <div className="flex-container">
      <Switch>
        <Route exact path="/classroom/one-to-one">
          <RoomPage roomType={roomType}>
            <OneToOne />
          </RoomPage>
        </Route>
        <Route exact path="/classroom/small-class">
          <RoomPage roomType={roomType}>
            <SmallClass />
          </RoomPage>
        </Route>
        <Route exact path="/classroom/big-class">
          <RoomPage roomType={roomType}>
            <BigClass />
          </RoomPage>
        </Route>
        <Route path="*">
          <Redirect to="/" />
        </Route>
      </Switch>
    </div>
  )
}