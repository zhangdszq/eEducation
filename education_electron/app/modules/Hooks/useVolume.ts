import { useState, useEffect } from 'react';

const useVolume = (client: any, interval = 100): number => {
  const [volume, setVolume] = useState(0);

  useEffect(() => {
    let mounted = true;

    const onChange = (uid: number, volume: number, speaker: any, totalVolume: number)=> {
      setVolume(Number((totalVolume / 255).toFixed(3)))
    }

    if (client) {
      client.on('audiovolumeindication', onChange)
      client.startAudioRecordingDeviceTest(interval);
    }

    return () => {
      mounted = false;
      client && client.stopAudioPlaybackDeviceTest()
    };
  }, [0]);

  return volume;
};

export default useVolume;
