package io.agora.rtc.MiniClass.model.bean;

import java.util.List;

public class JoinSuccessResponse {
    public String name;
    public Args args;

    public static class Args {
        public List<RtmRoomControl.UserAttr> members;
        public RtmRoomControl.ChannelAttr channelAttr;
    }
}
