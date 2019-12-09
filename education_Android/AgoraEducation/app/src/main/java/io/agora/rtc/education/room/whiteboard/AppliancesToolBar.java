package io.agora.rtc.education.room.whiteboard;

import android.graphics.PorterDuff;
import android.view.View;
import android.widget.ImageView;

import com.herewhite.sdk.Room;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.MemberState;

import java.util.Map;

public class AppliancesToolBar {

    private final Map<String, ImageView> mAppliances;
    private String mCurrentApplianceName;
    private Room mRoom = null;
    private int mStrokeWidth = 4;
    private int mTextWidth = 8;
    private int[] mColor = {0,0,0};

    public AppliancesToolBar(Map<String, ImageView> appliances) {
        mCurrentApplianceName = Appliance.ERASER;
        mAppliances = appliances;

        for (Map.Entry<String, ImageView> e: mAppliances.entrySet()) {
            final String applianceName = e.getKey();
            View v = e.getValue();
            v.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    onClickApplianceView(applianceName);
                }
            });
        }
        setViewsEnable(false);
    }

    public void setState(String applianceName, int[] color) {
        if (mCurrentApplianceName != null) {
            ImageView originalView = mAppliances.get(mCurrentApplianceName);
            if (originalView != null) {
                originalView.clearColorFilter();
            }
        }

        mCurrentApplianceName = applianceName;
        mColor = color;
        ImageView currentView = mAppliances.get(mCurrentApplianceName);
        if (currentView != null) {
            currentView.setColorFilter(getColorInt(color));
        }
    }

    public static int[] getColorArrayRGB(int color) {
        int[] colorArray = new int[3];
        colorArray[0] = color >> 16 & 0xFF;
        colorArray[1] = color >> 8 & 0xFF;
        colorArray[2] = color & 0xFF;
        return colorArray;
    }

    public static int getColorInt(int[] colorArray) {
        return  0xff << 24 | (colorArray[0] & 0xff) << 16 | (colorArray[1] & 0xff) << 8 | (colorArray[2] & 0xff);
    }

    public void setColor(int color) {
        mColor = getColorArrayRGB(color);
        if (mRoom != null) {
            MemberState memberState = mRoom.getMemberState();
            memberState.setStrokeColor(mColor);
            mRoom.setMemberState(memberState);
        }
        ImageView v = mAppliances.get(mCurrentApplianceName);
        if (v != null) {
            v.setColorFilter(color);
        }
    }

    public void setColor(int[] color) {
        mColor = color;
        if (mRoom != null) {
            MemberState memberState = mRoom.getMemberState();
            memberState.setStrokeColor(mColor);
            mRoom.setMemberState(memberState);
        }
        ImageView v = mAppliances.get(mCurrentApplianceName);
        if (v != null) {
            v.setColorFilter(getColorInt(color));
        }
    }

    public void setRoom(Room room) {
        mRoom = room;
        setViewsEnable(true);
    }

    public void setViewsEnable(boolean enable) {
        if (mAppliances != null) {
            for (View View: mAppliances.values()) {
                View.setEnabled(enable);
            }
        }
    }

    private void onClickApplianceView(String applianceName) {
        if (mRoom != null) {
            MemberState memberState = new MemberState();
            memberState.setCurrentApplianceName(applianceName);
            memberState.setStrokeColor(mColor);
            memberState.setStrokeWidth(mStrokeWidth);
            memberState.setTextSize(mTextWidth);
            mRoom.setMemberState(memberState);
        }
    }
}
