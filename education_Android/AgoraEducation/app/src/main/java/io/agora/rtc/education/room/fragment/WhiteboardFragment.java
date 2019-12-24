package io.agora.rtc.education.room.fragment;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.cardview.widget.CardView;

import com.herewhite.sdk.Player;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.RoomPhase;

import java.util.HashMap;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.room.replay.ReplayControl;
import io.agora.rtc.education.room.view.ColorSelectView;
import io.agora.rtc.education.room.whiteboard.SceneHelper;
import io.agora.rtc.education.room.whiteboard.WhiteboardDelegate;
import io.agora.rtc.lib.util.LogUtil;
import io.agora.rtc.lib.util.ToastUtil;


public class WhiteboardFragment extends BaseFragment implements View.OnClickListener {

    private LogUtil log = new LogUtil("WhiteboardFragment");
    private WhiteboardDelegate mWhiteboardDelegate = new WhiteboardDelegate();
    private WhiteboardView mWhiteboardView;
    private ImageView mIcToolColor;
    private CardView mLayoutHandUp;
    private TextView mTvPage;
    private ColorSelectView mColorSelectView;

    private ImageView mIcFirst;
    private ImageView mIcPrevious;
    private ImageView mIcNext;
    private ImageView mIcEnd;
    private ProgressBar mPbLoading;
    private boolean mDidLeave = false;

    private ReplayControl mControl;

    private static final String KEY_IS_SHOW_HAND = "is_show_hand";
    private boolean isShowHand = false;

    private Handler mHandler = new Handler();

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

    @Override
    protected View initUI(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_white_board, container, false);

        mIcToolColor = view.findViewById(R.id.ic_tool_color);
        mLayoutHandUp = view.findViewById(R.id.layout_hand_up);
        mTvPage = view.findViewById(R.id.tv_page);
        mIcFirst = view.findViewById(R.id.ic_first);
        mIcPrevious = view.findViewById(R.id.ic_previous);
        mIcNext = view.findViewById(R.id.ic_next);
        mIcEnd = view.findViewById(R.id.ic_end);
        mPbLoading = view.findViewById(R.id.pb_loading);
        mControl = view.findViewById(R.id.layout_replay_control);

        mIcFirst.setOnClickListener(this);
        mIcPrevious.setOnClickListener(this);
        mIcNext.setOnClickListener(this);
        mIcEnd.setOnClickListener(this);
        mIcToolColor.setOnClickListener(this);

        if (isShowHand) {
            mLayoutHandUp.setVisibility(View.VISIBLE);
            mLayoutHandUp.setOnClickListener(this);
        }

        HashMap<String, ImageView> appliances = new HashMap<>();
        appliances.put(Appliance.SELECTOR, (ImageView) view.findViewById(R.id.ic_tool_selecter));
        appliances.put(Appliance.PENCIL, (ImageView) view.findViewById(R.id.ic_tool_pen));
        appliances.put(Appliance.ERASER, (ImageView) view.findViewById(R.id.ic_tool_eraser));
        appliances.put(Appliance.TEXT, (ImageView) view.findViewById(R.id.ic_tool_text));
        mWhiteboardDelegate.initApplianceToolBar(appliances);

        mColorSelectView = view.findViewById(R.id.color_select_view);
        mColorSelectView.setChangedListener(new ColorSelectView.ColorChangedListener() {
            @Override
            public void onColorChanged(int color) {
                mIcToolColor.setSelected(false);
                mColorSelectView.setVisibility(View.GONE);
                mWhiteboardDelegate.setApplianceColor(color);
            }
        });

        mWhiteboardView = view.findViewById(R.id.white_board_view);

        mWhiteboardDelegate.initWhiteSdk(mContext, mWhiteboardView);

