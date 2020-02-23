package io.agora.education.classroom.bean.user;

import io.agora.education.classroom.bean.JsonBean;
import io.agora.education.classroom.bean.msg.Cmd;
import io.agora.education.classroom.mediator.MsgMediator;

public class User extends JsonBean {

    public int uid;
    public String account; // nickname
    public int audio; // mute local audio -- 0: mute, 1: un mute
    public int video; // mute local video -- 0: mute, 1: un mute
    public transient boolean isRtcOnline;

    public String getUserId() {
        return String.valueOf(uid);
    }

    public void sendMessageTo(Cmd cmd) {
        MsgMediator.sendMessageToPeer(this, cmd);
    }

}
