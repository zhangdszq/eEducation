package io.agora.rtc.education.room.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.constraintlayout.widget.ConstraintLayout;

import io.agora.rtc.education.R;

public class UserVideoItem extends ConstraintLayout {
    public UserVideoItem(Context context) {
        super(context);
        init(context);
    }

    public UserVideoItem(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public UserVideoItem(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private TextView tvName;
    private ImageView icVideo;
    private SpeakerView icAudio;
    private FrameLayout layoutPlaceHolder;
    private FrameLayout layoutVideo;
    private void init(Context c) {
        View.inflate(c, R.layout.item_user_video, this);
        tvName = findViewById(R.id.tv_name);
        icVideo = findViewById(R.id.ic_video);
        icAudio = findViewById(R.id.ic_audio);
        layoutPlaceHolder = findViewById(R.id.layout_place_holder);
        layoutVideo = findViewById(R.id.layout_video);

    }

    public void setVideoView(SurfaceView surfaceView) {
        layoutVideo.removeAllViews();
        layoutVideo.addView(surfaceView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
    }

    public SurfaceView getSurfaceView() {
        if (layoutVideo.getChildCount()>0) {
            return (SurfaceView) layoutVideo.getChildAt(0);
        }
        return null;
    }

    public void showVideo(boolean isShowVideo) {
        if (isShowVideo) {
            layoutVideo.setVisibility(View.VISIBLE);
            layoutPlaceHolder.setVisibility(View.GONE);
        } else {
            layoutVideo.setVisibility(View.GONE);
            layoutPlaceHolder.setVisibility(VISIBLE);
        }
    }

    public void setIcVideoSelect(boolean isSelect) {
        icVideo.setSelected(true);
    }

    public void showVideoIcon(boolean isShow) {
        icVideo.setVisibility(isShow ? VISIBLE : GONE);
    }

    public void setIcAudioState(int state) {
        icAudio.setSpeakingState(state);
    }

    public void setOnClickAudioListener(OnClickListener listener) {
        icAudio.setOnClickListener(listener);
    }

    public void setOnClickVideoListener(OnClickListener listener) {
        icVideo.setOnClickListener(listener);
    }
}
