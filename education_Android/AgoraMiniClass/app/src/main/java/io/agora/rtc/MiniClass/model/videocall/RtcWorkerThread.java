package io.agora.rtc.MiniClass.model.videocall;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.view.SurfaceView;


import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtc.video.VideoEncoderConfiguration;

public class RtcWorkerThread extends HandlerThread {
    private final static LogUtil log = new LogUtil("RtcWorkerThread");

    private boolean mReady;
    private Context mContext;

    public RtcWorkerThread(String name, Context context) {
        super(name);
        mContext = context.getApplicationContext();
    }

    public final void waitForReady() {
        while (mHandler == null) {
            try {
                Thread.sleep(20);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            log.d("wait for " + RtcWorkerThread.class.getSimpleName());
        }
    }

    private Handler mHandler;

    private IRtcEngineEventHandler mRtcEngineEventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            if (mRtcHandler != null)
                mRtcHandler.onJoinChannelSuccess(channel, uid, elapsed);
        }

        @Override
        public void onLastmileProbeResult(LastmileProbeResult result) {
            if (mRtcHandler != null)
                mRtcHandler.onLastmileProbeResult(result);
        }

        @Override
        public void onLastmileQuality(int quality) {
            if (mRtcHandler != null)
                mRtcHandler.onLastmileQuality(quality);
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            if (mRtcHandler != null)
                mRtcHandler.onUserJoined(uid, elapsed);
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            if (mRtcHandler != null)
                mRtcHandler.onUserOffline(uid, reason);
        }

        @Override
        public void onUserMuteAudio(int uid, boolean muted) {
            if (mRtcHandler != null)
                mRtcHandler.onUserMuteAudio(uid, muted);
        }

        @Override
        public void onUserMuteVideo(int uid, boolean muted) {
            if (mRtcHandler != null)
                mRtcHandler.onUserMuteVideo(uid, muted);
        }
    };

    private volatile IRtcEngineEventHandler mRtcHandler;

    @Override
    protected void onLooperPrepared() {
        mHandler = new Handler(Looper.myLooper());
        ensureRtcEngineReadyLock();
    }

    private RtcEngine mRtcEngine;

    public final void setRtcEventHandler(final IRtcEngineEventHandler rtcHandler) {
        mRtcHandler = rtcHandler;
    }

    public final void joinChannel(final int role, final String channel, final int uid, final SurfaceView localView) {

        runTask(new Runnable() {
            @Override
            public void run() {

                mRtcEngine.setClientRole(role);

                if (localView != null) {
                    mRtcEngine.setupLocalVideo(new VideoCanvas(localView, Constants.RENDER_MODE_HIDDEN, 0));
                }

                mRtcEngine.setVideoEncoderConfiguration(new VideoEncoderConfiguration(
                        VideoEncoderConfiguration.VD_240x240,
                        VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_10,
                        VideoEncoderConfiguration.STANDARD_BITRATE,
                        VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_LANDSCAPE
                ));

                mRtcEngine.setParameters("{\"rtc.force_unified_communication_mode\":true}");//uc模式

                mRtcEngine.joinChannel(null, channel, "", uid);
                log.d("joinChannel " + channel + " " + uid);
            }
        });
    }

    public final void runTask(Runnable runnable) {
        if (Thread.currentThread() == this) {
            runnable.run();
        } else {
            mHandler.post(runnable);
        }
    }

    public final void leaveChannel() {
        runTask(new Runnable() {
            @Override
            public void run() {
                if (mRtcEngine != null) {
                    mRtcEngine.leaveChannel();
                }
                log.d("leaveChannel ");
            }
        });
    }

    public final void destroyRtc() {
        runTask(new Runnable() {
            @Override
            public void run() {
                RtcEngine.destroy();
                mRtcEngine = null;
            }
        });
    }

    private RtcEngine ensureRtcEngineReadyLock() {
        if (mRtcEngine == null) {
            String appId = mContext.getString(R.string.agora_app_id);
            if (TextUtils.isEmpty(appId)) {
                throw new RuntimeException("NEED TO use your App ID, get your own ID at https://dashboard.agora.io/");
            }
            try {
                mRtcEngine = RtcEngine.create(mContext, appId, mRtcEngineEventHandler);
            } catch (Exception e) {
                log.e(Log.getStackTraceString(e));
                throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
            }

            log.i("Rtc engine created.");
            mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
            mRtcEngine.enableAudio();
            mRtcEngine.enableVideo();
            mRtcEngine.enableWebSdkInteroperability(true);
        }
        return mRtcEngine;
    }


    public RtcEngine getRtcEngine() {
        return mRtcEngine;
    }

    public void exit() {
        log.d("exit()");
        quit();
        mHandler = null;
    }
}
