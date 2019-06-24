package io.agora.rtc.MiniClass.ui.activity;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.SimpleEvent;
import io.agora.rtc.MiniClass.model.util.AppUtil;
import io.agora.rtc.MiniClass.ui.fragment.PreviewFragment;
import io.agora.rtc.MiniClass.ui.fragment.HomeFragment;
import io.agora.rtc.MiniClass.ui.fragment.LastMileFragment;

public class MainActivity extends AppCompatActivity implements
        HomeFragment.OnFragmentInteractionListener,
        PreviewFragment.OnFragmentInteractionListener,
        LastMileFragment.OnFragmentInteractionListener {

    private static final int PEMISSION_REQUEST_CODE = 101;

    private FrameLayout mFlMain;
    private Fragment showingFragment;
    private HomeFragment homeFragment;
    private PreviewFragment previewFragment;
    private LastMileFragment lastMileFragment;
    private int roleType = Constant.ROLE_STUDENT;

    private ImageView ivBtnBack;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mFlMain = findViewById(R.id.fl_main);
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
        } else if (showingFragment == previewFragment) {
            showPreviewFragment();
        } else {
            showHomeFragment();
        }
    }

    @Override
    public void onHomeFragmentEvent(BaseEvent event) {
        if (event instanceof SimpleEvent) {
            SimpleEvent simpleEvent = (SimpleEvent) event;
            if (simpleEvent.eventType == HomeFragment.OnFragmentInteractionListener.EVENT_TYPE_CLICK_JOIN) {
                showPreviewFragment();
                roleType = simpleEvent.value;
            }
        }
    }

    @Override
    public void onPreviewFragmentEvent(String eventType) {
        if (TextUtils.equals(eventType, PreviewFragment.OnFragmentInteractionListener.EVENT_CLICK_NEXT)) {
            showLastMileFragment();
        }
    }

    @Override
    public void onLastMileFragmentEvent(String eventType) {
        if (TextUtils.equals(eventType, LastMileFragment.OnFragmentInteractionListener.EVENT_CLICK_OK)) {
            startActivity(new Intent(this, MiniClassActivity.class));
            showingFragment = null;
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
            showPreviewFragment();
        } else if (showingFragment == previewFragment) {
            showHomeFragment();
        } else {
            finish();
        }
    }
}
