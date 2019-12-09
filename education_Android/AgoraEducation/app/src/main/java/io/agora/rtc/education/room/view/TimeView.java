package io.agora.rtc.education.room.view;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import io.agora.rtc.education.R;
import io.agora.rtc.lib.util.TimeUtil;

public class TimeView extends LinearLayout {
    public TimeView(Context context) {
        super(context);
        init(context);
    }

    public TimeView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public TimeView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public TimeView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context);
    }

    private TextView mTvTime;

    private Handler handler;
    private void init(Context c) {
        this.handler = new Handler();
        View.inflate(c, R.layout.view_time, this);
        mTvTime = findViewById(R.id.tv_time);
    }

    private long time = -1;

    private Runnable updateTimeRunnable = new Runnable() {
        @Override
        public void run() {
            if (time >= 0) {
                mTvTime.setText(TimeUtil.stringForTimeHMS(time, "%02d:%02d:%02d"));
                time++;
                handler.postDelayed(updateTimeRunnable, 1000);
            } else {
                mTvTime.setText("00:00:00");
            }
        }
    };

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public boolean isStarted() {
        return time >= 0;
    }

    public void start() {
        if (time < 0) {
            time = 0;
        }
        handler.removeCallbacks(updateTimeRunnable);
        updateTimeRunnable.run();
    }

    public void stop() {
        time = -1;
        handler.removeCallbacks(updateTimeRunnable);
        updateTimeRunnable.run();
    }
}
