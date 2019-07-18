package io.agora.rtc.MiniClass.ui.activity;

import android.os.Looper;
import android.support.v7.app.AppCompatActivity;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.rtm.RtmDemoAPI;
import io.agora.rtc.MiniClass.model.rtm.RtmManager;
import io.agora.rtc.MiniClass.model.videocall.RtcWorkerThread;
import io.agora.rtc.MiniClass.ui.fragment.BaseFragment;

public abstract class BaseActivity extends AppCompatActivity
        implements BaseFragment.OnFragmentInteractionListener {


    protected RtmManager rtmManager() {
        return AGApplication.the().getRtmManager();
    }

    protected RtcWorkerThread rtcWorkerThread() {
        return AGApplication.the().getWorkerThread();
    }

    protected RtmDemoAPI rtmDemoAPI() {
        return rtmManager().getRtmDemoAPI();
    }

    @Override
    public void onFragmentEvent(final BaseEvent event) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            onFragmentMainThreadEvent(event);
        } else {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onFragmentMainThreadEvent(event);
                }
            });
        }
    }

    protected abstract void onFragmentMainThreadEvent(BaseEvent event);
}
