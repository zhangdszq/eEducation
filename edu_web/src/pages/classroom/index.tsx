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
import { useGlobalContext } from '../../containers/global-container';
import NativeSharedWindow from '../../components/native-shared-window';

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
    rtmClient,
    initRTM,
    exitAll,
    onApplyConfirm,
    onRejectApply,
    onCloseConfirm,
    onCancelClose,
  } = useAgoraSDK();

  const {
    removeDialog
  } = useGlobalContext();

  useEffect(() => {
    if (!ref.current
      && !rtmClient) {
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

function Classroom() {
  const { roomType } = useParams();
  return (
    <div className="flex-container">
      <NativeSharedWindow />
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

export default React.memo(Classroom);