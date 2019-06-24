package io.agora.rtc.MiniClass.model.videocall;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;


import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.RtcEngine;

public class AgoraWorkerThread extends HandlerThread {
    private final static LogUtil log = new LogUtil("AgoraWorkerThread");

    private boolean mReady;
    private Context mContext;

    public AgoraWorkerThread(String name, Context context) {
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
            log.d("wait for " + AgoraWorkerThread.class.getSimpleName());
        }
    }

    private Handler mHandler;

    private IRtcEngineEventHandler mRtcEngineEventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            super.onJoinChannelSuccess(channel, uid, elapsed);
        }
    };

    private IRtcEngineEventHandler mRtcHandlerForUpdateUI;

    @Override
    protected void onLooperPrepared() {
        mHandler = new Handler(Looper.myLooper());
    }

    private RtcEngine mRtcEngine;

    public final void initRtc(final IRtcEngineEventHandler rtcHandlerForUpdateUI) {
        runTask(new Runnable() {
            @Override
            public void run() {
                mRtcHandlerForUpdateUI = rtcHandlerForUpdateUI;
                ensureRtcEngineReadyLock();
            }
        });
    }

    public final void joinChannel(final String channel, final int uid) {

        runTask(new Runnable() {
            @Override
            public void run() {

                mRtcEngine.enableAudio();
                mRtcEngine.enableVideo();
                mRtcEngine.enableAudioVolumeIndication(200, 3); // 200 ms

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

    public final void leaveChannel(final String channel) {
        runTask(new Runnable() {
            @Override
            public void run() {
                if (mRtcEngine != null) {
                    mRtcEngine.leaveChannel();
                }
                log.d("leaveChannel " + channel);
            }
        });
    }

    public final void destroyRtc() {
        runTask(new Runnable() {
            @Override
            public void run() {
                RtcEngine.destroy();
            }
        });
    }

    private RtcEngine ensureRtcEngineReadyLock() {
        if (mRtcEngine == null) {
            String appId = mContext.getString(R.string.agora_rtc_app_id);
            if (TextUtils.isEmpty(appId)) {
                throw new RuntimeException("NEED TO use your App ID, get your own ID at https://dashboard.agora.io/");
            }
            try {
                mRtcEngine = RtcEngine.create(mContext, appId, mRtcEngineEventHandler);
            } catch (Exception e) {
                log.e(Log.getStackTraceString(e));
                throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
            }

            mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        }
        return mRtcEngine;
    }


    public RtcEngine getRtcEngine() {
        return mRtcEngine;
    }

    public void exit() {
        log.d("exit()");
        quitSafely();
    }
}
