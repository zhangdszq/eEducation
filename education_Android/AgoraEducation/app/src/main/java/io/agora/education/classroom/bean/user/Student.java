package io.agora.education.classroom.bean.user;

import androidx.annotation.NonNull;

import io.agora.rtc.Constants;
import io.agora.sdk.annotation.ClientRole;

public class Student extends User implements Cloneable {

    public int chat; // enable chat -- 0: disable, 1: enable
    public int grant_board; // enable board -- 0: disable, 1: enable
    public transient boolean isGenerate; // create by local

    public Student(boolean isGenerate) {
        this.isGenerate = isGenerate;
    }

    public Student(int uid, String account, @ClientRole int role) {
        this.uid = uid;
        this.account = account;
        this.video = role == Constants.CLIENT_ROLE_AUDIENCE ? 0 : 1;
        this.audio = role == Constants.CLIENT_ROLE_AUDIENCE ? 0 : 1;
        this.chat = 1;
        this.isGenerate = true;
    }

    @NonNull
    @Override
    public Student clone() throws CloneNotSupportedException {
        return (Student) super.clone();
    }

}
