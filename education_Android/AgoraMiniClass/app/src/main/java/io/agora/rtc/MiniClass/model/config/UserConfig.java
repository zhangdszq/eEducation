package io.agora.rtc.MiniClass.model.config;

import android.text.TextUtils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.constant.Constant;

public class UserConfig {
    private static volatile Constant.Role role = Constant.Role.AUDIENCE;//teacher: 2, student: 1, audience: 0;

    private static volatile int rtcUserId;
    private static volatile String rtcChannelName;
    private static volatile String rtmUserId;
    private static volatile String rtmChannelName;
    private static volatile String rtmUserName;

    private static volatile RtmRoomControl.ChannelAttr channelAttr;

    private static Map<String, RtmRoomControl.UserAttr> teacherAttrs = new ConcurrentHashMap<>();
    private static Map<String, RtmRoomControl.UserAttr> studentAttrs = new ConcurrentHashMap<>();
    private static Map<String, RtmRoomControl.UserAttr> audienceAttrs = new ConcurrentHashMap<>();

    public static RtmRoomControl.UserAttr getTeacherAttr() {
        Collection<RtmRoomControl.UserAttr> c = teacherAttrs.values();
        Iterator<RtmRoomControl.UserAttr> it = c.iterator();
        if (it.hasNext())
            return it.next();
        else
            return null;
    }

    public static void addTeacherAttr(RtmRoomControl.UserAttr teacherAttr) {
        if (teacherAttr == null || TextUtils.isEmpty(teacherAttr.streamId))
            return;
        teacherAttrs.put(teacherAttr.streamId, teacherAttr);
    }

    public static void addStudentAttr(RtmRoomControl.UserAttr studentAttr) {
        if (studentAttr == null || TextUtils.isEmpty(studentAttr.streamId))
            return;

        studentAttrs.put(studentAttr.streamId, studentAttr);
    }

    public static List<RtmRoomControl.UserAttr> getStudentAttrsList() {
        return new ArrayList<>(studentAttrs.values());
    }

    public static void addAudienceAttr(RtmRoomControl.UserAttr audienceAttr) {
        if (audienceAttr == null || TextUtils.isEmpty(audienceAttr.streamId))
            return;

        audienceAttrs.put(audienceAttr.streamId, audienceAttr);
    }

    public static List<RtmRoomControl.UserAttr> getAudienceAttrsList() {
        return new ArrayList<>(audienceAttrs.values());
    }

    public static RtmRoomControl.UserAttr removeMember(String uid) {
        if (TextUtils.isEmpty(uid))
            return null;

        RtmRoomControl.UserAttr result = null;
        result = teacherAttrs.remove(uid);
        if (result == null)
            result = studentAttrs.remove(uid);
        if (result == null)
            result = audienceAttrs.remove(uid);
        return result;
    }

    public static void putMember(RtmRoomControl.UserAttr attr) {
        if (attr == null || TextUtils.isEmpty(attr.streamId))
            return;

        if (Constant.Role.TEACHER.strValue().equals(attr.role)) {
            addTeacherAttr(attr);
        } else if (Constant.Role.STUDENT.strValue().equals(attr.role)) {
            addStudentAttr(attr);
        } else {
            addAudienceAttr(attr);
        }
    }

    public static RtmRoomControl.UserAttr getUserAttrByUserId(String userId) {
        if (TextUtils.isEmpty(userId))
            return null;

        RtmRoomControl.UserAttr attr = teacherAttrs.get(userId);

        if (attr == null)
            attr = studentAttrs.get(userId);

        if (attr == null)
            attr = audienceAttrs.get(userId);

        return attr;
    }

    public static void setStudentAttrs(List<RtmRoomControl.UserAttr> channelMembersAttrList) {
        UserConfig.studentAttrs = new ConcurrentHashMap<>();
        if (channelMembersAttrList == null)
            return;

        for (RtmRoomControl.UserAttr userAttr : channelMembersAttrList) {
            if (userAttr != null && userAttr.streamId != null) {
                studentAttrs.put(userAttr.streamId, userAttr);
            }
        }
    }

    public static RtmRoomControl.ChannelAttr getChannelAttr() {
        return channelAttr;
    }

    public static void setChannelAttr(RtmRoomControl.ChannelAttr channelAttr) {
        UserConfig.channelAttr = channelAttr;
    }

    public static String getRtmServerId() {
        return rtmServerId;
    }

    public static void setRtmServerId(String rtmServerId) {
        UserConfig.rtmServerId = rtmServerId;
    }

    private volatile static String rtmServerId;

    public static void createUserId() {
        int userId = Math.abs((int) System.nanoTime());
        setRtcUserId(userId);
        setRtmUserId(String.valueOf(userId));
    }

    public static void resetUserId() {
        setRtmUserId(null);
        setRtcUserId(0);
    }

    public static Constant.Role getRole() {
        return role;
    }

    public static void setRole(Constant.Role role) {
        UserConfig.role = role;
    }

    public static String getRtmUserName() {
        return rtmUserName;
    }

    public static void setRtmUserName(String rtmUserName) {
        UserConfig.rtmUserName = rtmUserName;
    }

    private static String whiteBordUserId;

    public static int getRtcUserId() {
        return rtcUserId;
    }

    private static void setRtcUserId(int rtcUserId) {
        UserConfig.rtcUserId = rtcUserId;
    }

    public static String getRtcChannelName() {
        return rtcChannelName;
    }

    public static void setRtcChannelName(String rtcChannelName) {
        UserConfig.rtcChannelName = rtcChannelName;
    }

    public static String getRtmUserId() {
        return rtmUserId;
    }

    private static void setRtmUserId(String rtmUserId) {
        UserConfig.rtmUserId = rtmUserId;
    }

    public static String getRtmChannelName() {
        return rtmChannelName;
    }

    public static void setRtmChannelName(String rtmChannelName) {
        UserConfig.rtmChannelName = rtmChannelName;
    }

    public static String getWhiteBordUserId() {
        return whiteBordUserId;
    }

    public static void setWhiteBordUserId(String whiteBordUserId) {
        UserConfig.whiteBordUserId = whiteBordUserId;
    }

    public static void reset() {
        rtcUserId = 0;
        rtcChannelName = null;
        rtmUserId = null;
        rtmChannelName = null;
        whiteBordUserId = null;

        teacherAttrs = new ConcurrentHashMap<>();
        studentAttrs = new ConcurrentHashMap<>();
        audienceAttrs = new ConcurrentHashMap<>();
    }
}
