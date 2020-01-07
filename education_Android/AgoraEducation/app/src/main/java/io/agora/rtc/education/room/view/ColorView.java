package io.agora.rtc.education.room.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Checkable;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;

import io.agora.rtc.education.R;

public class ColorView extends View implements Checkable {

    public ColorView(Context context) {
        super(context);
        init(context);
    }

    public ColorView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public ColorView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private Paint mStrokePaint, mFillPaint, mStrokeWhiteFillPaint;
    private float fillPadding;
    private float stokeWidth;
    private boolean isNeedWhiteStroke;

    public void setFillColor(int fillColor) {
        mStrokePaint.setAntiAlias(true);
        mFillPaint.setColor(fillColor);
        if (fillColor == ContextCompat.getColor(getContext(), R.color.white)) {
            isNeedWhiteStroke = true;
        }
        invalidate();
    }

    private void init(Context context) {
        mStrokePaint = new Paint();
        mStrokePaint.setStyle(Paint.Style.STROKE);
        stokeWidth = context.getResources().getDimension(R.dimen.dp_1);
        mStrokePaint.setStrokeWidth(stokeWidth);
        mStrokePaint.setAntiAlias(true);
        mStrokePaint.setColor(ContextCompat.getColor(context, R.color.colorAccent));

        mStrokeWhiteFillPaint = new Paint();
        mStrokeWhiteFillPaint.setStyle(Paint.Style.STROKE);
        mStrokeWhiteFillPaint.setStrokeWidth(stokeWidth);
        mStrokeWhiteFillPaint.setAntiAlias(true);
        mStrokeWhiteFillPaint.setColor(ContextCompat.getColor(context, R.color.gray_EEEEEE));

        mFillPaint = new Paint();
        mFillPaint.setStyle(Paint.Style.FILL);
        mFillPaint.setAntiAlias(true);
        mFillPaint.setColor(ContextCompat.getColor(context, R.color.transparent));

        fillPadding = context.getResources().getDimension(R.dimen.dp_3);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        int x = getWidth() / 2;
        int y = getHeight() / 2;
        int radius = Math.min(x, y);
        if (isChecked) {
            canvas.drawCircle(x, y, radius - stokeWidth, mStrokePaint);
        }
        if (isNeedWhiteStroke) {
            canvas.drawCircle(x, y, radius - fillPadding - stokeWidth, mFillPaint);
            canvas.drawCircle(x, y, radius - fillPadding, mStrokeWhiteFillPaint);
        } else {
            canvas.drawCircle(x, y, radius - fillPadding, mFillPaint);
        }
    }

    private boolean isChecked;

    @Override
    public void setChecked(boolean checked) {
        if (isChecked != checked) {
            isChecked = checked;
            invalidate();
        }
    }

    @Override
    public boolean isChecked() {
        return isChecked;
    }

    @Override
    public void toggle() {
        isChecked = !isChecked;
        invalidate();
    }

}
