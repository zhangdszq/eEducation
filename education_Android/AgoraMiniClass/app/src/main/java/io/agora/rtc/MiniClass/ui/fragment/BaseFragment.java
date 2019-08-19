package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Looper;
import android.support.v4.app.Fragment;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.rtm.RtmDemoAPI;
import io.agora.rtc.MiniClass.model.rtm.RtmManager;
import io.agora.rtc.MiniClass.model.videocall.RtcWorkerThread;
import io.agora.rtc.RtcEngine;

public abstract class BaseFragment extends Fragment {

    protected OnFragmentInteractionListener mListener;

    protected RtmManager rtmManager() {
        return AGApplication.the().getRtmManager();
    }

    protected RtcWorkerThread rtcWorkerThread() {
        return AGApplication.the().getWorkerThread();
    }

    protected RtmDemoAPI rtmDemoAPI() {
        return rtmManager().getRtmDemoAPI();
    }

    protected RtcEngine rtcEngine() {
        return rtcWorkerThread().getRtcEngine();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }


    public void onActivityEvent(final BaseEvent event) {
        if (mListener == null)
            return;

        if (Looper.myLooper() == Looper.getMainLooper()) {
            onActivityMainThreadEvent(event);
        } else {
            ((Activity)mListener).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onActivityMainThreadEvent(event);
                }
            });
        }
    }

    public interface OnFragmentInteractionListener {

        void onFragmentEvent(BaseEvent event);
    }

    protected void onActivityMainThreadEvent(BaseEvent event){};

}
