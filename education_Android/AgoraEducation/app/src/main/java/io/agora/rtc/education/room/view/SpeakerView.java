package io.agora.rtc.education.room.view;

import android.content.Context;
import android.util.AttributeSet;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

import io.agora.rtc.education.R;

public class SpeakerView extends AppCompatImageView {
    public SpeakerView(Context context) {
        super(context);
        init(context);
    }

    public SpeakerView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public SpeakerView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    Runnable runnable = new Runnable() {
        @Override
        public void run() {
            setImageResource(imgResArray[showIndex]);
            if (speakingState == 2) {
                showIndex++;
                postDelayed(runnable, 500);
            }
        }
    };

    private void init(Context c) {
        runnable.run();
    }

    private int[] imgResArray = {
            R.drawable.icon_speaker_off_s,
            R.drawable.icon_speaker1,
            R.drawable.icon_speaker2,
            R.drawable.icon_speaker3
    };
    private int showIndex = 0;
    private int speakingState = 0;

    /**
     * @param speakingState// 0为开启，1为关闭，2为正在说话
     */
    public void setSpeakingState(int speakingState) {
        if (this.speakingState != speakingState) {
            this.speakingState = speakingState;
            if (speakingState == 0) {
                showIndex = 3;
            } else if (speakingState == 1) {
                showIndex = 0;
            } else if (speakingState == 2) {
                showIndex = 0;
            }
            runnable.run();
        }
    }
}
