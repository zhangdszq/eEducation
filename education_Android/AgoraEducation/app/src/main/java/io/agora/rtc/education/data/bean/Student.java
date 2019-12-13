package io.agora.rtc.education.data.bean;

public class Student extends User {
    public transient int uid;

    @Override
    public int getUid() {
        return uid;
    }
}
