package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.support.v4.app.Fragment;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.rtm.ChatDemoAPI;
import io.agora.rtc.MiniClass.model.rtm.ChatManager;
import io.agora.rtc.MiniClass.model.videocall.AgoraWorkerThread;
import io.agora.rtc.RtcEngine;

public abstract class BaseFragment extends Fragment {

    protected OnFragmentInteractionListener mListener;

    protected ChatManager chatManager() {
        return AGApplication.the().getChatManager();
    }

    protected AgoraWorkerThread workerThread() {
        return AGApplication.the().getWorkerThread();
    }

    protected ChatDemoAPI chatDemoAPI() {
        return chatManager().getChatDemoAPI();
    }

    protected RtcEngine rtcEngine() {
        return workerThread().getRtcEngine();
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

    public interface OnFragmentInteractionListener {

        void onFragmentEvent(BaseEvent event);
    }

    public abstract void onActivityEvent(BaseEvent event);

}
