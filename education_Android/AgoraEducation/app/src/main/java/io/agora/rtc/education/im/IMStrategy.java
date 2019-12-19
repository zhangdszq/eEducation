package io.agora.rtc.education.im;

import io.agora.rtc.education.data.ChannelDataRepository;

public interface IMStrategy {

    void login(String uid) ;

    void joinChannel(String channel);

    void setChannelDataRepository(ChannelDataRepository channelDataRepository);

    void leaveChannel();

    void muteLocalVideo(boolean isMute);

    void muteLocalAudio(boolean isMute);

    void muteLocalChat(boolean isMute);

    ChannelMsg sendChannelMessage(String text);

    void sendMessage(String peerId, int cmd);

    void release();
}
