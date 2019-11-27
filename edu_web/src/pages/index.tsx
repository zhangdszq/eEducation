import React from 'react';
import { Route } from 'react-router-dom';
import CustomBrowserRouter from '../containers/custom-browser-router';
import ThemeContainer from '../containers/theme-container';
import Home from './home';
import DeviceTest from './device-test';
import ClassRoom from './classroom';
import Loading from '../components/loading';
import Toast from '../components/toast';
import { useRootContext, useRootObserver } from '../store';
import { AgoraSDKProvider } from '../hooks/use-agora-sdk';

import '../icons.scss';
import 'animate.css';

export default function () {
  const { store } = useRootContext();
  useRootObserver(store);

  return (
    <ThemeContainer>
      <CustomBrowserRouter>
        <AgoraSDKProvider>
          {store.global.loading ? <Loading /> : null}
          <Toast />
          <Route exact path="/">
            <Home />
          </Route>
          <Route exact path="/device_test">
            <DeviceTest />
          </Route>
          <Route exact path="/classroom/:roomType">
            <ClassRoom />
          </Route>
        </AgoraSDKProvider>
      </CustomBrowserRouter>
    </ThemeContainer>
  )
}