package io.agora.rtc.education.im.rtm;

import androidx.annotation.NonNull;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;

import io.agora.rtc.education.data.ChannelDataRepository;
import io.agora.rtc.education.im.ChannelMsg;
import io.agora.rtc.education.im.P2PMessage;
import io.agora.rtc.education.data.bean.Student;
import io.agora.rtc.education.data.bean.Teacher;
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

public class RtmRepository {
    private RtmManager rtmManager;
    private EventListener eventListener;
    private RtmChannel rtmChannel;
    private LogUtil log = new LogUtil("RtmRepository");
    private ChannelDataRepository mRepository;
    private String mRoom;
    private Gson gson = new Gson();

    private RtmChannelListener channelListener = new RtmChannelListener() {
        @Override
        public void onMemberCountUpdated(int i) {
            if (eventListener != null) {
                eventListener.onChannelMemberCountUpdated(i);
            }
        }

        @Override
        public void onAttributesUpdated(List<RtmChannelAttribute> list) {
            mRepository.parseChannelAttributes(list);
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

    public String myRtmUid() {
        return String.valueOf(myAttr().uid);
    }

    public void leaveChannel() {
        rtmManager.leaveChannel(rtmChannel);
        rtmManager.releaseChannel(rtmChannel);
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
    }

    public RtmRepository(RtmManager rtmManager, EventListener rtmListener, @NonNull Student myAttr) {
        this.rtmManager = rtmManager;
        this.eventListener = rtmListener;
        rtmManager.registerListener(clientListener);
        mRepository = new ChannelDataRepository();
        mRepository.setMyAttr(myAttr);
    }

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
                        log.i("addOrUpdateMyAttr failed: " + errorInfo.getErrorCode() + ","
                                + errorInfo.getErrorDescription());
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

    public void parseChannelAttributes(List<RtmChannelAttribute> attributes) {
        mRepository.parseChannelAttributes(attributes);
    }

    public void muteLocalAudio(boolean isMute) {
        myAttr().audio = isMute ? 0 : 1;
        addOrUpdateMyChannelAttribute();
    }

    public void muteLocalVideo(boolean isMute) {
        myAttr().video = isMute ? 0 : 1;
        addOrUpdateMyChannelAttribute();
    }

    public void sendCmd(String peerId, int cmd) {
        String msg = gson.toJson(new P2PMessage());
    }

    public void sendMessage(String peerId, String text) {
    }

    public Student myAttr() {
        return mRepository.getMyAttr();
    }
}
