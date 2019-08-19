package io.agora.rtc.MiniClass;

import android.app.Application;

import io.agora.rtc.MiniClass.model.rtm.RtmManager;
import io.agora.rtc.MiniClass.model.videocall.RtcWorkerThread;


public class AGApplication extends Application {

    private static AGApplication sInstance;
    private RtmManager mRtmManager;
    private RtcWorkerThread mWorkerThread;

    public static AGApplication the() {
        return sInstance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        sInstance = this;

        mRtmManager = new RtmManager(this);
        mRtmManager.init();
    }

    public synchronized void initWorkerThread() {
        if (mWorkerThread == null) {
            mWorkerThread = new RtcWorkerThread("Agora", this);
            mWorkerThread.start();

            mWorkerThread.waitForReady();
        }
    }

    public synchronized RtcWorkerThread getWorkerThread() {
        return mWorkerThread;
    }

    public synchronized void deInitWorkerThread() {
        mWorkerThread.exit();
        try {
            mWorkerThread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        mWorkerThread = null;
    }

    public RtmManager getRtmManager() {
        return mRtmManager;
    }
}
