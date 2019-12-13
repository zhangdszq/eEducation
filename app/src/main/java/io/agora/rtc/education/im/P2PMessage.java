package io.agora.rtc.education.im;

public class P2PMessage {
    public P2PMessage() {
    }

    public P2PMessage(int cmd) {
        this.cmd = cmd;
    }

    public P2PMessage(int cmd, String text) {
        this.cmd = cmd;
        this.text = text;
    }

    public int cmd;
    public String text;
}
