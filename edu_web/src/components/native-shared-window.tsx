import React, { useMemo, useEffect } from 'react';
import { useRootContext } from '../store';
import { useAgoraSDK, IWindow } from '../hooks/use-agora-sdk';
import './native-shared-window.scss';
import Button from './custom-button';
import { usePlatform } from '../containers/platform-container';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import { AgoraStream } from '../reducers/types';

export interface IWindowProps extends IWindow {
  className?: string
}

export const WindowItem: React.FC<IWindowProps> = ({
  ownerName,
  name,
  className,
  windowId,
  image,
}) => {

  return (
    <div className={className ? className : ''} >
      <div className="screen-image">
        <div className="content" style={{ backgroundImage: `url(data:image/png;base64,${image})` }}>
        </div>
      </div>
      <div className="screen-meta">{name}</div>
    </div>
  )
}

export interface WindowListProps {
  title: string
  items: any[]
  windowId: number
  selectWindow: (windowId: any) => void
  confirm: (evt: any) => void
  cancel: (evt: any) => void
}

export const WindowList: React.FC<WindowListProps> = ({
  title,
  items,
  windowId,
  selectWindow,
  confirm,
  cancel
}) => {
  return (
    <div className="window-picker-mask">
      <div className="window-picker">
        <div className="header">
          <div className="title">{title}</div>
          <div className="cancelBtn" onClick={cancel}></div>
        </div>
        <div className='screen-container'>
          {
            items.map((it: any, key: number) =>
              <div className="screen-item" 
                key={key}
                onClick={() => {
                  selectWindow(it.windowId);
                }}
                onDoubleClick={confirm}
                >
                <WindowItem
                  ownerName={it.ownerName}
                  name={it.name}
                  className={`window-item ${it.windowId === windowId ? 'active' : ''}`}
                  windowId={it.windowId}
                  image={it.image}
                />
              </div>
            )
          }
        </div>
        <div className='footer'>
          <Button className={'share-confirm-btn'} name={"start"}
            onClick={confirm} />
        </div>
      </div>
    </div>
  )
}

export default function NativeSharedWindowContainer() {

  const {
    platform
  } = usePlatform();

  const {
    nativeWindowInfo,
    setNativeWindowInfo,
    rtcClient,
    addLocalSharedStream,
  } = useAgoraSDK();

  const [windowId, setWindowId] = React.useState<any>('');

  // useEffect(() => {
  //   console.log('nativeWindowInfo.items', nativeWindowInfo.items);
  // }, [nativeWindowInfo]);

  return (
    nativeWindowInfo.visible ? 
    <WindowList
      windowId={windowId}
      title={'Please select and click window for share'}
      items={nativeWindowInfo.items}
      cancel={() => {
        setNativeWindowInfo({visible: false, items: []});
      }}
      selectWindow={(windowId: any) => {
        setWindowId(windowId)
      }}
      confirm={async (evt: any) => {
        if (!windowId) {
          console.log("windowId is empty");
          return;
        }
        console.log("windowId ", windowId);
        try {
          if (platform === 'electron') {
            const nativeClient = rtcClient as AgoraElectronClient;
            let electronStream = await nativeClient.startScreenShare(windowId)
            addLocalSharedStream(new AgoraStream(electronStream, electronStream.uid, true));
          }
        } catch(err) {
          throw err;
        } finally {
          setNativeWindowInfo({visible: false, items: []});
        }
      }}
    />
    : null
  )
}