package io.agora.rtc.education.room.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;

import com.herewhite.sdk.AbstractRoomCallbacks;
import com.herewhite.sdk.Room;
import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.BroadcastState;
import com.herewhite.sdk.domain.DeviceType;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.RoomState;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.SceneState;
import com.herewhite.sdk.domain.ViewMode;

import java.util.HashMap;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.room.view.ColorSelectView;
import io.agora.rtc.education.whiteboard.AppliancesTooBar;
import io.agora.rtc.education.whiteboard.SceneHelper;
import io.agora.rtc.lib.util.ToastUtil;


public class WhiteboardFragment extends BaseFragment implements View.OnClickListener {

    private AppliancesTooBar mAppliancesTooBar;
    private WhiteboardView mWhiteboardView;
    private ImageView mIcToolColor;
    private CardView mLayoutHandUp;
    private TextView mTvPage;
    private ColorSelectView mColorSelectView;

    private WhiteSdk mWhiteSdk;
    private Room mRoom;
    private boolean mDidLeave = false;
    private ImageView mIcFirst;
    private SceneHelper mSceneHelper = new SceneHelper();
    private ImageView mIcPrevious;
    private ImageView mIcNext;
    private ImageView mIcEnd;
    private ProgressBar mPbLoading;

    private static final String KEY_IS_SHOW_HAND = "is_show_hand";
    private boolean isShowHand = false;

    public static WhiteboardFragment newInstance(boolean isShowHandLayout) {
        WhiteboardFragment fragment = new WhiteboardFragment();
        Bundle bundle = new Bundle();
        bundle.putBoolean(KEY_IS_SHOW_HAND, isShowHandLayout);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onAttach(@NonNull Context context) {
        super.onAttach(context);
        Bundle bundle = getArguments();
        if (bundle != null) {
            isShowHand = bundle.getBoolean(KEY_IS_SHOW_HAND);
        }
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_white_board, container, false);

        mIcToolColor = root.findViewById(R.id.ic_tool_color);
        mLayoutHandUp = root.findViewById(R.id.layout_hand_up);
        mTvPage = root.findViewById(R.id.tv_page);
        mIcFirst = root.findViewById(R.id.ic_first);
        mIcPrevious = root.findViewById(R.id.ic_previous);
        mIcNext = root.findViewById(R.id.ic_next);
        mIcEnd = root.findViewById(R.id.ic_end);
        mPbLoading = root.findViewById(R.id.pb_loading);

        mIcFirst.setOnClickListener(this);
        mIcPrevious.setOnClickListener(this);
        mIcNext.setOnClickListener(this);
        mIcEnd.setOnClickListener(this);
        mIcToolColor.setOnClickListener(this);

        if (isShowHand) {
            mLayoutHandUp.setVisibility(View.VISIBLE);
        }

        HashMap<String, ImageView> hashMap = new HashMap<>();
        hashMap.put(Appliance.SELECTOR, (ImageView) root.findViewById(R.id.ic_tool_selecter));
        hashMap.put(Appliance.PENCIL, (ImageView) root.findViewById(R.id.ic_tool_pen));
        hashMap.put(Appliance.ERASER, (ImageView) root.findViewById(R.id.ic_tool_eraser));
        hashMap.put(Appliance.TEXT, (ImageView) root.findViewById(R.id.ic_tool_text));
        this.mAppliancesTooBar = new AppliancesTooBar(hashMap);

        mColorSelectView = root.findViewById(R.id.color_select_view);
        mColorSelectView.setChangedListener(new ColorSelectView.ColorChangedListener() {
            @Override
            public void onColorChanged(int color) {
                mIcToolColor.setSelected(false);
                mAppliancesTooBar.setColor(color);
                mColorSelectView.setVisibility(View.GONE);
            }
        });

        mWhiteboardView = root.findViewById(R.id.white_board_view);
        WhiteSdkConfiguration configuration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.1);
        mWhiteSdk = new WhiteSdk(mWhiteboardView, mContext, configuration);