        mWhiteboardDelegate.setOnSceneChangeListener(new SceneHelper.OnSceneChangeListener() {
            @Override
            public void onSceneIndexChanged(int index, int totalCount) {
                mTvPage.setText(index + "/" + totalCount);
                mWhiteboardDelegate.initCameraToContainer();
            }
        });
        return view;
    }

    private void resetLayoutVisible(boolean isReplay) {
        mViewRoot.findViewById(R.id.layout_tools).setVisibility(!isReplay ? View.VISIBLE : View.GONE);
        mViewRoot.findViewById(R.id.layout_scene_control).setVisibility(!isReplay ? View.VISIBLE : View.GONE);
    }

    public void acceptLink(boolean isAccept) {
        mHandler.removeCallbacks(handUpTimeOutRunnable);
        mLayoutHandUp.setSelected(isAccept);
    }

    public boolean isApplyingOrLinking() {
        return mLayoutHandUp.isSelected();
    }

    public interface JoinRoomCallBack {
        void onSuccess();

        void onFailure(String err);
    }

    private String mUuid;

    public String getUuid() {
        return mUuid;
    }

    public void joinRoom(String uuid, final JoinRoomCallBack callBack) {
        mUuid = uuid;
        mPbLoading.setVisibility(View.VISIBLE);
        resetLayoutVisible(false);

        mWhiteboardDelegate.joinRoom(uuid, new WhiteboardDelegate.OnRoomStateChangedListener() {
            @Override
            public void onSuccess() {
                mWhiteboardDelegate.initCameraToContainer();
                callBack.onSuccess();
            }

            @Override
            public void onFailure(String err) {
                mUuid = null;
                callBack.onFailure(err);
            }

            @Override
            public void onRoomPhaseChange(RoomPhase phase) {
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
        });
    }

    public void replay(String uuid, long startTime, long endTime) {
        mUuid = uuid;
        mPbLoading.setVisibility(View.VISIBLE);
        resetLayoutVisible(true);

        mWhiteboardView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mControl.setVisibility(View.VISIBLE);
                }
                return false;
            }
        });

        mWhiteboardDelegate.replay(uuid, startTime, endTime, mControl, new WhiteboardDelegate.OnPlayerStateChangedListener() {
            @Override
            public void onSuccess(Player player) {
                mPbLoading.setVisibility(View.GONE);
                mControl.setPlayer(player);
            }

            @Override
            public void onFailure(String err) {
                mUuid = null;
            }
        });
    }

    private void showToast(String s) {
        if (!mDidLeave) {
            ToastUtil.showShort(s);
        }
    }

    public void finishRoomPage() {
        mDidLeave = true;
        mWhiteboardDelegate.finishRoomPage();
        mUuid = null;
    }

    public void finishReplayPage() {
        mWhiteboardDelegate.finishPlayerPage();
        mUuid = null;
    }

    private void setButtonsEnable(boolean enable) {
//        if (!this.mDidLeave) {
        mIcFirst.setEnabled(enable);
        mIcPrevious.setEnabled(enable);
        mIcNext.setEnabled(enable);
        mIcEnd.setEnabled(enable);
        mPbLoading.setVisibility(enable ? View.GONE : View.VISIBLE);
        mWhiteboardDelegate.setApplianceBarEnable(enable);
//        }
    }

    private Runnable handUpTimeOutRunnable = new Runnable() {
        @Override
        public void run() {
            mLayoutHandUp.setSelected(false);
//            if (handUpOperateListener != null) {
//                handUpOperateListener.onCancel();
//            }
        }
    };

    public interface HandUpOperateListener {
        void onApply();

        void onCancel();
    }

    private HandUpOperateListener handUpOperateListener;

    public void setHandUpOperateListener(HandUpOperateListener handUpOperateListener) {
        this.handUpOperateListener = handUpOperateListener;
    }

    @Override
    public void onClick(View v) {
        if (v == null)
            return;
        switch (v.getId()) {
            case R.id.ic_first:
                mWhiteboardDelegate.goToFirstPage();
                break;
            case R.id.ic_previous:
                mWhiteboardDelegate.goToPreviousPage();
                break;
            case R.id.ic_next:
                mWhiteboardDelegate.goToNextPage();
                break;
            case R.id.ic_end:
                mWhiteboardDelegate.goToEndPage();
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
            case R.id.layout_hand_up:
                boolean isToSelect = !mLayoutHandUp.isSelected();
                if (isToSelect) {
                    if (handUpOperateListener != null) {
                        handUpOperateListener.onApply();
                    }
                    mHandler.postDelayed(handUpTimeOutRunnable, 6000);
                } else {
                    if (handUpOperateListener != null) {
                        handUpOperateListener.onCancel();
                    }
                    mHandler.removeCallbacks(handUpTimeOutRunnable);
                }
                mLayoutHandUp.setSelected(isToSelect);
                break;
        }
    }
}
