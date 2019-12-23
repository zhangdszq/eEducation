package io.agora.rtc.education.room.replay;

import android.content.Context;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.herewhite.sdk.Player;
import com.herewhite.sdk.PlayerEventListener;
import com.herewhite.sdk.domain.PlayerPhase;
import com.herewhite.sdk.domain.PlayerState;
import com.herewhite.sdk.domain.SDKError;

import io.agora.rtc.education.R;
import io.agora.rtc.lib.util.TimeUtil;

public class ReplayControl extends RelativeLayout implements View.OnClickListener, PlayerEventListener {

    private ImageView btnPlay;
    private ImageView btnPlayPause;
    private SeekBar sbTime;
    private TextView tvCurrentTime, tvTotalTime;

    private Player mPlayer;
    private Handler mHandler;

    public ReplayControl(@NonNull Context context) {
        this(context, null);
    }

    public ReplayControl(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ReplayControl(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
        mHandler = new Handler();
    }

    private void init(Context context) {
        LayoutInflater.from(context).inflate(R.layout.layout_replay_control, this);
        btnPlay = findViewById(R.id.btn_play);
        btnPlay.setOnClickListener(this);
        btnPlayPause = findViewById(R.id.btn_play_pause);
        btnPlayPause.setOnClickListener(this);
        sbTime = findViewById(R.id.sb_time);
        tvCurrentTime = findViewById(R.id.tv_current_time);
        tvTotalTime = findViewById(R.id.tv_total_time);
    }

    public void setPlayer(Player player) {
        mPlayer = player;
        mPlayer.play();
        tvTotalTime.setText(TimeUtil.stringForTimeHMS(player.getPlayerTimeInfo().getTimeDuration() / 1000, "%02d:%02d:%02d"));
    }

    private void playOrPause() {
        if (mPlayer != null) {
            switch (mPlayer.getPlayerPhase()) {
                case stopped:
                case ended:
                    mPlayer.seekToScheduleTime(0);
                case waitingFirstFrame:
                case pause:
                    mPlayer.play();
                    break;
                case playing:
                    mPlayer.pause();
                    break;
            }
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (mPlayer != null && visibility == VISIBLE) {
            if (mPlayer.getPlayerPhase() == PlayerPhase.playing) {
                mHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        if (mPlayer.getPlayerPhase() == PlayerPhase.playing)
                            setVisibility(GONE);
                    }
                }, 2500);
            }
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_play:
            case R.id.btn_play_pause:
                playOrPause();
                break;
        }
    }

    @Override
    public void onPhaseChanged(final PlayerPhase playerPhase) {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                switch (playerPhase) {
                    case playing:
                        btnPlay.setVisibility(GONE);
                        btnPlayPause.setImageResource(R.drawable.icon_pause);
                        setVisibility(VISIBLE);
                        break;
                    case pause:
                    case ended:
                    case stopped:
                        btnPlay.setVisibility(VISIBLE);
                        btnPlayPause.setImageResource(R.drawable.icon_play);
                        setVisibility(VISIBLE);
                        break;
                }
            }
        });
    }

    @Override
    public void onLoadFirstFrame() {
        mPlayer.pause();
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                setVisibility(VISIBLE);
            }
        });
    }

    @Override
    public void onSliceChanged(String s) {
    }

    @Override
    public void onPlayerStateChanged(PlayerState playerState) {
    }

    @Override
    public void onStoppedWithError(SDKError sdkError) {
    }

    @Override
    public void onScheduleTimeChanged(final long l) {
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                if (mPlayer != null) {
                    float percent = (float) l / mPlayer.getPlayerTimeInfo().getTimeDuration();
                    sbTime.setProgress((int) (percent * 100));
                    tvCurrentTime.setText(TimeUtil.stringForTimeHMS(l / 1000, "%02d:%02d:%02d"));
                }
            }
        });
    }

    @Override
    public void onCatchErrorWhenAppendFrame(SDKError sdkError) {
    }

    @Override
    public void onCatchErrorWhenRender(SDKError sdkError) {
    }

}
