package io.agora.education.classroom.mediator;

import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.Cmd;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.bean.user.User;
import io.agora.sdk.manager.RtmManager;

public class MsgMediator {

    public static void sendMessageToPeer(User user, Cmd cmd) {
        RtmManager.instance().sendMessageToPeer(String.valueOf(user.uid), new PeerMsg(cmd).toJsonString());
    }

    public static void sendMessage(ChannelMsg msg) {
        RtmManager.instance().sendMessage(msg.toJsonString());
    }

}
