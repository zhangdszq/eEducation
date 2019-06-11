import { useState, useEffect } from 'react';

interface MediaDeviceInfo {
  devicename: string;
  deviceid: string;
}

const useCameras = (client: any): [MediaDeviceInfo[], MediaDeviceInfo[]] => {
  const [microphoneList, setMicrophoneList] = useState<MediaDeviceInfo[]>([]);
  const [speakerList, setSpeakerList] = useState<MediaDeviceInfo[]>([]);

  useEffect(() => {
    let mounted = true;

    const onChange = () => {
      if (!client) {
        return;
      }
      setMicrophoneList(client.getAudioRecordingDevices())
      setSpeakerList(client.getAudioPlaybackDevices())
    };
    
    client && client.on('audiodevicestatechanged', onChange);
    
    onChange();

    return () => {
      mounted = false;
      client && client.off('audiodevicestatechanged', onChange);
    };
  }, []);

  return [microphoneList, speakerList];
};

export default useCameras;