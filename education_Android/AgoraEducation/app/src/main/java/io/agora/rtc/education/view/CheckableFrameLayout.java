package io.agora.rtc.education.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Checkable;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class CheckableFrameLayout extends FrameLayout implements Checkable {
    public CheckableFrameLayout(@NonNull Context context) {
        super(context);
    }

    public CheckableFrameLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public CheckableFrameLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    private boolean isChecked;

    @Override
    public void setChecked(boolean checked) {
        isChecked = checked;
        setSelected(checked);
        int childCount = getChildCount();
        if (childCount > 0) {
            for (int i = 0; i < childCount; i++) {
                View v = getChildAt(i);
                if (v != null)
                    v.setSelected(checked);
            }
        }
    }

    @Override
    public boolean isChecked() {
        return isChecked;
    }

    @Override
    public void toggle() {
        setChecked(!isChecked);
    }
}
