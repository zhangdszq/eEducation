package io.agora.rtc.education;

import android.app.Application;

import io.agora.rtc.lib.rtc.RtcWorkerThread;
import io.agora.rtc.lib.rtm.RtmManager;
import io.agora.rtc.lib.util.SPUtil;
import io.agora.rtc.lib.util.ToastUtil;


public class AGApplication extends Application {

    private static AGApplication instance;
    private RtmManager rtmManager;
    private RtcWorkerThread rtcWorker;

    public static AGApplication the() {
        return instance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        initSpUtil();
    }

    public void initRtmManager() {
        rtmManager = RtmManager.createInstance(this, getString(R.string.agora_app_id));
    }

    public synchronized void initWorkerThread() {
        if (rtcWorker == null) {
            rtcWorker = new RtcWorkerThread("RTC", this);
            rtcWorker.start();

            rtcWorker.waitForReady();
        }
    }

    public void initSpUtil() {
        SPUtil.init(this);
    }

    public void initToastUtil() {
        ToastUtil.init(this);
    }

    public synchronized void deInitWorkerThread() {
        rtcWorker.exit();
        try {
            rtcWorker.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        rtcWorker = null;
    }

    public RtcWorkerThread getRtcWorker() {
        return rtcWorker;
    }

    public RtmManager getRtmManager() {
        return rtmManager;
    }
}
