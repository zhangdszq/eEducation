package io.agora.rtc.education.constant;

public class Constant {

    public interface RoomType{
        int ONE_TO_ONE = 0;
        int SMALL_CLASS = 1;
        int BIG_CLASS = 2;
    }

    public interface WhiteboardUrl {
        String JOIN = "https://cloudcapiv4.herewhite.com/room/join";
    }

    public static String RTM_CHANNEL_KEY_TEACHER = "teacher";

    public static int SHARE_UID = 7;
}
