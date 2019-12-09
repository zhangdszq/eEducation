package io.agora.rtc.education.room.miniclass;

import android.view.SurfaceView;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.room.bean.Student;
import io.agora.rtc.lib.rtc.RtcWorkerThread;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtc.video.VideoEncoderConfiguration;

public class RtcDelegate {
    private RtcWorkerThread rtcWorker;
    private RtcEngine rtcEngine;

    public RtcDelegate(RtcWorkerThread rtcWorker, IRtcEngineEventHandler handler) {
        this.rtcWorker = rtcWorker;
        this.rtcEngine = rtcWorker.getRtcEngine();
        this.rtcWorker.setRtcEventHandler(handler);
    }

    public void joinChannel(String channel, Student myAttr) {
        rtcEngine.setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
        rtcEngine.enableAudio();
        rtcEngine.enableVideo();
        rtcEngine.muteLocalAudioStream(myAttr.audio == 0);
        rtcEngine.muteLocalVideoStream(myAttr.video == 0);
        VideoEncoderConfiguration config = new VideoEncoderConfiguration(
                VideoEncoderConfiguration.VD_360x360,
                VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15,
                VideoEncoderConfiguration.STANDARD_BITRATE,
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_LANDSCAPE
        );
        rtcEngine.setVideoEncoderConfiguration(config);
        rtcEngine.joinChannel(null, channel, "", myAttr.uid);
    }

    public void leaveChannel() {
        rtcWorker.leaveChannel();
    }

    public void muteLocalAudio(boolean isMute) {
        rtcEngine.muteLocalAudioStream(isMute);
    }

    public void muteLocalVideo(boolean isMute) {
        rtcEngine.muteLocalVideoStream(isMute);
    }

    public void bindLocalRtcVideo(SurfaceView surfaceView) {
        rtcEngine.setupLocalVideo(new VideoCanvas(surfaceView));
    }

    public void bindRemoteRtcVideo(int uid, SurfaceView surfaceView) {
        rtcEngine.setupRemoteVideo(new VideoCanvas(surfaceView, VideoCanvas.RENDER_MODE_HIDDEN, uid));
    }
}
