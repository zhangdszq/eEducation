package io.agora.rtc.MiniClass.model.event;

import java.util.List;

import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;

public class UpdateMembersEvent extends BaseEvent {

    public static final int EVENT_TYPE_UPDATE_MEMBERS = 101;

    private List<RtmRoomControl.UserAttr> userAttrList;
    private RtmRoomControl.UserAttr teacherAttr;

    public UpdateMembersEvent() {
        super(EVENT_TYPE_UPDATE_MEMBERS);
    }

    public UpdateMembersEvent(List<RtmRoomControl.UserAttr> userAttrList, RtmRoomControl.UserAttr teacherAttr) {
        super(EVENT_TYPE_UPDATE_MEMBERS);
        this.userAttrList = userAttrList;
        this.teacherAttr = teacherAttr;
    }

    public List<RtmRoomControl.UserAttr> getUserAttrList() {
        return userAttrList;
    }

    public void setUserAttrList(List<RtmRoomControl.UserAttr> userAttrList) {
        this.userAttrList = userAttrList;
    }

    public RtmRoomControl.UserAttr getTeacherAttr() {
        return teacherAttr;
    }

    public void setTeacherAttr(RtmRoomControl.UserAttr teacherAttr) {
        this.teacherAttr = teacherAttr;
    }
}
