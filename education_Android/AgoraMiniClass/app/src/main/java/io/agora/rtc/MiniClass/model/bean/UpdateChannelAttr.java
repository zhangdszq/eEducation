package io.agora.rtc.MiniClass.model.bean;

public class UpdateChannelAttr {
    public final String name = "UpdateChannelAttr";
    public Args args;

    public static class Args {
        public RtmRoomControl.ChannelAttr channelAttr;
    }
}
