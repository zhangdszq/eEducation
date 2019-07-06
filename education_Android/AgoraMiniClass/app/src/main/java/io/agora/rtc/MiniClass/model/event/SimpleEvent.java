package io.agora.rtc.MiniClass.model.event;

public class SimpleEvent extends BaseEvent {
    public static final int EVENT_EXIT = 1;

    public int eventType;
    public int value1;
    public int value2;
    public String text1;
    public String text2;

    public SimpleEvent(int eventType) {
        super(eventType);
        this.eventType = eventType;
    }

}
