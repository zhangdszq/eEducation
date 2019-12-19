package io.agora.rtc.education.im.rtm;

import android.text.TextUtils;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.agora.rtc.education.constant.Constant;
import io.agora.rtc.education.data.ChannelDataRepository;
import io.agora.rtc.education.data.bean.Student;
import io.agora.rtc.education.data.bean.Teacher;
import io.agora.rtc.education.im.ChannelMsg;
import io.agora.rtc.education.im.IMStrategy;
import io.agora.rtc.education.im.P2PMessage;
import io.agora.rtc.lib.rtm.RtmManager;
import io.agora.rtc.lib.util.LogUtil;
import io.agora.rtm.ChannelAttributeOptions;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmChannel;
import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmMessage;
import io.agora.rtm.SendMessageOptions;

public class RtmStrategy implements IMStrategy {
    private RtmManager rtmManager;
    private EventListener eventListener;
    private RtmChannel rtmChannel;
    private LogUtil log = new LogUtil("RtmStrategy");
    private ChannelDataRepository mRepository;
    private String mRoom;
    private Gson gson = new Gson();

    public void setEventListener(EventListener eventListener) {
        this.eventListener = eventListener;
        rtmManager.registerListener(clientListener);
    }

    private RtmChannelListener channelListener = new RtmChannelListener() {
        @Override
        public void onMemberCountUpdated(int i) {
            if (eventListener != null) {
                eventListener.onChannelMemberCountUpdated(i);
            }
        }

        @Override
        public void onAttributesUpdated(List<RtmChannelAttribute> list) {
            parseChannelAttributes(list);
            if (eventListener != null)
                eventListener.onChannelAttributesUpdated();
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, RtmChannelMember rtmChannelMember) {
            if (eventListener == null)
                return;
            ChannelMsg msg;
            try {
                msg = gson.fromJson(rtmMessage.getText(), ChannelMsg.class);
            } catch (Exception e) {
                msg = null;
            }
            if (msg != null) {
                msg.isMe = myRtmUid().equals(rtmChannelMember.getUserId());
                eventListener.onChannelMessageReceived(msg, rtmChannelMember);
            }
        }

        @Override
        public void onMemberJoined(RtmChannelMember rtmChannelMember) {
        }

        @Override
        public void onMemberLeft(RtmChannelMember rtmChannelMember) {
            if (eventListener != null) {
                eventListener.onMemberLeft(rtmChannelMember);
            }
        }
    };

