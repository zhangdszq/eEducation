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

    public static final int STATE_CLOSED = 0; //关闭
    public static final int STATE_OPENED = 1; //开启
    public static final int STATE_SPEAKING = 2; //正在说话
    private int speakingState = 0;

    /**
     * @param speakingState STATE_CLOSED, STATE_OPENED, STATE_SPEAKING
     */
    public void setSpeakingState(int speakingState) {
        if (this.speakingState != speakingState) {
            this.speakingState = speakingState;
            if (speakingState == STATE_OPENED) {
                showIndex = 3;
            } else if (speakingState == STATE_CLOSED) {
                showIndex = 0;
            } else if (speakingState == STATE_SPEAKING) {
                showIndex = 0;
            }
            runnable.run();
        }
    }

    public int getSpeakingState() {
        return speakingState;
    }
}
