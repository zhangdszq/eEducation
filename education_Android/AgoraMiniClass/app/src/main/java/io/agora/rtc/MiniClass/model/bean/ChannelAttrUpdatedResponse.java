package io.agora.rtc.MiniClass.model.bean;

public class ChannelAttrUpdatedResponse {
    public String name;
    public Args args;

    public static class Args {
        public RtmRoomControl.ChannelAttr channelAttr;
        public String uid;
    }
}
