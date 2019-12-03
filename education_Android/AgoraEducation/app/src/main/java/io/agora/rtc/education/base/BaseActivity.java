package io.agora.rtc.education.base;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.widget.eyecare.EyeCare;
import io.agora.rtc.lib.rtc.RtcWorkerThread;
import io.agora.rtc.lib.rtm.RtmManager;

public abstract class BaseActivity extends AppCompatActivity {

    protected EyeCare.EyeCareView eyeCareView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        final View layout = findViewById(Window.ID_ANDROID_CONTENT);
        layout.getViewTreeObserver().addOnGlobalLayoutListener(
                new ViewTreeObserver.OnGlobalLayoutListener() {
                    @Override
                    public void onGlobalLayout() {
                        layout.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                        initData();
                    }
                });

        initUI(savedInstanceState);

        if (EyeCare.isNeedShow()) {
            showEyeCareView();
        }
    }

    protected void dismissEyeCareView() {
        if (eyeCareView != null)
            eyeCareView.setVisibility(View.GONE);
    }

    protected void showEyeCareView() {
        if (eyeCareView == null) {
            eyeCareView = new EyeCare.EyeCareView(this);
            addContentView(eyeCareView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }

        eyeCareView.setVisibility(View.VISIBLE);
    }

    protected abstract void initUI(@Nullable Bundle savedInstanceState);

    protected void initData() {
    }

    protected RtmManager rtmManager() {
        return AGApplication.the().getRtmManager();
    }

    protected RtcWorkerThread rtcWorker() {
        return AGApplication.the().getRtcWorker();
    }
}
