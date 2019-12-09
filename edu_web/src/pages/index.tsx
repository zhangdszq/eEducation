import React, { useEffect } from 'react';
import { Route, useLocation } from 'react-router-dom';
import CustomBrowserRouter from '../containers/custom-browser-router';
import ThemeContainer from '../containers/theme-container';
import Home from './home';
import DeviceTest from './device-test';
import ClassRoom from './classroom';
import Loading from '../components/loading';
import Toast from '../components/toast';
import { useRootContext, useRootObserver } from '../store';
import { AgoraSDKProvider } from '../hooks/use-agora-sdk';
import {GlobalContainer} from '../containers/global-container';
import '../icons.scss';
import { PlatformContainer } from '../containers/platform-container';

export default function () {
  const { store } = useRootContext();
  useRootObserver(store);

  return (
    <ThemeContainer>
      <CustomBrowserRouter>
        <GlobalContainer>
          <PlatformContainer>
            <AgoraSDKProvider>
              <Loading />
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
          </PlatformContainer>
        </GlobalContainer>
      </CustomBrowserRouter>
    </ThemeContainer>
  )
}