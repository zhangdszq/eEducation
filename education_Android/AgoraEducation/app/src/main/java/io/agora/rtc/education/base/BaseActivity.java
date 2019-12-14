package io.agora.rtc.education.base;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.widget.eyecare.EyeCare;
import io.agora.rtc.lib.rtc.RtcWorkerThread;
import io.agora.rtc.lib.rtm.RtmManager;
import io.agora.rtc.lib.util.StatusBarUtil;

public abstract class BaseActivity extends AppCompatActivity {

    protected EyeCare.EyeCareView eyeCareView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            AGApplication app = AGApplication.the();
            app.initRtmManager();
            app.initWorkerThread();
        }
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
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (EyeCare.isNeedShow()) {
            showEyeCareView();
        } else {
            dismissEyeCareView();
        }
    }

    @Override
    public void setContentView(int layoutResID) {
        super.setContentView(layoutResID);
        if (EyeCare.isNeedShow()) {
            showEyeCareView();
        } else {
            dismissEyeCareView();
        }
    }

    protected void dismissEyeCareView() {
        if (eyeCareView != null && eyeCareView.getVisibility() != View.GONE) {
            eyeCareView.setVisibility(View.GONE);
            StatusBarUtil.setStatusBarColor(this, R.color.colorPrimaryDark);
        }
    }

    protected void showEyeCareView() {
        if (eyeCareView == null) {
            eyeCareView = new EyeCare.EyeCareView(this);
            eyeCareView.setVisibility(View.GONE);
        }
        if (eyeCareView.getParent() == null) {
            addContentView(eyeCareView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
        if (eyeCareView.getVisibility() != View.VISIBLE) {
            eyeCareView.setVisibility(View.VISIBLE);
            StatusBarUtil.setStatusBarColor(this, R.color.eye_care_color);
        }
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
