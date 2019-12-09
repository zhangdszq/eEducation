package io.agora.rtc.education.room.bean;

public class User {
    public String account; // 昵称
    public int audio; // 0:mute, 1: un mute
    public int video; // 0:mute, 1: un mute

    public int getUid() {
        return 0;
    }
}
