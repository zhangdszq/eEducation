package io.agora.rtc.education.room.view;

import android.content.Context;
import android.content.res.Resources;
import android.util.AttributeSet;
import android.util.TypedValue;
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
    }

    public UserVideoItem(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public UserVideoItem(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    private TextView tvName;
    private ImageView icVideo;
    private SpeakerView icAudio;
    private FrameLayout layoutPlaceHolder;
    private FrameLayout layoutVideo;
    private boolean isShowVideoIcon;

    public void init(int resLayout, boolean isShowVideoIcon) {
        this.isShowVideoIcon = isShowVideoIcon;
        View.inflate(getContext(), resLayout, this);
        tvName = findViewById(R.id.tv_name);
        if (isShowVideoIcon) {
            icVideo = findViewById(R.id.ic_video);
            icVideo.setVisibility(VISIBLE);
        }
        icAudio = findViewById(R.id.ic_audio);
        layoutPlaceHolder = findViewById(R.id.layout_place_holder);
        layoutVideo = findViewById(R.id.layout_video);
    }

    public void setVideoView(SurfaceView surfaceView) {
        layoutVideo.removeAllViews();
        if (surfaceView != null) {
            layoutVideo.addView(surfaceView, FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
        }
    }

    public SurfaceView getSurfaceView() {
        if (layoutVideo.getChildCount() > 0) {
            return (SurfaceView) layoutVideo.getChildAt(0);
        }
        return null;
    }

//    public void changToLittleLayout() {
//        Resources res = getContext().getResources();
//        LayoutParams lp = (LayoutParams) info.getLayoutParams();
//        lp.height = res.getDimensionPixelSize(R.dimen.dp_20);
//        info.setLayoutParams(lp);
//
//        LayoutParams lpAudio = (LayoutParams) icAudio.getLayoutParams();
//        int dp19 = res.getDimensionPixelSize(R.dimen.dp_19);
//        lpAudio.width = dp19;
//        lpAudio.height = dp19;
//        icAudio.setLayoutParams(lpAudio);
//
//        tvName.setTextSize(TypedValue.COMPLEX_UNIT_PX, res.getDimensionPixelSize(R.dimen.dp_12));
//    }

    public void showVideo(boolean isShowVideo) {
        if (isShowVideo) {
            layoutVideo.setVisibility(View.VISIBLE);
            layoutPlaceHolder.setVisibility(View.GONE);
        } else {
            layoutVideo.setVisibility(View.GONE);
            layoutPlaceHolder.setVisibility(VISIBLE);
        }
    }

    public void setName(String name) {
        tvName.setText(name);
    }

    public void setIcVideoSelect(boolean isSelect) {
        if (isShowVideoIcon) {
            icVideo.setSelected(isSelect);
        }
    }

    public boolean isIcVideoSelected() {
        if (isShowVideoIcon) {
            return icVideo.isSelected();
        }
        return false;
    }

    public void setIcAudioState(int state) {
        icAudio.setSpeakingState(state);
    }

    public int getIcAudioState() {
        return icAudio.getSpeakingState();
    }

    public void setOnClickAudioListener(OnClickListener listener) {
        icAudio.setOnClickListener(listener);
    }

    public void setOnClickVideoListener(OnClickListener listener) {
        if (isShowVideoIcon) {
            icVideo.setOnClickListener(listener);
        }
    }
}
