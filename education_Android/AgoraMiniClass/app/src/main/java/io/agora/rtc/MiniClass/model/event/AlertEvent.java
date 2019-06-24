package io.agora.rtc.MiniClass.model.event;

public class AlertEvent extends BaseEvent {
    public AlertEvent(String title, String detail) {
        this.title = title;
        this.detail = detail;
    }

    public String title;
    public String detail;
}
