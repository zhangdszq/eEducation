package io.agora.rtc.MiniClass.model.bean;

public class RtmRoomControl {

    public static class UserAttr {
        public String role;
        public String streamId;
        public String name;

        public boolean isMuteVideo;
        public boolean isMuteAudio;
    }

    public static class ChannelAttr {
        public int isSharing;
        public int isRecording;
        public int shareId;
        public String whiteboardId;
        public String teacherId;
    }
}
