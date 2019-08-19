package io.agora.rtc.MiniClass.ui.activity;

import android.content.Intent;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.ui.fragment.BaseFragment;
import io.agora.rtc.MiniClass.ui.fragment.PreviewFragment;
import io.agora.rtc.MiniClass.ui.fragment.HomeFragment;
import io.agora.rtc.MiniClass.ui.fragment.LastMileFragment;

public class MainActivity extends BaseActivity {


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

    }

    @Override
    protected void onResume() {
        super.onResume();
        if (showingFragment == null || showingFragment == homeFragment) {
            showHomeFragment();
        } else {
            showLastMileFragment();
        }
    }

    @Override
    public void onFragmentMainThreadEvent(BaseEvent event) {
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
                previewFragment = null;
                lastMileFragment = null;
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

        rtmManager().logout();
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
