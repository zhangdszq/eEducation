package io.agora.education.classroom.widget.whiteboard;

import android.content.Context;
import android.net.Uri;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;
import android.webkit.URLUtil;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.exoplayer2.ExoPlaybackException;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.Timeline;
import com.google.android.exoplayer2.source.ExtractorMediaSource;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.source.hls.HlsMediaSource;
import com.google.android.exoplayer2.trackselection.AdaptiveTrackSelection;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelection;
import com.google.android.exoplayer2.trackselection.TrackSelectionArray;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.BandwidthMeter;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;
import com.herewhite.sdk.combinePlayer.NativePlayer;
import com.herewhite.sdk.combinePlayer.PlayerSyncManager;
import com.herewhite.sdk.domain.PlayerPhase;

import java.util.concurrent.TimeUnit;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.util.TimeUtil;
import io.agora.whiteboard.netless.manager.ReplayManager;
import io.agora.whiteboard.netless.listener.ReplayEventListener;

public class ReplayControlView extends RelativeLayout implements View.OnClickListener, ReplayEventListener, NativePlayer, PlayerSyncManager.Callbacks, com.google.android.exoplayer2.Player.EventListener, SeekBar.OnSeekBarChangeListener {

    @BindView(R.id.btn_play)
    protected ImageView btn_play;
    @BindView(R.id.btn_play_pause)
    protected ImageView btn_play_pause;
    @BindView(R.id.sb_time)
    protected SeekBar sb_time;
    @BindView(R.id.tv_current_time)
    protected TextView tv_current_time;
    @BindView(R.id.tv_total_time)
    protected TextView tv_total_time;

    private Context mContext;
    private ReplayManager mPlayer;
    private PlayerSyncManager mManager;
    private NativePlayerPhase mPhase = NativePlayerPhase.Idle;
    private PlayerView mVideoView;
    private ExoPlayer mVideoPlayer;
    private Handler mHandler;

    public ReplayControlView(@NonNull Context context) {
        this(context, null);
    }

