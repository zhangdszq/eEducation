package io.agora.rtc.MiniClass.model.bean;

public class JoinRequest {
    public final String name = "Join";
    public Args args;

    public static class Args {
        public String channel;
        public RtmRoomControl.UserAttr userAttr;
    }

}
