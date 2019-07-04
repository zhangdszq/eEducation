package io.agora.rtc.MiniClass.model.bean;

public class UpdateUserAttr {
    public final String name = "UpdateUserAttr";
    public Args args;

    public static class Args {
        public String uid;
        public RtmRoomControl.UserAttr userAttr;
    }
}
