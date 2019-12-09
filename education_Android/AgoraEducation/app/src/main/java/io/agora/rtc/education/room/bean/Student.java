package io.agora.rtc.education.room.bean;

public class Student extends User {
    public transient int uid;

    @Override
    public int getUid() {
        return uid;
    }
}
