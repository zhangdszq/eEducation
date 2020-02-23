package io.agora.education.classroom.bean.msg;

import io.agora.education.classroom.bean.JsonBean;

public class PeerMsg extends JsonBean {

    private int cmd;
    public String text;

    public PeerMsg(Cmd cmd) {
        this.cmd = cmd.getCode();
    }

    public Cmd getCmd() {
        return Cmd.get(cmd);
    }

}
