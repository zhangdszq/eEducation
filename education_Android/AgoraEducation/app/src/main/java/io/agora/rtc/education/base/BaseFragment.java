package io.agora.rtc.education.base;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.AGApplication;
import io.agora.rtc.lib.rtc.RtcWorkerThread;
import io.agora.rtc.lib.rtm.RtmManager;

public abstract class BaseFragment extends Fragment {

    protected Context mContext;

    protected RtmManager rtmManager() {
        return AGApplication.the().getRtmManager();
    }

    protected RtcWorkerThread rtcWorker() {
        return AGApplication.the().getRtcWorker();
    }

//    protected RtmDemoAPI rtmDemoAPI() {
//        return rtmManager().getRtmDemoAPI();
//    }

    protected RtcEngine rtcEngine() {
        return AGApplication.the().getRtcWorker().getRtcEngine();
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        mContext = context;
    }

    protected void runOnUiThread(Runnable r) {
        Activity activity = getActivity();
        if (activity != null) {
            activity.runOnUiThread(r);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mContext = null;
    }
}
