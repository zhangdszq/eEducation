package io.agora.rtc.education.room.bean;

public class Teacher extends User {
    public int uid;

    @Override
    public int getUid() {
        return uid;
    }

    public int mute_chat; //全员禁言: 默认用0表示不禁言 |1表示禁言
    public int shared_uid; //屏幕共享: 默认用0，共享时更新为真实uid
    public int link_uid; //连麦uid: 默认用0，连麦时更新为真实uid
    public String whiteboard_uid; //白板uid: 默认用0
    public int class_state; //课程状态: 默认是0 表示关闭上课，1 开始上课
}
