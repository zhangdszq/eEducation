package io.agora.rtc.MiniClass.model.event;

public class ShowToastEvent extends BaseEvent {
    public String content;

    public ShowToastEvent(String content) {
        this.content = content;
    }
}
