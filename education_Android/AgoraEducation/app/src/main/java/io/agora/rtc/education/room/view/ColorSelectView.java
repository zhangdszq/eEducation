package io.agora.rtc.education.room.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;

import io.agora.rtc.education.R;

public class ColorSelectView extends CardView {

    public ColorSelectView(@NonNull Context context) {
        super(context);
        init(context);
    }

    public ColorSelectView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public ColorSelectView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private final int[] colors = new int[12];
    private ArrayList<ColorView> colorViews = new ArrayList<>();
    private int selectIndex = -1;

    private OnClickListener onClickListener = v -> {
        int index = (int) v.getTag();
        select(index);
    };

    private void init(Context context) {
        View.inflate(context, R.layout.view_select_color, this);
        colors[0] = ContextCompat.getColor(context, R.color.red_FF0D19);
        colors[1] = ContextCompat.getColor(context, R.color.yellow_FF8F00);
        colors[2] = ContextCompat.getColor(context, R.color.yellow_FFCA00);
        colors[3] = ContextCompat.getColor(context, R.color.green_00DD52);
        colors[4] = ContextCompat.getColor(context, R.color.blue_007CFF);
        colors[5] = ContextCompat.getColor(context, R.color.purple_C455DF);
        colors[6] = ContextCompat.getColor(context, R.color.white);
        colors[7] = ContextCompat.getColor(context, R.color.gray_EEEEEE);
        colors[8] = ContextCompat.getColor(context, R.color.gray_CCCCCC);
        colors[9] = ContextCompat.getColor(context, R.color.gray_666666);
        colors[10] = ContextCompat.getColor(context, R.color.gray_333333);
        colors[11] = ContextCompat.getColor(context, R.color.black);

        LinearLayout llColors1 = findViewById(R.id.ll_colors_1);
        LinearLayout llColors2 = findViewById(R.id.ll_colors_2);

        for (int i = 0; i < colors.length; i++) {
            ColorView colorView = new ColorView(context);
            colorView.setTag(i);
            colorView.setFillColor(colors[i]);
            colorView.setOnClickListener(onClickListener);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT);
            lp.weight = 1;
            if (i < 6) {
                llColors1.addView(colorView, lp);
            } else {
                llColors2.addView(colorView, lp);
            }

            colorViews.add(colorView);
        }

        select(0);
    }

    private void select(int index) {
        if (selectIndex != index) {
            if (selectIndex >= 0) {
                colorViews.get(selectIndex).setChecked(false);
            }
            colorViews.get(index).setChecked(true);
            selectIndex = index;
            if (changedListener != null) {
                changedListener.onColorChanged(getSelectColor());
            }
        }
    }

    private ColorChangedListener changedListener;

    public void setChangedListener(ColorChangedListener changedListener) {
        this.changedListener = changedListener;
        if (selectIndex >= 0) {
            if (changedListener != null) {
                changedListener.onColorChanged(getSelectColor());
            }
        }
    }

    public interface ColorChangedListener {
        void onColorChanged(int color);
    }

    public int getSelectColor() {
        return colors[selectIndex];
    }

}