    public ReplayControlView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ReplayControlView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        mHandler = new Handler();
        inflate(context, R.layout.layout_replay_control, this);
        ButterKnife.bind(this);
        sb_time.setOnSeekBarChangeListener(this);
    }

    public void init(PlayerView videoView, String url) {
        mVideoView = videoView;
        mVideoView.setUseController(false);
        initManager(url);
    }

    public void release() {
        if (mVideoPlayer != null) {
            mVideoPlayer.removeListener(this);
            mVideoPlayer.release();
            mVideoPlayer = null;
        }
    }

    private void initVideoPlayer() {
        BandwidthMeter bandwidthMeter = new DefaultBandwidthMeter();
        TrackSelection.Factory videoTrackSelectionFactory = new AdaptiveTrackSelection.Factory(bandwidthMeter);
        TrackSelector trackSelector = new DefaultTrackSelector(videoTrackSelectionFactory);
        mVideoPlayer = ExoPlayerFactory.newSimpleInstance(mContext, trackSelector);
        mVideoPlayer.addListener(this);
        mVideoView.setPlayer(mVideoPlayer);
    }

    private void initVideoSource(String url) {
        DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(mContext, Util.getUserAgent(mContext, mContext.getPackageName()));
        Uri uri = Uri.parse(url);
        MediaSource source;
        if (url.endsWith(".m3u8")) {
            source = new HlsMediaSource.Factory(dataSourceFactory).createMediaSource(uri);
        } else {
            source = new ExtractorMediaSource.Factory(dataSourceFactory).createMediaSource(uri);
        }
        mVideoPlayer.setPlayWhenReady(false);
        mVideoPlayer.prepare(source);
    }

    private void initManager(String url) {
        if (URLUtil.isNetworkUrl(url)) {
            initVideoPlayer();
            initVideoSource(url);
        }
    }

    private void playOrPause() {
        if (mPlayer != null) {
            switch (mPlayer.getPlayerPhase()) {
                case stopped:
                case ended:
                    if (mManager != null) {
                        mManager.seek(0, TimeUnit.MILLISECONDS);
                        if (mVideoPlayer != null) {
                            mVideoPlayer.seekTo(0);
                        }
                    } else {
                        mPlayer.seekToScheduleTime(0);
                    }
                case waitingFirstFrame:
                case pause:
                    if (mManager != null) {
                        mManager.play();
                    } else {
                        mPlayer.play();
                    }
                    break;
                case playing:
                    if (mManager != null) {
                        mManager.pause();
                    } else {
                        mPlayer.pause();
                    }
                    break;
            }
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        if (mPlayer != null && visibility == VISIBLE) {
            if (mPlayer.getPlayerPhase() == PlayerPhase.playing) {
                mHandler.postDelayed(() -> {
                    if (mPlayer.getPlayerPhase() == PlayerPhase.playing)
                        setVisibility(GONE);
                }, 2500);
            }
        }
    }

    @OnClick({R.id.btn_play, R.id.btn_play_pause})
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.btn_play:
            case R.id.btn_play_pause:
                playOrPause();
                break;
        }
    }

    @Override
    public void onPlayerPrepared(ReplayManager replayBoard) {
        mPlayer = replayBoard;
        mPlayer.play();
        tv_total_time.setText(TimeUtil.stringForTimeHMS(mPlayer.getPlayerTimeInfo().getTimeDuration() / 1000, "%02d:%02d:%02d"));
        mManager = mPlayer.getSyncManager(this, this);
    }

    @Override
    public void onPhaseChanged(PlayerPhase playerPhase) {
        if (mManager != null) {
            mManager.updateWhitePlayerPhase(playerPhase);
        }
        mHandler.post(() -> {
            switch (playerPhase) {
                case playing:
                    btn_play.setVisibility(GONE);
                    btn_play_pause.setImageResource(R.drawable.ic_pause);
                    setVisibility(VISIBLE);
                    break;
                case pause:
                case ended:
                case stopped:
                    btn_play.setVisibility(VISIBLE);
                    btn_play_pause.setImageResource(R.drawable.ic_play);
                    setVisibility(VISIBLE);
                    break;
            }
        });
    }

    @Override
    public void onLoadFirstFrame() {
        if (mManager != null) {
            mManager.pause();
        } else if (mPlayer != null) {
            mPlayer.pause();
        }
        mHandler.post(() -> setVisibility(VISIBLE));
    }

    @Override
    public void onScheduleTimeChanged(long l) {
        mHandler.post(() -> {
            if (mPlayer != null) {
                float percent = (float) l / mPlayer.getPlayerTimeInfo().getTimeDuration();
                sb_time.setProgress((int) (percent * sb_time.getMax()));
                tv_current_time.setText(TimeUtil.stringForTimeHMS(l / 1000, "%02d:%02d:%02d"));
            }
        });
    }

    @Override
    public void play() {
        if (mVideoPlayer != null) {
            mVideoPlayer.setPlayWhenReady(true);
        }
    }

    @Override
    public void pause() {
        if (mVideoPlayer != null) {
            mVideoPlayer.setPlayWhenReady(false);
        }
    }

    @Override
    public boolean hasEnoughBuffer() {
        if (mVideoPlayer != null) {
            return mVideoPlayer.getPlaybackState() == com.google.android.exoplayer2.Player.STATE_READY;
        }
        return false;
    }

    @Override
    public NativePlayerPhase getPhase() {
        return mPhase;
    }

    @Override
    public void startBuffering() {

    }

    @Override
    public void endBuffering() {

    }

    @Override
    public void onTimelineChanged(Timeline timeline, Object manifest, int reason) {

    }

    @Override
    public void onTracksChanged(TrackGroupArray trackGroups, TrackSelectionArray trackSelections) {

    }

    @Override
    public void onLoadingChanged(boolean isLoading) {
//        if (isLoading) {
//            mManager.play();
//        }
    }

    @Override
    public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
        if (mManager != null) {
            switch (playbackState) {
                case com.google.android.exoplayer2.Player.STATE_IDLE:
                    mPhase = NativePlayerPhase.Idle;
                    break;
                case com.google.android.exoplayer2.Player.STATE_BUFFERING:
                    mPhase = NativePlayerPhase.Buffering;
                    break;
                case com.google.android.exoplayer2.Player.STATE_READY:
                    mPhase = playWhenReady ? NativePlayerPhase.Playing : NativePlayerPhase.Pause;
                    break;
                case com.google.android.exoplayer2.Player.STATE_ENDED:
                    mPhase = NativePlayerPhase.Pause;
                    break;
            }
            mManager.updateNativePhase(mPhase);
        }
    }

    @Override
    public void onRepeatModeChanged(int repeatMode) {

    }

    @Override
    public void onShuffleModeEnabledChanged(boolean shuffleModeEnabled) {

    }

    @Override
    public void onPlayerError(ExoPlaybackException error) {

    }

    @Override
    public void onPositionDiscontinuity(int reason) {

    }

    @Override
    public void onPlaybackParametersChanged(PlaybackParameters playbackParameters) {

    }

    @Override
    public void onSeekProcessed() {

    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        if (fromUser) {
            float percent = (float) progress / seekBar.getMax();
            long position = (long) (mPlayer.getPlayerTimeInfo().getTimeDuration() * percent);
            if (mManager != null) {
                mManager.seek(position, TimeUnit.MILLISECONDS);
            } else if (mPlayer != null) {
                mPlayer.seekToScheduleTime(position);
            }
            if (mVideoPlayer != null) {
                mVideoPlayer.seekTo(position);
            }
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

}
