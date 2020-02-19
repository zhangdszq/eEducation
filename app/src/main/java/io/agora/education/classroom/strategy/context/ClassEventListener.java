package io.agora.education.classroom.strategy.context;

import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.user.Teacher;
import io.agora.sdk.annotation.NetworkQuality;

public interface ClassEventListener {

    void onTeacherInit(Teacher teacher);

    void onNetworkQualityChanged(@NetworkQuality int quality);

    void onClassStateChanged(boolean isStart);

    void onWhiteboardIdChanged(String id);

    void onLockWhiteboard(boolean locked);

    void onMuteLocalChat(boolean muted);

    void onMuteAllChat(boolean muted);

    void onChannelMsgReceived(ChannelMsg msg);

    void onScreenShareJoined(int uid);

    void onScreenShareOffline(int uid);

}
