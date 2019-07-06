package io.agora.rtc.MiniClass.model.bean;

public class ChannelMessage {
    public String name;
    public Args args;

    public static class Args {
        public String uid;
        public String message;
        public int role;
    }

    public static final String SEND_NAME = "Chat";
}
