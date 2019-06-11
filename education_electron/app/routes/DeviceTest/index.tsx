import * as React from 'react';
import { useState, useEffect, useRef, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { Form, Select, Button, Progress, Slider } from 'antd';

import Adapter from '../../modules/Adapter';
import { useCamera, useMicrophone, useVolume } from '../../modules/Hooks';
import './index.scss';

const FormItem = Form.Item;
const Option = Select.Option;

enum PrecallTestStatus {
  PENDING = 0,
  SUCCESS,
  ERROR
}

export default function(props: any) {
  const adapter: Adapter = props.adapter
  const {rtcEngine} = adapter;
  const {client} = rtcEngine;
  // ---------------- Hooks ----------------
  // Hooks used in this component
  const musicRef = useRef(null);
  const [isMusicOn, setIsMusicOn] = useState(false);
  const [musicVolume, setMusicVolume] = useState(1);

  const cameraList = useCamera(client);
  const [microphoneList, speakerList] = useMicrophone(client);
  const volume = useVolume(client);

  const [currentCamera, setCurrentCamera] = useState<string | undefined>(
    undefined
  );
  const [currentMic, setCurrentMic] = useState<string | undefined>(undefined);
  const [currentSpeaker, setCurrentSpeaker] = useState<string | undefined>(undefined);
  // refresh stream when change device
  useEffect(() => {
    client.setVideoDevice(currentCamera)
  }, [currentCamera]);

  useEffect(() => {
    client.setAudioPlaybackDevice(currentSpeaker)
  }, [currentSpeaker]);

  useEffect(() => {
    client.setAudioRecordingDevice(currentMic)
  }, [currentMic]);

  // control volume when slider change
  useEffect(() => {
    if (musicRef) {
      let musicNode = (musicRef as any).current;
      musicNode.volume = musicVolume;
    }
  }, [musicVolume]);

  // mount and unmount
  useEffect(() => {
    client.setupLocalVideo(document.querySelector('.preview-window'));
    client.startPreview();

    return () => {
      client.stopPreview();
    }
  }, [0])

  // ---------------- Methods or Others ----------------
  // Methods or sth else used in this component

  const toggleMusic = () => {
    if (!musicRef) {
      return;
    }
    let musicNode = (musicRef as any).current;
    if (!isMusicOn) {
      musicNode.play();
    } else {
      musicNode.pause();
    }
    setIsMusicOn(!isMusicOn);
  };

  const handleNextStep = () => {
    props.history.push('/classroom')
  }

  return (
    <div className="wrapper" id="deviceTesting">
      <main className="main">
        <section className="content">
          <header>
            <img src={require('../../assets/images/logo.png')} alt="" />
          </header>
          <main>
            <Form>
              <FormItem
                style={{ marginBottom: '6px' }}
                label="Camera"
                colon={false}
              >
                <Select
                  defaultValue={0}
                  onChange={val => setCurrentCamera(cameraList[val].deviceid)}
                >
                  {cameraList.map((item, index) => (
                    <Option key={item.deviceid} value={index}>
                      {item.devicename}
                    </Option>
                  ))}
                </Select>
              </FormItem>
              <FormItem
                style={{ marginBottom: '6px' }}
                label="Microphone"
                colon={false}
              >
                <Select
                  defaultValue={0}
                  onChange={val => setCurrentMic(microphoneList[val].deviceid)}
                >
                  {microphoneList.map((item, index) => (
                    <Option key={item.deviceid} value={index}>
                      {item.devicename}
                    </Option>
                  ))}
                </Select>
              </FormItem>
              <FormItem
                style={{ marginBottom: '6px' }}
                label={
                  <img
                    style={{ width: '13px' }}
                    src={require('../../assets/images/microphone.png')}
                    alt=""
                  />
                }
                labelCol={{ span: 4 }}
                wrapperCol={{ span: 20 }}
                colon={false}
              >
                <Progress percent={volume * 100} showInfo={false} />
              </FormItem>
              <FormItem
                style={{ marginBottom: "6px" }}
                label="Speaker"
                colon={false}
              >
                <Select
                  defaultValue={0}
                  onChange={val => setCurrentSpeaker(speakerList[val].deviceid)}
                >
                  {speakerList.map((item, index) => (
                    <Option key={item.deviceid} value={index}>
                      {item.devicename}
                    </Option>
                  ))}
                </Select>
              </FormItem>
              <FormItem
                style={{ marginBottom: '6px' }}
                label={
                  <img
                    id="toggleMusicBtn"
                    onClick={toggleMusic}
                    src={require('../../assets/images/sound.png')}
                    alt=""
                  />
                }
                labelCol={{ span: 4 }}
                wrapperCol={{ span: 20 }}
                colon={false}
              >
                <Slider
                  onChange={val => setMusicVolume(val as number)}
                  min={0}
                  step={0.01}
                  max={1.0}
                  value={musicVolume}
                />
              </FormItem>
              <audio
                ref={musicRef}
                style={{ display: 'none' }}
                src={require('../../assets/music/music.mp3')}
              />
            </Form>
          </main>
        </section>
        <section className="illustration">
          <h3 className="title">Device Testing</h3>
          
          <div
            className="preview-window"
          />
          
          <div className="button-group">
            <Button size="large" id="nextBtn" type="primary" onClick={handleNextStep}>
              Next Step ->
            </Button>
          </div>
        </section>
      </main>
    </div>
  );
}