        mSceneHelper.setOnSceneChangeListener(new SceneHelper.OnSceneChangeListener() {
            @Override
            public void onSceneIndexChanged(int index, int totalCount) {
                mTvPage.setText(index + "/" + totalCount);
            }
        });
        return root;
    }

    public void joinRoom(String uuid, String roomToken) {
        RoomParams roomParams = new RoomParams(uuid, roomToken);
        Activity activity = getActivity();
        if (activity == null)
            return;

        mWhiteSdk.joinRoom(roomParams, new AbstractRoomCallbacks() {

            @Override
            public void onPhaseChanged(final RoomPhase phase) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        onRoomPhaseChange(phase);
                    }
                });
            }

            @Override
            public void onRoomStateChanged(RoomState modifyState) {
                MemberState memberState = modifyState.getMemberState();
                BroadcastState broadcastState = modifyState.getBroadcastState();
                final SceneState sceneState = modifyState.getSceneState();

                if (memberState != null) {
                    final String applianceName = memberState.getCurrentApplianceName();
                    final int[] sdkColor = memberState.getStrokeColor();

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mAppliancesTooBar.setState(applianceName, sdkColor);
                        }
                    });
                }
                if (broadcastState != null) {
                    final ViewMode viewMode = broadcastState.getMode();//自己是否为主播
                    final boolean hasBroadcaster = broadcastState.getBroadcasterInformation() != null;// 房间内是否有主播
                }
                if (sceneState != null) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mSceneHelper.setSceneState(sceneState);
                        }
                    });
                }
            }
        }, new Promise<Room>() {

            @Override
            public void then(final Room room) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        setupRoom(room);
                    }
                });
            }

            @Override
            public void catchEx(final SDKError sdkError) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        showToast(sdkError.getMessage());
                    }
                });
            }
        });
    }

    private void setupRoom(Room room) {
        mRoom = room;
        mAppliancesTooBar.setRoom(room);
        mSceneHelper.setRoom(room);

        if (mDidLeave) {
            room.disconnect();
        } else {
            MemberState memberState = room.getMemberState();
            String applianceName = memberState.getCurrentApplianceName();
            int[] sdkColor = memberState.getStrokeColor();
            mAppliancesTooBar.setState(applianceName, sdkColor);
        }
    }

    private void onRoomPhaseChange(RoomPhase phase) {
        if (phase == RoomPhase.connected) {
            showToast("连接成功");
            setButtonsEnable(true);

        } else if (phase == RoomPhase.disconnected) {
            showToast("断开连接");
            setButtonsEnable(false);

        } else if (phase == RoomPhase.reconnecting) {
            showToast("重新建立连接");
            setButtonsEnable(false);
        }
    }

    public void finishRoomPage() {
        mDidLeave = true;
        if (mRoom != null) {
            mRoom.disconnect();
            mRoom = null;
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        finishRoomPage();
    }

    private void showToast(String s) {
        if (!mDidLeave) {
            ToastUtil.showShort(s);
        }
    }

    private void setButtonsEnable(boolean enable) {
        if (!this.mDidLeave) {
            mIcFirst.setEnabled(enable);
            mIcPrevious.setEnabled(enable);
            mIcNext.setEnabled(enable);
            mIcEnd.setEnabled(enable);
            mAppliancesTooBar.setViewsEnable(enable);
            mPbLoading.setVisibility(enable ? View.GONE : View.VISIBLE);
        }
    }

    @Override
    public void onClick(View v) {
        if (v == null)
            return;
        switch (v.getId()) {
            case R.id.ic_first:
                mSceneHelper.goToFirstPage();
                break;
            case R.id.ic_previous:
                mSceneHelper.goToPreviousPage();
                break;
            case R.id.ic_next:
                mSceneHelper.goToNextPage();
                break;
            case R.id.ic_end:
                mSceneHelper.goToEndPage();
                break;
            case R.id.ic_tool_color:
                if (mIcToolColor.isSelected()) {
                    mIcToolColor.setSelected(false);
                    mColorSelectView.setVisibility(View.GONE);
                } else {
                    mIcToolColor.setSelected(true);
                    mColorSelectView.setVisibility(View.VISIBLE);
                }
                break;
        }
    }
}
