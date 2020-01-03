package io.agora.rtc.education.widget.eyecare;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import io.agora.rtc.education.R;
import io.agora.rtc.education.constant.SPKey;
import io.agora.rtc.lib.util.SPUtil;

public class EyeCare {

    public static class EyeCareView extends View {
        public EyeCareView(Context context) {
            super(context);
            init(context);
        }

        public EyeCareView(Context context, @Nullable AttributeSet attrs) {
            super(context, attrs);
            init(context);
        }

        public EyeCareView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
            super(context, attrs, defStyleAttr);
            init(context);
        }

        private void init(Context context) {
            setBackgroundColor(context.getResources().getColor(R.color.eye_care_color));
        }
    }

    public static boolean isNeedShow() {
        return SPUtil.get(SPKey.KEY_IS_EYE_CARE, false);
    }

    public static void setNeedShow(boolean isNeed) {
        SPUtil.put(SPKey.KEY_IS_EYE_CARE, isNeed);
    }

}
