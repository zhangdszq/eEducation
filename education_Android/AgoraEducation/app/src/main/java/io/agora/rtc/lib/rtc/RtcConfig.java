package io.agora.rtc.lib.rtc;

public class RtcConfig {
    int localUid;
    String currentChannel;

    public void reset() {
        localUid = 0;
        currentChannel = null;
    }

    public RtcConfig(int localUid, String currentChannel) {
        this.localUid = localUid;
        this.currentChannel = currentChannel;
    }

    RtcConfig() {
    }

    public int getLocalUid() {
        return localUid;
    }

    public String getCurrentChannel() {
        return currentChannel;
    }
}
