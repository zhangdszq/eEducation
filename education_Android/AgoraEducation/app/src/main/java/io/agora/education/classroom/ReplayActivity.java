package io.agora.education.classroom;

import android.content.Intent;
import android.text.TextUtils;
import android.view.View;

import com.google.android.exoplayer2.ui.PlayerView;

import butterknife.BindView;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.base.BaseActivity;
import io.agora.education.classroom.fragment.ReplayBoardFragment;

public class ReplayActivity extends BaseActivity {

    public static final String WHITEBOARD_UID = "whiteboardUid";
    public static final String WHITEBOARD_START_TIME = "whiteboardStartTime";
    public static final String WHITEBOARD_END_TIME = "whiteboardEndTime";
    public static final String WHITEBOARD_URL = "whiteboardUrl";

    @BindView(R.id.video_view)
    protected PlayerView video_view;

    private ReplayBoardFragment replayBoardFragment;
    private String url, uuid, token;
    private long startTime, endTime;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_replay;
    }

    @Override
    protected void initData() {
        Intent intent = getIntent();
        url = intent.getStringExtra(WHITEBOARD_URL);
        uuid = intent.getStringExtra(WHITEBOARD_UID);
        token = intent.getStringExtra(BaseClassActivity.WHITEBOARD_SDK_TOKEN);
        startTime = intent.getLongExtra(WHITEBOARD_START_TIME, 0);
        endTime = intent.getLongExtra(WHITEBOARD_END_TIME, 0);
    }

    @Override
    protected void initView() {
        video_view.setVisibility(!TextUtils.isEmpty(url) ? View.VISIBLE : View.GONE);
        findViewById(R.id.iv_temp).setVisibility(TextUtils.isEmpty(url) ? View.VISIBLE : View.GONE);

        replayBoardFragment = new ReplayBoardFragment();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.layout_whiteboard, replayBoardFragment)
                .commitNow();
    }

    @Override
    protected void onResumeFragments() {
        super.onResumeFragments();
        replayBoardFragment.initReplay(uuid, token, startTime, endTime);
        replayBoardFragment.setPlayer(video_view, url);
    }

    @Override
    protected void onDestroy() {
        replayBoardFragment.releaseReplay();
        super.onDestroy();
    }

    @OnClick(R.id.iv_back)
    public void onClick(View view) {
        finish();
    }

}
