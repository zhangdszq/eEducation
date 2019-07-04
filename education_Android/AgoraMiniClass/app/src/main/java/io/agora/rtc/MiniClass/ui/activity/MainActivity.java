package io.agora.rtc.MiniClass.ui.activity;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.SimpleEvent;
import io.agora.rtc.MiniClass.model.rtm.ChatManager;
import io.agora.rtc.MiniClass.model.util.AppUtil;
import io.agora.rtc.MiniClass.ui.fragment.BaseFragment;
import io.agora.rtc.MiniClass.ui.fragment.PreviewFragment;
import io.agora.rtc.MiniClass.ui.fragment.HomeFragment;
import io.agora.rtc.MiniClass.ui.fragment.LastMileFragment;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmClient;
import io.agora.rtm.internal.RtmManager;

public class MainActivity extends BaseActivity {

    private static final int PEMISSION_REQUEST_CODE = 101;

    private Fragment showingFragment;
    private BaseFragment homeFragment;
    private PreviewFragment previewFragment;
    private LastMileFragment lastMileFragment;

    private ImageView ivBtnBack;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ivBtnBack = findViewById(R.id.iv_btn_back);
        showHomeFragment();

        String[] needPermissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA};
        if (AppUtil.checkAndRequestAppPermission(this, needPermissions, PEMISSION_REQUEST_CODE)) {
            ((AGApplication) getApplication()).initWorkerThread();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode != PEMISSION_REQUEST_CODE)
            return;

        for (int grantResult : grantResults) {
            if (grantResult != PackageManager.PERMISSION_GRANTED)
                finish();
        }

        ((AGApplication) getApplication()).initWorkerThread();
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (showingFragment == lastMileFragment) {
            showLastMileFragment();
//        } else if (showingFragment == previewFragment) {
//            showPreviewFragment();
        } else {
            showHomeFragment();
        }
    }

    @Override
    public void onFragmentEvent(BaseEvent event) {
        if (event instanceof HomeFragment.Event) {
            if (event.getEventType() == HomeFragment.Event.EVENT_TYPE_CLICK_JOIN) {
//                showPreviewFragment();
                showLastMileFragment();
            }
        }
        if (event instanceof PreviewFragment.Event) {
            if (event.getEventType() == PreviewFragment.Event.EVENT_CLICK_NEXT) {
                showLastMileFragment();
            }
        }
        if (event instanceof LastMileFragment.Event) {
            if (event.getEventType() == LastMileFragment.Event.EVENT_CLICK_OK) {
                startActivity(new Intent(this, MiniClassActivity.class));
                showingFragment = null;
//                lastMileFragment = null;
            }
        }
    }

    public void onClickBack(View view) {
        onBackPressed();
    }

    private void showHomeFragment() {
        if (homeFragment == null)
            homeFragment = HomeFragment.newInstance();

        ivBtnBack.setVisibility(View.GONE);
        showFragment(homeFragment);

        chatManager().logout();
    }

    private void showPreviewFragment() {
        if (previewFragment == null)
            previewFragment = PreviewFragment.newInstance();

        ivBtnBack.setVisibility(View.VISIBLE);
        showFragment(previewFragment);
    }

    private void showLastMileFragment() {
        if (lastMileFragment == null)
            lastMileFragment = LastMileFragment.newInstance();

        ivBtnBack.setVisibility(View.VISIBLE);
        showFragment(lastMileFragment);
    }

    private void showFragment(Fragment fragment) {
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_main, fragment).commit();
        showingFragment = fragment;
    }

    @Override
    public void onBackPressed() {
        if (showingFragment == lastMileFragment) {
//            showPreviewFragment();
//        } else if (showingFragment == previewFragment) {
            showHomeFragment();
        } else {
            finish();
        }
    }
}
