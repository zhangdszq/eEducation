package io.agora.rtc.MiniClass.model.event;

import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;

public class MuteEvent extends BaseEvent{
    public static final int EVENT_TYPE_MUTE = 100;
    private RtmRoomControl.UserAttr userAttr;
    public String muteType;

    public MuteEvent(RtmRoomControl.UserAttr userAttr) {
        super(EVENT_TYPE_MUTE);
        this.userAttr = userAttr;
    }

    public RtmRoomControl.UserAttr getUserAttr() {
        return userAttr;
    }
}
