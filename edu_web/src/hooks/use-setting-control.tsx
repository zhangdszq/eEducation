import { usePlatform } from '../containers/platform-container';
import { useAgoraSDK } from './use-agora-sdk';
import React, { useState, useEffect, useMemo, useRef, useCallback } from 'react';

import VoiceVolume from '../components/volume/voice';
import { ActionType } from '../reducers/types';
import { MediaInfo } from '../reducers/initialize-state';
import {useRootContext} from '../store';
import AgoraWebClient from '../utils/agora-rtc-client';
import { AgoraElectronClient } from '../utils/agora-electron-client';
import VideoPlayer from '../components/video-player';

export default function useSettingControl () {

  const {store, dispatch} = useRootContext();
  const {rtcClient, devices, setDevices} = useAgoraSDK();
  const {platform} = usePlatform();

  const cameraList = useMemo(() => {
    return devices
    .filter((it: Device) => 
      it.kind === 'videoinput');
  }, [devices]);

  const microphoneList = useMemo(() => {
    return devices
    .filter((it: Device) => 
      it.kind === 'audioinput');
  }, [devices]);

  const speakerList = useMemo(() => {
    return devices
    .filter((it: Device) => 
      it.kind === 'audiooutput');
  }, [devices]);

  const {mediaInfo} = store.global;

  const [camera, setCamera] = useState(mediaInfo.camera);
  const [microphone, setMicrophone] = useState(mediaInfo.microphone);
  const [speaker, setSpeaker] = useState(mediaInfo.speaker);
  // const [localStream, setLocalStream] = useState<any>(null);
  const [speakerVolume, setSpeakerVolume] = useState<number>(mediaInfo.speakerVolume);
  const [volume, setVolume] = useState<number>(0);
  const ref = useRef<boolean>(false);

  useEffect(() => {
    // @ts-ignore
    window.d = {
      mediaInfo,
      devices
    }
  }, [mediaInfo, devices]);



  let mounted = false;

  useEffect(() => {
    if (!platform || !rtcClient) return;

    if (platform === 'web' && !mounted) {
      const webClient = rtcClient as AgoraWebClient;
      const onChange = async () => {
        const devices: Device[] = await webClient.getDevices();
        console.log("devices", devices);
        setDevices(devices.map((item: Device) => ({
          value: item.deviceId,
          text: item.label,
          kind: item.kind
        })));
      }
      window.addEventListener('devicechange', onChange);
      onChange().then(() => {
      }).catch(console.warn);
      mounted = true;
      return () => {
        window.removeEventListener('devicechange', onChange);
      }
    }

    if (platform === 'electron' && !mounted) {
      const nativeClient = rtcClient as AgoraElectronClient;

      const onChange = async () => {
        let microphoneIds = await nativeClient.rtcEngine.getAudioRecordingDevices();
        let speakerIds = await nativeClient.rtcEngine.getAudioPlaybackDevices();
        let cameraIds = await nativeClient.rtcEngine.getVideoDevices();
        const microphones = microphoneIds.map((it: any) => (
          {
            kind: 'audioinput',
            text: it.devicename,
            deviceId: it.deviceid
          }
        ));
        const speakers = speakerIds.map((it: any) => ({
          kind: 'audiooutput',
          text: it.devicename,
          deviceId: it.deviceid,
        }));
        const cameras = cameraIds.map((it: any) => ({
          kind: 'videoinput',
          text: it.devicename,
          deviceId: it.deviceid,
        }));
        setDevices([].concat(microphones).concat(speakers).concat(cameras));
      }
      onChange().then(() => console.log('electron devices changed'))
        .catch(console.warn);

      nativeClient.on('videodevicestatechanged', onChange);
      nativeClient.on('audiodevicestatechanged', onChange);
      mounted = true;
      return () => {
        nativeClient.off('videodevicestatechanged', onChange);
        nativeClient.off('audiodevicestatechanged', onChange);
      }
    }
  }, [platform, rtcClient]);

  const cameraId: string = useMemo(() => {
    return cameraList[camera] ? cameraList[camera].value : '';
  }, [cameraList, camera]);

  const microphoneId: string = useMemo(() => {
    return microphoneList[microphone] ? microphoneList[microphone].value : '';
  }, [microphoneList, microphone]);

  const speakerId: string = useMemo(() => {
    return speakerList[speaker] ? speakerList[speaker].value : '';
  }, [speakerList, speaker]);

  const [stream, setStream] = useState<any>(null);

  const preview = useRef<boolean>(false);
  useEffect(() => {
    if (preview.current) return;
    if (platform === 'web') {
      const webClient = rtcClient as AgoraWebClient;
      preview.current = true;
      webClient.createPreviewStream({
        cameraId,
        microphoneId,
        speakerId,
      }).then((stream: any) => {
        setStream(stream);
      })
    }

    if (platform === 'electron') {
      const nativeClient = rtcClient as AgoraElectronClient;
      preview.current = true;
      const stream = nativeClient.createStream({
        streamID: 0,
        cameraId,
        microphoneId,
        speakerId,
      })
      setStream(stream);
    }
  }, [platform, speakerId, cameraId, microphoneId]);

  const interval = useRef<any>(null);

  useEffect(() => {
    if (!stream || !stream.getAudioLevel) return;
    interval.current = setInterval(() => {
      console.log("setVolume: ", stream.getAudioLevel());
      setVolume(stream.getAudioLevel())
    }, 300);
    return () => {
      interval.current && clearInterval(interval.current);
      interval.current = null;
    }
  }, [stream]);

  useEffect(() => {
    console.log("use -setting -control", stream, platform);
    if (!stream) return;
    if (platform === 'electron') {
      console.log("[electron-client] add volume event listener");
      const onVolumeChange = (uid: number, volume: number, speaker: any, totalVolume: number)=> {
        console.log("update volume");
        setVolume(Number((totalVolume / 255).toFixed(3)))
      }
      const nativeClient = rtcClient as AgoraElectronClient;
      nativeClient.rtcEngine.setClientRole(1);
      nativeClient.rtcEngine.enableAudioVolumeIndication(1000, 3, false);
      nativeClient.rtcEngine.on('audiovolumeindication', onVolumeChange);
      console.log('startplayback on result', nativeClient.rtcEngine.startAudioRecordingDeviceTest(300));
      return () => {
        nativeClient.rtcEngine.off("audiovolumeindication", onVolumeChange);
        console.log('startplayback off result', nativeClient.rtcEngine.stopAudioPlaybackDeviceTest());
      }
    }
  }, [stream]);

  const PreviewPlayer = useCallback(() => {
    if (!stream) return null;
    return (
      <VideoPlayer
        domId={"local"}
        preview={true}
        stream={stream}
        streamID={0}
        video={true}
        audio={true}
        local={true}
      />
    )

  }, [stream]);

  const MicrophoneVolume = useCallback(() => {
    return (<VoiceVolume volume={volume}/>)
  }, [volume]);

  const handleSave = (args: {camera: number, microphone: number, speaker: number, speakerVolume: number}) => {
    const { camera, microphone, speaker, speakerVolume } = args;
    const cameraId = cameraList[camera] ? cameraList[camera].value : '';
    const microphoneId = microphoneList[microphone] ? microphoneList[microphone].value : '';
    const speakerId = speakerList[speaker] ? speakerList[speaker].value : '';
    const mediaInfo: MediaInfo = {
      cameraId,
      microphoneId,
      speakerId,
      camera,
      microphone,
      speaker,
      speakerVolume,
    }
    dispatch({type: ActionType.SAVE_MEDIA, media: mediaInfo});
    if (stream && stream.close) {
      stream.close();
    }
  }

  return {
    volume,
    cameraList,
    microphoneList,
    speakerList,
    camera,
    microphone,
    speaker,
    setCamera,
    setMicrophone,
    setSpeaker,
    speakerVolume,
    setSpeakerVolume,
    PreviewPlayer,
    MicrophoneVolume,
    save: handleSave,
  }
}