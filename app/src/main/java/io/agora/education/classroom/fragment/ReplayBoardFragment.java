package io.agora.education.classroom.fragment;

import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ProgressBar;

import com.google.android.exoplayer2.ui.PlayerView;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.DeviceType;
import com.herewhite.sdk.domain.PlayerConfiguration;

import butterknife.BindView;
import butterknife.OnTouch;
import io.agora.base.Callback;
import io.agora.education.R;
import io.agora.education.base.BaseFragment;
import io.agora.education.classroom.widget.whiteboard.ReplayControlView;
import io.agora.whiteboard.netless.manager.ReplayManager;
import io.agora.whiteboard.netless.service.bean.response.RoomJoin;

public class ReplayBoardFragment extends BaseFragment {

    @BindView(R.id.white_board_view)
    protected WhiteboardView white_board_view;
    @BindView(R.id.replay_control_view)
    protected ReplayControlView replay_control_view;
    @BindView(R.id.pb_loading)
    protected ProgressBar pb_loading;

    private WhiteSdk whiteSdk;
    private ReplayManager replayBoard;

    @Override
    protected int getLayoutResId() {
        return R.layout.fragment_replay_board;
    }

    @Override
    protected void initData() {
        WhiteSdkConfiguration configuration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.1);
        whiteSdk = new WhiteSdk(white_board_view, context, configuration);
        replayBoard = new ReplayManager();
        replayBoard.setListener(replay_control_view);
    }

    @Override
    protected void initView() {

    }

    @OnTouch(R.id.white_board_view)
    boolean onTouch(View view, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_UP) {
            replay_control_view.setVisibility(View.VISIBLE);
        }
        return false;
    }

    public void initReplay(String uuid, String token, long startTime, long endTime) {
        if (TextUtils.isEmpty(uuid)) return;
//        pb_loading.setVisibility(View.VISIBLE);
        replayBoard.roomJoin(uuid, token, new Callback<RoomJoin>() {
            @Override
            public void onSuccess(RoomJoin res) {
                PlayerConfiguration configuration = new PlayerConfiguration(uuid, res.roomToken);
                configuration.setBeginTimestamp(startTime);
                configuration.setDuration(endTime - startTime);
                replayBoard.init(whiteSdk, configuration);
            }

            @Override
            public void onFailure(Throwable throwable) {

            }
        });
    }

    public void setPlayer(PlayerView view, String url) {
        replay_control_view.init(view, url);
    }

    public void releaseReplay() {
        whiteSdk.releasePlayer();
    }

}
