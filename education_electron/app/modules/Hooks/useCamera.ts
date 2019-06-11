import { useState, useEffect } from 'react';

interface MediaDeviceInfo {
  devicename: string;
  deviceid: string;
}

const useCameras = (client: any): MediaDeviceInfo[] => {
  const [cameraList, setCameraList] = useState<MediaDeviceInfo[]>([]);

  useEffect(() => {
    let mounted = true;

    const onChange = () => {
      if (!client) {
        return;
      }
      setCameraList(client.getVideoDevices())
    };
    
    client && client.on('videodevicestatechanged', onChange);
    
    onChange();

    return () => {
      mounted = false;
      client && client.off('videodevicestatechanged', onChange);
    };
  }, []);

  return cameraList;
};

export default useCameras;
