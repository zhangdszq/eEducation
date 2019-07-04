package io.agora.rtc.MiniClass.ui.activity;

import android.support.v7.app.AppCompatActivity;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.model.rtm.ChatDemoAPI;
import io.agora.rtc.MiniClass.model.rtm.ChatManager;
import io.agora.rtc.MiniClass.model.videocall.AgoraWorkerThread;
import io.agora.rtc.MiniClass.ui.fragment.BaseFragment;

public abstract class BaseActivity extends AppCompatActivity
        implements BaseFragment.OnFragmentInteractionListener {


    protected ChatManager chatManager() {
        return AGApplication.the().getChatManager();
    }

    protected AgoraWorkerThread workerThread() {
        return AGApplication.the().getWorkerThread();
    }

    protected ChatDemoAPI chatDemoAPI() {
        return chatManager().getChatDemoAPI();
    }

}
