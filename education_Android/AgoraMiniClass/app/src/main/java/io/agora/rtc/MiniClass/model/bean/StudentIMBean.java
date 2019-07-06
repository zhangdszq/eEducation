package io.agora.rtc.MiniClass.model.bean;

public class StudentIMBean {
    public String name;
    public boolean isMuteVideo;
    public boolean isMuteAudio;

    public StudentIMBean() {
    }

    public StudentIMBean(String name, boolean isMuteVideo, boolean isMuteAudio) {
        this.name = name;
        this.isMuteVideo = isMuteVideo;
        this.isMuteAudio = isMuteAudio;
    }

    public StudentIMBean(String name) {
        this.name = name;
    }
}
