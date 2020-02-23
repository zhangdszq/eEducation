package io.agora.education.classroom.bean.msg;

import io.agora.education.classroom.bean.JsonBean;

public class ChannelMsg extends JsonBean {

    public String account;
    public String content;
    public String link;
    public String url;
    public transient boolean isMe;

    public ChannelMsg(String account, String content) {
        this.account = account;
        this.content = content;
        isMe = true;
    }

}
