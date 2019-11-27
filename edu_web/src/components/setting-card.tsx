import React, { useEffect } from 'react';
import { FormControl } from '@material-ui/core';
import {makeStyles} from '@material-ui/core/styles';
import Button from './custom-button';
import Icon from './icon';
import FormSelect from './form-select';
import SpeakerVolume from './volume/speaker';
import VoiceVolume from './volume/voice';
import useSettingControl from '../hooks/use-setting-control';
import VideoPlayer from './video-player';

import {isElectron} from '../utils/platform';

const useStyles = makeStyles ({
  formControl: {
    minWidth: '240px',
    maxWidth: '240px',
  }
});

interface SettingProps {
  className?: string
  handleFinish: (evt: any) => void
}

export default function (props: SettingProps) {
  const classes = useStyles();
  const {
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
    save
  } = useSettingControl();

  useEffect(() => {
    if (localStream) {
      localStream.close();
    }
  }, [])

  const changeCamera = (evt: any) => {
    setCamera(evt.target.value);
  }

  const changeMicrophone = (evt: any) => {
    setMicrophone(evt.target.value);
  }

  const changeSpeaker = (evt: any) => {
    setSpeaker(evt.target.value);
  }

  const changeSpeakerVolume = (volume: number) => {
    setSpeakerVolume(volume);
  }

  return (
    <div className={props.className ? props.className : "flex-container"}>
      <div className="custom-card">
        <div className="flex-item cover">
          {localStream ?
            <VideoPlayer
              domId={"local"}
              preview={true}
              stream={localStream}
              video={true}
              audio={true}
            /> :
            <div className="cover-placeholder"></div>}
        </div>
        <div className="flex-item card">
          <div className="position-top card-menu">
            <div></div>
            <div className="icon-container">
              {/* <Icon className="icon-minimum" icon /> */}
              {isElectron ? <Icon className="icon-close" icon /> : null }
            </div>
          </div>
          <div className="position-content flex-direction-column">
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={"Camera"}
                value={camera}
                onChange={changeCamera}
                menus={cameraList}
              />
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={"Microphone"}
                value={microphone}
                onChange={changeMicrophone}
                menus={microphoneList}
              />
              <VoiceVolume volume={volume}/>
            </FormControl>
            <FormControl className={classes.formControl}>
              <FormSelect 
                Label={"Speaker"}
                value={speaker}
                onChange={changeSpeaker}
                menus={speakerList}
              />
              <SpeakerVolume volume={speakerVolume} onChange={changeSpeakerVolume} />
            </FormControl>
            <Button name={"Finish"} onClick={(evt: any) => {
              save({
                speakerVolume,
                camera,
                microphone,
                speaker,
              })
              props.handleFinish(evt);
            }}/>
          </div>
        </div>
      </div>
    </div>
  )
}