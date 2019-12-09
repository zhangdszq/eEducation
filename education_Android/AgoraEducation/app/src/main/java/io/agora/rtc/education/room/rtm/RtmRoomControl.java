package io.agora.rtc.education.room.rtm;

public class RtmRoomControl {

    public static class UserAttr {
        public String role;
        public String streamId;
        public String name;

        public boolean isMuteVideo;
        public boolean isMuteAudio;
        public transient boolean isNetPoor;
    }

    public static class ChannelAttr {
        public int isSharing;
        public int isRecording;
        public int shareId;
        public String whiteboardId;
        public String teacherId;
    }
}
