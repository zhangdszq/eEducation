import React, { useRef, useState, useEffect, useMemo } from 'react';
import Icon from './icon';
import './video-player.scss';
import { useRootContext } from '../store';
import { UserRole } from '../reducers/types';
interface VideoPlayerProps {
  domId?: string
  id?: string
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

export default function VideoPlayer ({
  preview,
  role,
  account,
  stream,
  className,
  domId,
  audio,
  id,
  video,
  handleClick,
  local,
  handleClose,
  close
}: VideoPlayerProps) {

  const {store} = useRootContext();
  const isTeacher = useMemo(() => {
    return store.user.role === UserRole.teacher
  }, [store.user.role]);
  const [play, setPlay] = useState<boolean>(false);

  const ref = useRef<boolean>();

  const loadVideo = useRef<boolean>(false);
  const loadAudio = useRef<boolean>(false);

  useEffect(() => {
    ref.current = false;
    loadVideo.current = false;
    loadAudio.current = false;
    return () => {
      ref.current = true;
      loadVideo.current = true;
      loadAudio.current = true;
      stream && stream.isPlaying() && stream.stop();
      local && stream.close();
    }
  }, []);

  useEffect(() => {
    if (!ref.current && stream && !play && !stream.isPlaying()) {
      stream.play(`${domId}`, {fit: 'cover'}, (err: any) => {
        if (err && err.status !== 'aborted') {
          console.warn('[video-player] ', err, id);
        }
        !ref.current && setPlay(!play);
      })
    }
    return () => {
      if (!ref.current && play) {
        setPlay(!play);
        stream && stream.isPlaying() && stream.stop();
      }
    }
  }, [domId, stream, play]);


  useEffect(() => {
    if (stream) {
      // prevent already muted audio
      if (!loadAudio.current) {
        if (!audio) stream.muteAudio();
        loadAudio.current = true;
        return;
      }

      if (audio) {
        stream.unmuteAudio();
      } else {
        stream.muteAudio();
      }
    }
  }, [stream, audio]);

  useEffect(() => {
    if (stream) {
      // prevent already muted video
      if (!loadVideo.current) {
        if (!video) stream.muteVideo();
        loadVideo.current = true;
        return;
      }

      if (video) {
        stream.unmuteVideo();
      } else {
        stream.muteVideo();
      }
    }
  }, [stream, video]);

  const onAudioClick = (evt: any) => {
    if (handleClick && id) {
      handleClick('audio', stream.getId(), id);
    }
  }

  const onVideoClick = (evt: any) => {
    if (handleClick && id) {
      handleClick('video', stream.getId(), id);
    }
  }

  const onClose = (evt: any) => {
    if (handleClose && id) {
      handleClose('close', stream.getId());
    }
  }

  return (
    <div id={`${domId}`} className={`${className ? className : (preview ? 'preview-video' : `agora-video-view ${!!video ? '' : 'show-placeholder'}`)}`}>
      {close ? <div className="icon-close" onClick={onClose}></div> : null}
      <div className={role === 'teacher' ? 'teacher-placeholder' : 'student-placeholder'}></div>
      {preview ? null : 
        account ? 
          <div className="video-profile">
            <span className="account">{account}</span>
            { isTeacher || store.user.id === id ? 
              <span className="media-btn">
                <Icon onClick={onAudioClick} className={audio ? "icon-speaker-on" : "icon-speaker-off" } data={"audio"} />
                <Icon onClick={onVideoClick} className={video ? "icons-camera-unmute-s" : "icons-camera-mute-s"} data={"video"} />
              </span> : null}
          </div>
        : null
      }
    </div>
  )
}