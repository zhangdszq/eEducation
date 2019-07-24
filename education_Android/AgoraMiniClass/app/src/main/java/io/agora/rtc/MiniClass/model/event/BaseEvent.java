package io.agora.rtc.MiniClass.model.event;

public abstract class BaseEvent {

    private int eventType;
    public int value1;
    public int value2;
    public String text1;
    public String text2;
    public boolean bool1;

    public BaseEvent(int eventType) {
        this.eventType = eventType;
    }

    public int getEventType() {
        return eventType;
    }
}
