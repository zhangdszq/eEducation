package io.agora.rtc.education.im;


import io.agora.rtc.education.data.ChannelDataRepository;

public class IMContext {

    private IMStrategy mImStrategy;
    private ChannelDataRepository mChannelDataRepository;

    public IMContext(IMStrategy mImStrategy) {
        this.mImStrategy = mImStrategy;
    }

    public void setChannelDataRepository(ChannelDataRepository channelDataRepository) {
        this.mChannelDataRepository = channelDataRepository;
        this.mImStrategy.setChannelDataRepository(channelDataRepository);
    }

    public void join(String uid) {
        mImStrategy.login(uid);
    }

    public void joinChannel(String channel) {
        mImStrategy.joinChannel(channel);
    }

    public void leaveChannel() {
        mImStrategy.leaveChannel();
    }

    public void muteLocalAudio(boolean isMute) {
        mImStrategy.muteLocalAudio(isMute);
    }

    public void muteLocalVideo(boolean isMute) {
        mImStrategy.muteLocalVideo(isMute);
    }

}
