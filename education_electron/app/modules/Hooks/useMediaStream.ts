import { useState, useEffect } from "react";

import { createLogger } from "../../utils";

const useStreamLog = createLogger("[UseStreamHook]", "#fff", "#1890ff", true);

const useMediaStream = (client: any, info: {shareStreamId: number, shareByLocal: boolean}): any[] => {
  const [streamList, setStreamList] = useState<any[]>([]);
  const [count, setCount] = useState(0);
  const {shareStreamId, shareByLocal} = info;

  useEffect(() => {
    let mounted = true;
    // add when subscribed
    const addRemote = (id: number, elapsed: number) => {
      if (!mounted) {
        return;
      }
      useStreamLog(`=>>> incoming remote stream ${id} =>>>`);
      console.log(shareStreamId);
      const [local, share] = [id === shareStreamId && shareByLocal, id === shareStreamId] 
      useStreamLog(`local ${local}; share: ${share}; id: ${id}`)
      setStreamList(streamList => {
        streamList.push({
          local,
          share,
          id
        });
        return streamList;
      });
      setCount(count => count + 1);
    };
    // remove stream
    const removeRemote = (id: number, reason: number) => {
      if (!mounted) {
        return;
      }
      useStreamLog(`=>>> remove remote stream ${id} =>>>`);
      const index = streamList.findIndex(item => item.id === id);
      if (index !== -1) {
        setStreamList(streamList => {
          streamList.splice(index, 1);
          return streamList;
        });
        setCount(count => count - 1);
      }
    };
    // add when published
    const addLocal = (channel: string, id: number, elapsed: number) => {
      if (!mounted) {
        return;
      }
      useStreamLog(`=>>> incoming local stream ${id} =>>>`);
      const [local, share] = [true, false] 
      useStreamLog(`local ${local}; share: ${share}; id: ${id}`)
      setStreamList(streamList => {
        streamList.push({
          local,
          share,
          id
        });
        return streamList;
      });
      setCount(count => count + 1);
    };

    if (client) {
      client.on("joinedchannel", addLocal);
      client.on("userjoined", addRemote);
      client.on("removestream", removeRemote);
    }

    return () => {
      mounted = false;
      if (client) {
        client.off("joinedchannel", addLocal);
        client.off("userjoined", addRemote);
        client.off("removestream", removeRemote);
      }
    };
  }, [0]);

  return [streamList, count];
};

export default useMediaStream;
