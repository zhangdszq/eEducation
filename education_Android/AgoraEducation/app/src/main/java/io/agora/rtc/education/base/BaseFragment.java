package io.agora.rtc.education.base;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.AGApplication;
import io.agora.rtc.lib.rtc.RtcWorkerThread;
import io.agora.rtc.lib.rtm.RtmManager;

public abstract class BaseFragment extends Fragment {

    protected Context mContext;
    protected View mViewRoot;
    private FragmentStateListener mListener;

    protected abstract View initUI(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState);

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

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        if (mViewRoot != null) {
            ViewGroup parent = (ViewGroup) mViewRoot.getParent();
            if (parent != null) {
                parent.removeView(mViewRoot);
            }
            return mViewRoot;
        }
        mViewRoot = initUI(inflater, container, savedInstanceState);
        if (mListener != null)
            mListener.onCreatedView(this);
        return mViewRoot;
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

    public interface FragmentStateListener {
        void onCreatedView(Fragment fragment);
    }

    public void setFragmentStateListener(FragmentStateListener listener) {
        this.mListener = listener;
    }

}
