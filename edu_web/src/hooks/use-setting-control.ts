import { useState, useEffect, useMemo, useRef } from 'react';

import AgoraRTCClient from '../utils/agora-rtc-client';
import { ActionType } from '../reducers/types';
import { MediaInfo } from '../reducers/initialize-state';
import {useRootContext} from '../store';

export default function useSettingControl () {

  const {store, dispatch} = useRootContext();

  const [devices, setDevices] = useState<any[]>([]);

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
  const [localStream, setLocalStream] = useState<any>(null);
  const [speakerVolume, setSpeakerVolume] = useState<number>(mediaInfo.speakerVolume);
  const [volume, setVolume] = useState<number>(0);
  const [timer, setTimer] = useState<NodeJS.Timeout|any>(null);
  const ref = useRef<boolean>(false);

  useEffect(() => {
    ref.current = false;
    return () => {
      ref.current = true;
      timer && clearInterval(timer);
      if (localStream) {
        if (localStream.isPlaying()) {
          localStream.stop();
        }
        localStream.close();
      }
    }
  }, [])

  useEffect(() => {
    const rtc = new AgoraRTCClient();
    const cameraId = cameraList[camera] ? cameraList[camera].value : '';
    const microphoneId = microphoneList[microphone] ? microphoneList[microphone].value : '';
    const speakerId = speakerList[speaker] ? speakerList[speaker].value : '';
    timer && clearInterval(timer);
    if (localStream) {
      if (localStream.isPlaying()) {
        localStream.stop();
      }
      localStream.close();
    }

    if (!ref.current) {
      ref.current = true;
      rtc.createStream({
        streamID: 0,
        audio: true,
        video: true,
        screen: false,
        cameraId,
        microphoneId,
        audioOutput: {
          volume: volume,
          deviceId: speakerId,
        }
      })
      .then((stream: any) => {
        ref.current = false
        setLocalStream(stream);
      }).catch((err: any) => {
        ref.current = false
      })
    }
  }, [camera, microphone, speaker]);

  useEffect(() => {
    dispatch({ type: ActionType.LOADING, payload: true });
    AgoraRTCClient.getDevices().then((devices: Device[]) => {
      dispatch({ type: ActionType.LOADING, payload: false });
      setDevices(devices.map(
        (item: Device) => ({
          value: item.deviceId,
          text: item.label,
          kind: item.kind
        })));
    })
    return () => {
      ref.current = true;
    }
  }, []);

  useEffect(() => {
    if (localStream && timer === null && localStream.isPlaying()) {
      setTimer(setInterval(() => {
        const audioLevel = localStream.getAudioLevel();
        setVolume(audioLevel);
      }, 150));
    }
    return () => {
      if (localStream && !localStream.isPlaying() && timer) {
        clearInterval(timer);
        setTimer(null);
      }
    }
  }, [localStream, timer]);

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
    timer && clearInterval(timer);
    if (localStream) {
      if (localStream.isPlaying()) {
        localStream.stop();
      }
      localStream.close();
    }
    // methods.saveMedia(mediaInfo);
  }

  return {
    localStream,
    cameraList,
    microphoneList,
    speakerList,
    camera,
    microphone,
    speaker,
    setCamera,
    setMicrophone,
    setSpeaker,
    volume,
    speakerVolume,
    setSpeakerVolume,
    save: handleSave,
  }
}