    private RtmManager.MyRtmClientListener clientListener = new RtmManager.MyRtmClientListener() {
        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String s) {
            if (eventListener == null)
                return;
            P2PMessage msg;
            try {
                msg = gson.fromJson(rtmMessage.getText(), P2PMessage.class);
            } catch (Exception e) {
                msg = null;
            }
            if (msg != null) {
                eventListener.onMessageReceived(msg, s);
            }
        }
    };


    public void parseChannelAttributes(List<RtmChannelAttribute> attributes) {
        log.i("parseChannelAttributes:");
        if (attributes == null || attributes.isEmpty()) {
            mRepository.resetData();
            return;
        }

        String teacherJson = null;
        Map<String, String> studentAttributesMap = new LinkedHashMap<>();
        for (RtmChannelAttribute attribute : attributes) {
            String key = attribute.getKey();
            String value = attribute.getValue();
            if (!TextUtils.isEmpty(key) && !TextUtils.isEmpty(value)) {
                if (key.equals(Constant.RTM_CHANNEL_KEY_TEACHER)) {
                    teacherJson = value;
                } else {
                    studentAttributesMap.put(attribute.getKey(), attribute.getValue());
                }
            }
        }

        if (studentAttributesMap.isEmpty() || studentAttributesMap.get(String.valueOf(myAttr().uid)) == null) {
            // 第一次得到数据不包含自己，等待有自己的数据后再渲染出来
            mRepository.resetData();
            return;
        }

        if (TextUtils.isEmpty(teacherJson)) {
            // 老师不在房间
            mRepository.setTeacher(null);
        } else {
            // 老师在房间
            try {
                mRepository.setTeacher(gson.fromJson(teacherJson, Teacher.class));
            } catch (Exception e) {
                mRepository.setTeacher(null);
            }
        }

        ArrayList<Student> students = new ArrayList<>();

        if (!studentAttributesMap.isEmpty()) {
            for (String key : studentAttributesMap.keySet()) {
                Student s;
                try {
                    s = gson.fromJson(studentAttributesMap.get(key), Student.class);
                    s.uid = Integer.parseInt(key);
                } catch (Exception e) {
                    s = null;
                }
                if (s != null) {
                    students.add(s);
                }
            }
        }
        mRepository.setStudents(students);
    }

    public String myRtmUid() {
        return String.valueOf(myAttr().uid);
    }

    @Override
    public void leaveChannel() {
        deleteMyAttrInChannel();
        rtmManager.leaveChannel(rtmChannel);
        rtmManager.releaseChannel(rtmChannel);
    }

    private void deleteMyAttrInChannel() {
        if (!TextUtils.isEmpty(mRoom)) {
            ChannelAttributeOptions options = new ChannelAttributeOptions(true);
            List<String> deleteKeys = new ArrayList<>();
            deleteKeys.add(myRtmUid());
            rtmManager.getRtmClient().deleteChannelAttributesByKeys(
                    mRoom,
                    deleteKeys,
                    options,
                    new ResultCallback<Void>() {
                        @Override
                        public void onSuccess(Void aVoid) {
                            log.i("deleteChannelAttributesByKeys success");
                        }

                        @Override
                        public void onFailure(ErrorInfo errorInfo) {
                            log.i("deleteChannelAttributesByKeys failed");
                        }
                    }
            );
        }
    }

    public ChannelMsg sendChannelMessage(String text) {
        ChannelMsg msg = new ChannelMsg();
        msg.account = myAttr().account;
        msg.content = text;
        msg.isMe = true;
        String json = gson.toJson(msg);
        rtmManager.sendChannelMsg(rtmChannel, json, null);
        return msg;
    }

    public Student getStudent(int uid) {
        return mRepository.getStudent(uid);
    }

    public static class EventListener {
        public void onMessageReceived(P2PMessage p2PMessage, String peerId) {
        }

        public void onJoinRtmChannelSuccess() {
        }

        public void onJoinRtmChannelFailure(ErrorInfo errorInfo) {
        }

        public void onChannelMessageReceived(ChannelMsg channelMsg, RtmChannelMember channelMember) {
        }

        public void onChannelAttributesUpdated() {
        }

        public void onErrorInfo(ErrorInfo errorInfo) {
        }

        public void onChannelMemberCountUpdated(int i) {
        }

        public void onMemberLeft(RtmChannelMember rtmChannelMember) {
        }
    }

    public RtmStrategy(RtmManager rtmManager, EventListener rtmListener) {
        this.rtmManager = rtmManager;
        mRepository = new ChannelDataRepository();
        setEventListener(rtmListener);
    }

    @Override
    public void login(String uid) {
        rtmManager.login(uid);
    }

    @Override
    public void joinChannel(String channel) {
        mRoom = channel;
        rtmChannel = rtmManager.createChannel(channel, channelListener);
        rtmManager.joinChannel(rtmChannel, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                if (eventListener != null)
                    eventListener.onJoinRtmChannelSuccess();
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                if (eventListener != null)
                    eventListener.onJoinRtmChannelFailure(errorInfo);
            }
        });
        addOrUpdateMyChannelAttribute();
    }

    @Override
    public void setChannelDataRepository(ChannelDataRepository channelDataRepository) {
        this.mRepository = channelDataRepository;
    }

    public void addOrUpdateMyChannelAttribute() {
        String myRtmUid = myRtmUid();
        ArrayList<RtmChannelAttribute> updateAttributes = new ArrayList<>();
        updateAttributes.add(
                new RtmChannelAttribute(myRtmUid, mRepository.getMyAttrJson(), myRtmUid, System.currentTimeMillis())
        );
        rtmManager.getRtmClient().addOrUpdateChannelAttributes(
                mRoom,
                updateAttributes,
                new ChannelAttributeOptions(true),
                new ResultCallback<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        log.i("addOrUpdateMyAttr success");
                    }

                    @Override
                    public void onFailure(ErrorInfo errorInfo) {
                        log.i("addOrUpdateMyAttr failed: " + errorInfo.toString());
                        if (eventListener != null) {
                            eventListener.onErrorInfo(errorInfo);
                        }
                    }
                });
    }

    public Teacher getTeacher() {
        return mRepository.getTeacher();
    }

    public ArrayList<Student> getStudents() {
        return mRepository.getStudents();
    }

    @Override
    public void muteLocalAudio(boolean isMute) {
        myAttr().audio = isMute ? 0 : 1;
        addOrUpdateMyChannelAttribute();
    }

    @Override
    public void muteLocalChat(boolean isMute) {
        myAttr().chat = isMute ? 0 : 1;
        addOrUpdateMyChannelAttribute();
    }

    @Override
    public void muteLocalVideo(boolean isMute) {
        myAttr().video = isMute ? 0 : 1;
        addOrUpdateMyChannelAttribute();
    }


    public void sendMessage(String peerId, int cmd) {
        String msg = gson.toJson(new P2PMessage(cmd));
        rtmManager.sendP2PMsg(peerId, msg, new SendMessageOptions(), null);
    }

    @Override
    public void release() {
        rtmManager.unregisterListener(clientListener);
        channelListener = null;
    }

    public void sendMessage(String peerId, int cmd, String text) {
    }

    public Student myAttr() {
        return mRepository.getMyAttr();
    }
}
