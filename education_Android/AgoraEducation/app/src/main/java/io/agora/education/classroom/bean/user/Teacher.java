package io.agora.education.classroom.bean.user;

public class Teacher extends User {

    public int mute_chat; // mute chat all -- 0(default): un mute, 1: mute
    public int grant_board; // disable board all -- 0: disable, 1(default): enable
    public int shared_uid; // screen share -- 0(default), update when start share
    public int link_uid; // co-host uid -- 0(default)，update when co-hosting
    public String whiteboard_uid; // white board uid -- 0(default)
    public int class_state; // class state -- 0(default): closed，1: started

}
