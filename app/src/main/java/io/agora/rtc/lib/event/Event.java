package io.agora.rtc.lib.event;

public class Event {
    private int code;
    private Object data;

    public Event(int code, Object data) {
        this.code = code;
        this.data = data;
    }

    public Event(int code) {
        this.code = code;
    }
}
