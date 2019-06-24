package io.agora.rtc.MiniClass.model.event;

public class SimpleEvent extends BaseEvent {
    public static final int EVENT_EXIT = 1;

    public int eventType;
    public int value;
    public String str;

    public SimpleEvent(int eventType) {
        this.eventType = eventType;
    }

}
