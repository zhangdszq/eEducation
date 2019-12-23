package io.agora.rtc.education.room.replay;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.room.fragment.WhiteboardFragment;

public class ReplayActivity extends BaseActivity implements BaseFragment.FragmentStateListener {

    private WhiteboardFragment mWhiteboardFragment;

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_replay);
        mWhiteboardFragment = WhiteboardFragment.newInstance(false);
        mWhiteboardFragment.setFragmentStateListener(this);
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.layout_whiteboard, mWhiteboardFragment)
                .commit();
    }

    @Override
    public void onCreatedView(Fragment fragment) {
        if (fragment == mWhiteboardFragment) {
            Intent intent = getIntent();
            String uuid = intent.getStringExtra(IntentKey.WHITE_BOARD_UID);
            long startTime = intent.getLongExtra(IntentKey.WHITE_BOARD_START_TIME, 0);
            long endTime = intent.getLongExtra(IntentKey.WHITE_BOARD_END_TIME, 0);
            mWhiteboardFragment.replay(uuid, startTime, endTime);
        }
    }

    @Override
    protected void onDestroy() {
        mWhiteboardFragment.finishReplayPage();
        super.onDestroy();
    }

}
