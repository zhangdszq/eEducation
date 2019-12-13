import React, { useRef, useState, useEffect, useMemo } from 'react';
import Icon from './icon';
import './video-player.scss';
import { useRootContext } from '../store';
import { UserRole } from '../reducers/types';
import { usePlatform } from '../containers/platform-container';
import { AgoraElectronStream, StreamType, nativeRTCClient as nativeClient } from '../utils/agora-electron-client';

const contentMode = 0;

interface VideoPlayerProps {
  domId?: string
  id?: string
  streamID: number
  preview?: boolean
  account?: any
  stream?: any
  role?: string
  audio?: boolean
  video?: boolean
  className?: string
  showProfile?: boolean
  local?: boolean
  handleClick?: (type: string, streamID: number, uid: string) => Promise<any>
  close?: boolean
  handleClose?: (uid: string, streamID: number) => void
}

const VideoPlayer: React.FC<VideoPlayerProps> = ({
  preview,
  role,
  account,
  stream,
  className,
  domId,
  streamID,
  audio,
  id,
  video,
  handleClick,
  local,
  handleClose,
  close
}) => {

  const { store } = useRootContext();
  const { platform } = usePlatform();
  const isTeacher = useMemo(() => {
    return store.user.role === UserRole.teacher
  }, [store.user.role]);

  const loadVideo = useRef<boolean>(false);
  const loadAudio = useRef<boolean>(false);

  const lockPlay = useRef<boolean>(false);

  const AgoraRtcEngine = useMemo(() => {
    return nativeClient.rtcEngine;
  }, [nativeClient.rtcEngine]);

  useEffect(() => {
    if (!domId || !stream || !nativeClient) return;
    const _stream = stream as AgoraElectronStream;
    if (platform === 'electron') {
      const dom = document.getElementById(domId);
      if (!dom) return;
      if (preview) {
        // set for preview
        AgoraRtcEngine.setupLocalVideo(dom);
        AgoraRtcEngine.setupViewContentMode(streamID, contentMode);
        AgoraRtcEngine.setClientRole(1);
        // preview mode required you become host
        AgoraRtcEngine.startPreview();
        // AgoraRtcEngine.muteLocalVideoStream(nativeClient.published);
        // AgoraRtcEngine.muteLocalAudioStream(nativeClient.published);
        return () => {
          AgoraRtcEngine.stopPreview();
          AgoraRtcEngine.setClientRole(2);
        }
      }
      if (_stream.type === StreamType.local) {
        console.log("video-player play " ,AgoraRtcEngine.setupViewContentMode(streamID, contentMode));
        console.log("video-player setupLocalVideo ", AgoraRtcEngine.setupLocalVideo(dom));
        return () => {
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }

      if (_stream.type === StreamType.localVideoSource) {
        AgoraRtcEngine.setupLocalVideoSource(dom);
        AgoraRtcEngine.setupViewContentMode('videosource', contentMode);
        AgoraRtcEngine.setupViewContentMode(streamID, contentMode);
        return () => {
          // AgoraRtcEngine.destroyRenderView('videosource');
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }

      if (_stream.type === StreamType.remote) {
        AgoraRtcEngine.subscribe(streamID, dom);
        AgoraRtcEngine.setupViewContentMode(streamID, contentMode);
        return () => {
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }

      if (_stream.type === StreamType.remoteVideoSource) {
        AgoraRtcEngine.subscribe(streamID, dom);
        AgoraRtcEngine.setupViewContentMode('videosource', contentMode);
        AgoraRtcEngine.setupViewContentMode(streamID, contentMode);
        return () => {
          // AgoraRtcEngine.destroyRenderView('videosource');
          // AgoraRtcEngine.destroyRenderView(streamID, dom, (err: any) => { console.warn(err.message) });
        }
      }
    }
  }, [domId, stream, AgoraRtcEngine, nativeClient]);

useEffect(() => {
  if (platform === 'web') {
    if (!stream || !domId || lockPlay.current && stream.isPlaying()) return;
    lockPlay.current = true;
    stream.play(`${domId}`, { fit: 'cover' }, (err: any) => {
      lockPlay.current = false;
      if (err && err.status !== 'aborted') {
        console.warn('[video-player] ', err, id);
      }
    })
    return () => {
      if (stream.isPlaying()) {
        stream.stop();
      }
      // local && stream && stream.close();
    }
  }
}, [domId, stream]);


useEffect(() => {
  if (stream && platform === 'web') {
    // prevent already muted audio
    if (!loadAudio.current) {
      if (!audio) {
        stream.muteAudio();
        console.log('strea mute audio');
      }
      loadAudio.current = true;
      return;
    }

    if (audio) {
      console.log('strea unmute audio');
      stream.unmuteAudio();
    } else {
      console.log('strea mute audio');
      stream.muteAudio();
    }
  }

  if (stream && platform === 'electron') {
    // prevent already muted video
    if (!loadAudio.current) {
      if (!audio) {
        AgoraRtcEngine.muteLocalAudioStream(true);
      }
      loadAudio.current = true;
      return;
    }

    if (audio) {
      AgoraRtcEngine.muteLocalAudioStream(false);
    } else {
      AgoraRtcEngine.muteLocalAudioStream(true);
    }
}
}, [stream, audio, AgoraRtcEngine]);

useEffect(() => {
  if (stream && platform === 'web') {
    // prevent already muted video
    if (!loadVideo.current) {
      if (!video) {
        console.log('strea mute video');
        stream.muteVideo();
      }
      loadVideo.current = true;
      return;
    }

    if (video) {
      console.log('strea unmute video');
      stream.unmuteVideo();
    } else {
      console.log('strea mute video');
      stream.muteVideo();
    }
  }

  if (stream && platform === 'electron') {
      // prevent already muted video
      if (!loadVideo.current) {
        if (!video) {
          AgoraRtcEngine.muteLocalVideoStream(true);
        }
        loadVideo.current = true;
        return;
      }

      if (video) {
        AgoraRtcEngine.muteLocalVideoStream(false);
      } else {
        AgoraRtcEngine.muteLocalVideoStream(true);
      }
  }
}, [stream, video, AgoraRtcEngine]);

const onAudioClick = (evt: any) => {
  if (handleClick && id) {
    handleClick('audio', streamID, id);
  }
}

const onVideoClick = (evt: any) => {
  if (handleClick && id) {
    handleClick('video', streamID, id);
  }
}

const onClose = (evt: any) => {
  if (handleClose && id) {
    handleClose('close', streamID);
  }
}

return (
  <div id={`${domId}`} className={`${className ? className : (preview ? 'preview-video' : `agora-video-view ${Boolean(video) === false && stream ? 'show-placeholder' : ''}`)}`}>
    {close ? <div className="icon-close" onClick={onClose}></div> : null}
    <div className={role === 'teacher' ? 'teacher-placeholder' : 'student-placeholder'}></div>
    {preview ? null :
      account ?
        <div className="video-profile">
          <span className="account">{account}</span>
          {isTeacher || store.user.id === id ?
            <span className="media-btn">
              <Icon onClick={onAudioClick} className={audio ? "icon-speaker-on" : "icon-speaker-off"} data={"audio"} />
              <Icon onClick={onVideoClick} className={video ? "icons-camera-unmute-s" : "icons-camera-mute-s"} data={"video"} />
            </span> : null}
        </div>
        : null
    }
  </div>
)
}

export default React.memo(VideoPlayer);