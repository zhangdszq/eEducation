package io.agora.rtc.MiniClass.model.bean;

import java.util.List;

public class Mute {
    public static final String MUTE_REQUEST = "Mute";
    public static final String UN_MUTE_REQUEST = "Unmute";
    public static final String MUTE_RESPONSE = "Muted";
    public static final String UN_MUTE_RESPONSE = "Unmuted";
    public static final String VIDEO = "video";
    public static final String AUDIO = "audio";
    public static final String CHAT = "chat";

    public String name;
    public Args args;

    public static class Args {
        public String type;
        public String uid;
        public List<String> target;
    }
}
