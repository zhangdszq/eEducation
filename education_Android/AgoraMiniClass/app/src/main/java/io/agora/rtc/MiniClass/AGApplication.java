package io.agora.rtc.MiniClass;

import android.app.Application;

import io.agora.rtc.MiniClass.model.rtm.ChatManager;
import io.agora.rtc.MiniClass.model.videocall.AgoraWorkerThread;


public class AGApplication extends Application {

    private static AGApplication sInstance;
    private ChatManager mChatManager;
    private AgoraWorkerThread mWorkerThread;

    public static AGApplication the() {
        return sInstance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        sInstance = this;

        mChatManager = new ChatManager(this);
        mChatManager.init();
    }

    public synchronized void initWorkerThread() {
        if (mWorkerThread == null) {
            mWorkerThread = new AgoraWorkerThread("Agora", this);
            mWorkerThread.start();

            mWorkerThread.waitForReady();
        }
    }

    public synchronized AgoraWorkerThread getWorkerThread() {
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

    public ChatManager getChatManager() {
        return mChatManager;
    }
}
