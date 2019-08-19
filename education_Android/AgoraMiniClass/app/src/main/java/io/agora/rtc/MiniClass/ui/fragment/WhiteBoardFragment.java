package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Looper;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.herewhite.sdk.AbstractRoomCallbacks;
import com.herewhite.sdk.Logger;
import com.herewhite.sdk.Room;
import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteBroadView;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.domain.AkkoEvent;
import com.herewhite.sdk.domain.AnimationMode;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.BroadcastState;
import com.herewhite.sdk.domain.CameraConfig;
import com.herewhite.sdk.domain.DeviceType;
import com.herewhite.sdk.domain.EventEntry;
import com.herewhite.sdk.domain.EventListener;
import com.herewhite.sdk.domain.ImageInformationWithUrl;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Point;
import com.herewhite.sdk.domain.PptPage;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.RectangleConfig;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.RoomState;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.Scene;
import com.herewhite.sdk.domain.UrlInterrupter;
import com.herewhite.sdk.domain.ViewMode;

import java.io.IOException;
import java.util.HashMap;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.MuteEvent;
import io.agora.rtc.MiniClass.model.event.UpdateMembersEvent;
import io.agora.rtc.MiniClass.model.util.DensityUtil;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.MiniClass.model.util.ToastUtil;
import io.agora.rtc.MiniClass.model.whiteboard.WhiteDemoAPI;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.ui.activity.MiniClassActivity;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;


public class WhiteBoardFragment extends BaseFragment implements View.OnClickListener {
    public static final String PARAM_UUID = "whiteSDKDemo.UUID";
    /*和 iOS 名字一致*/
    final String EVENT_NAME = "WhiteCommandCustomEvent";
    final String SCENE_DIR = "/dir";
    final String ROOM_INFO = "room info";
    final String ROOM_ACTION = "room action";

    LogUtil log = new LogUtil("WhiteBoard");

    WhiteBroadView whiteBroadView;
    Room room;
    Gson gson = new Gson();
    WhiteDemoAPI mWhiteDemoAPI = new WhiteDemoAPI();
    WhiteSdk mWhiteSdk;
    private volatile boolean isJoiningRoom = false;

    private int[] mColor = null;
    private int mStrokeWidth = 4;
    private int mTextWidth = 8;

    private ImageView  mIvBtnText, mIvBtnEraser, mIvBtnOvalVertical,
            mIvBtnSquareVertical, mIvBtnMoveCollection, mIvBtnPencil,
            mIvBtnMinOrMax, mIvBtnMoveHorizontal, mIvBtnDelete, mIvBtnMuteLocalVideo,
            mIvBtnMuteLocalAudio;
    private LinearLayout  mLlMoveHorizontal;

    public static WhiteBoardFragment newInstance(String paramUUID) {
        WhiteBoardFragment fragment = new WhiteBoardFragment();
        Bundle args = new Bundle();
        args.putString(PARAM_UUID, paramUUID);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_white_board, container, false);
        whiteBroadView = root.findViewById(R.id.white);

        initButtons(root);

        initWhiteSdk();

        return root;
    }

    private void initWhiteSdk() {

        if (UserConfig.getRole() == Constant.Role.TEACHER) {
            mColor = new int[]{200, 30, 30};
        } else {
            mColor = new int[]{30, 30, 200};
        }

        WhiteSdkConfiguration sdkConfiguration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.1, true);

        mWhiteSdk = new WhiteSdk(
                whiteBroadView,
                (Context) mListener,
                sdkConfiguration,
                new UrlInterrupter() {
                    @Override
                    public String urlInterrupter(String sourceUrl) {
                        return sourceUrl;
                    }
                });

    }

    private void initButtons(View root) {
        mIvBtnMinOrMax = root.findViewById(R.id.iv_btn_min_or_max);
        mIvBtnMinOrMax.setOnClickListener(this);

        mIvBtnMuteLocalVideo = root.findViewById(R.id.iv_btn_mute_local_video);
        mIvBtnMuteLocalAudio = root.findViewById(R.id.iv_btn_mute_local_audio);

        if (UserConfig.getRole() == Constant.Role.AUDIENCE) {
            mIvBtnMuteLocalVideo.setVisibility(View.GONE);
            mIvBtnMuteLocalAudio.setVisibility(View.GONE);
            root.findViewById(R.id.cl_white).setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View v, MotionEvent event) {
                    return true;
                }
            });
        } else {
            mIvBtnMuteLocalAudio.setOnClickListener(this);
            mIvBtnMuteLocalVideo.setOnClickListener(this);

            mIvBtnText = root.findViewById(R.id.iv_btn_text);
            mIvBtnEraser = root.findViewById(R.id.iv_btn_eraser);
            mIvBtnOvalVertical = root.findViewById(R.id.iv_btn_oval_vertical);
            mIvBtnSquareVertical = root.findViewById(R.id.iv_btn_square_vertical);
            mIvBtnMoveCollection = root.findViewById(R.id.iv_btn_move_collection);
            mIvBtnPencil = root.findViewById(R.id.iv_btn_pencil);
            mIvBtnMoveHorizontal = root.findViewById(R.id.iv_btn_move_horizontal);
            mIvBtnDelete = root.findViewById(R.id.iv_btn_delete);
            mLlMoveHorizontal = root.findViewById(R.id.ll_move_horizontal);

            mIvBtnText.setOnClickListener(this);
            mIvBtnEraser.setOnClickListener(this);
            mIvBtnOvalVertical.setOnClickListener(this);
            mIvBtnSquareVertical.setOnClickListener(this);
            mIvBtnMoveCollection.setOnClickListener(this);
            mIvBtnPencil.setOnClickListener(this);
            mIvBtnMoveHorizontal.setOnClickListener(this);
            mIvBtnDelete.setOnClickListener(this);
        }

    }

    private void clearSelected() {
        if (mIvBtnText.isSelected())
            mIvBtnText.setSelected(false);
        if (mIvBtnEraser.isSelected())
            mIvBtnEraser.setSelected(false);
        if (mIvBtnOvalVertical.isSelected())
            mIvBtnOvalVertical.setSelected(false);
        if (mIvBtnSquareVertical.isSelected())
            mIvBtnSquareVertical.setSelected(false);
        if (mIvBtnMoveCollection.isSelected())
            mIvBtnMoveCollection.setSelected(false);
        if (mIvBtnPencil.isSelected())
            mIvBtnPencil.setSelected(false);
        if (mIvBtnMoveHorizontal.isSelected())
            mIvBtnMoveHorizontal.setSelected(false);
        if (mIvBtnDelete.isSelected())
            mIvBtnDelete.setSelected(false);
    }

    private RtmRoomControl.UserAttr teacherAttr;

    private volatile String mUuid;
    private static final String UUID_NONE = "uuid_none";

    @Override
    public void onActivityMainThreadEvent(BaseEvent event) {
        if (event instanceof Event) {
            if (event.getEventType() == Event.EVENT_TYPE_UPDATE_UUID) {
                String uuid = event.text1;
                log.d("uuid:" + uuid + ", mUUid:" + mUuid);
                if ((TextUtils.isEmpty(uuid) && UUID_NONE.equals(mUuid)) || (uuid != null && uuid.equals(mUuid))) {
                    log.d("return");
                    return;
                }
                if (TextUtils.isEmpty(uuid)) {
                    mUuid = UUID_NONE;
                    createRoom();
                } else {
                    mUuid = uuid;
                    getRoomToken(uuid);
                }
            }
        } else if (event instanceof UpdateMembersEvent) {
            UpdateMembersEvent updateMembersEvent = (UpdateMembersEvent) event;
            this.teacherAttr = updateMembersEvent.getTeacherAttr();
        } else if (event instanceof MuteEvent) {
            MuteEvent muteEvent = (MuteEvent) event;
            RtmRoomControl.UserAttr attr = muteEvent.getUserAttr();
            if (attr != null && UserConfig.getRtmUserId().equals(attr.streamId)) {
                mIvBtnMuteLocalVideo.setSelected(attr.isMuteVideo);
                mIvBtnMuteLocalAudio.setSelected(attr.isMuteAudio);

            }
        }
    }

    private void changeWhiteBoardView() {

        double width = (double) whiteBroadView.getWidth();
        double height = (double) whiteBroadView.getHeight();
        log.i("rectangle:" + width + ", " + height);
        double ratio = 2d;
        if (height != 0) {
            ratio = width / height;
        }
        room.moveCameraToContainer(new RectangleConfig(ratio * 720d, 720d, AnimationMode.Immediately));
    }

    private void updateActionAuthorization(RtmRoomControl.UserAttr teacherAttr) {
        if (room == null || mListener == null)
            return;

        changeWhiteBoardView();

        switch (UserConfig.getRole()) {
            case TEACHER:
                room.disableOperations(false);
                room.setViewMode(ViewMode.Broadcaster);
                break;

            case STUDENT:
                room.disableOperations(false);
                room.setViewMode(ViewMode.Follower);
                break;

            case AUDIENCE:
                room.disableOperations(true);
                room.setViewMode(ViewMode.Follower);
                break;
        }
    }

    @Override
    public void onClick(View v) {

        if (mListener == null)
            return;

        switch (v.getId()) {
            case R.id.iv_btn_text:
                clearSelected();
                mIvBtnText.setSelected(true);
                text();
                break;
            case R.id.iv_btn_eraser:
                clearSelected();
                mIvBtnEraser.setSelected(true);
                eraser();
                break;
            case R.id.iv_btn_oval_vertical:
                clearSelected();
                mIvBtnOvalVertical.setSelected(true);
                ellipse();
                break;
            case R.id.iv_btn_square_vertical:
                clearSelected();
                mIvBtnSquareVertical.setSelected(true);
                rectangle();
                break;
            case R.id.iv_btn_move_collection:
                if (mLlMoveHorizontal.getVisibility() == View.GONE) {
                    mLlMoveHorizontal.setVisibility(View.VISIBLE);
                } else {
                    mLlMoveHorizontal.setVisibility(View.GONE);
                }
                break;
            case R.id.iv_btn_move_horizontal:
                clearSelected();
                mIvBtnMoveHorizontal.setSelected(true);
                mIvBtnMoveCollection.setSelected(true);
                if (mLlMoveHorizontal.getVisibility() != View.GONE)
                    mLlMoveHorizontal.setVisibility(View.GONE);
                selector();
                break;
            case R.id.iv_btn_delete:
                clearSelected();
                mIvBtnDelete.setSelected(true);
                mIvBtnMoveCollection.setSelected(true);
                if (mLlMoveHorizontal.getVisibility() != View.GONE)
                    mLlMoveHorizontal.setVisibility(View.GONE);
                if (room != null)
                    room.cleanScene(true);
                break;
            case R.id.iv_btn_pencil:
                clearSelected();
                mIvBtnPencil.setSelected(true);
                pencil();
                break;
            case R.id.iv_btn_min_or_max:
                if (mIvBtnMinOrMax.isSelected()) {
                    mIvBtnMinOrMax.setSelected(false);
                    mListener.onFragmentEvent(new Event(Event.EVENT_TYPE_MIN));

                } else {
                    mIvBtnMinOrMax.setSelected(true);
                    mListener.onFragmentEvent(new Event(Event.EVENT_TYPE_MAX));
                }
                break;

            case R.id.iv_btn_mute_local_audio:
                Event muteAudioEvent = new Event(Event.EVENT_TYPE_MUTE_LOCAL_AUDIO_BY_UI);
                muteAudioEvent.bool1 = !mIvBtnMuteLocalAudio.isSelected();
                mListener.onFragmentEvent(muteAudioEvent);
                break;

            case R.id.iv_btn_mute_local_video:
                Event muteVideoEvent = new Event(Event.EVENT_TYPE_MUTE_LOCAL_VIDEO_BY_UI);
                muteVideoEvent.bool1 = !mIvBtnMuteLocalVideo.isSelected();
                mListener.onFragmentEvent(muteVideoEvent);
                break;
        }
    }

    public static class Event extends BaseEvent {
        public static final int EVENT_TYPE_ALERT = 101;
        public static final int EVENT_TYPE_UPDATE_UUID = 102;
        public static final int EVENT_TYPE_MIN = 104;
        public static final int EVENT_TYPE_MAX = 105;
        public static final int EVENT_TYPE_NOTIFY_JOIN_STATE = 106;
        public static final int EVENT_TYPE_NOTIFY_CREATED_UUID = 107;

        public static final int EVENT_TYPE_MUTE_LOCAL_AUDIO_BY_UI = 108;
        public static final int EVENT_TYPE_MUTE_LOCAL_VIDEO_BY_UI = 109;

        public Event(int eventType) {
            super(eventType);
        }
    }

    public void alert(final String title, final String detail) {
        if (mListener != null) {
            final Event event = new Event(Event.EVENT_TYPE_ALERT);
            event.text1 = title;
            event.text2 = detail;
            mListener.onFragmentEvent(event);
        }
    }

    void showToast(final String s) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            if (mListener != null) {
                ((Activity) mListener).runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ToastUtil.showShort(s);
                    }
                });
            }
        } else {
            ToastUtil.showShort(s);
        }
    }

    private void createRoom() {
        if (mWhiteDemoAPI == null)
            return;
        mWhiteDemoAPI.createRoom(UserConfig.getRtmChannelName(), 100, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                alert("网络请求错误", e.toString());
            }

            @Override
            public void onResponse(Call call, Response response) {
                try {
                    String resStr = response.body().string();
                    log.d(resStr);
                    if (response.code() == 200) {
                        JsonObject room = gson.fromJson(resStr, JsonObject.class);
                        String uuid = room.getAsJsonObject("msg").getAsJsonObject("hare").get("uuid").getAsString();
                        String roomToken = room.getAsJsonObject("msg").get("roomToken").getAsString();
                        mUuid = uuid;
                        notifyCreatedWhiteUUid(uuid);
                        joinRoom(uuid, roomToken);
                    } else {
                        alert("网络请求错误", response.body().string());
                    }
                } catch (Throwable e) {
                    alert("创建房间失败", e.toString());
                }
            }
        });


    }

    private void notifyCreatedWhiteUUid(String uuid) {
        if (mListener != null) {
            Event event = new Event(Event.EVENT_TYPE_NOTIFY_CREATED_UUID);
            event.text1 = uuid;
            mListener.onFragmentEvent(event);
        }
    }

    private void getRoomToken(final String uuid) {
        if (mWhiteDemoAPI == null || isJoiningRoom)
            return;
        isJoiningRoom = true;
        mWhiteDemoAPI.getRoomToken(uuid, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                alert("获取房间 token 请求失败", e.toString());
                isJoiningRoom = false;
            }

            @Override
            public void onResponse(Call call, Response response) {
                try {
                    String str = response.body().string();
                    log.d(str);
                    if (response.code() == 200) {
                        JsonObject room = gson.fromJson(str, JsonObject.class);
                        String roomToken = room.getAsJsonObject("msg").get("roomToken").getAsString();
                        joinRoom(uuid, roomToken);
                    } else {
                        alert("获取房间 token 失败", response.body().string());
                    }
                } catch (Throwable e) {
                    alert("获取房间 token 失败", e.toString());
                }
            }
        });
    }

    private void joinRoom(String uuid, String roomToken) {

        if (mListener == null)
            return;

        logRoomInfo("room mUuid: " + uuid + "roomToken" + roomToken);

        log.d("join room");
        mWhiteSdk.joinRoom(new RoomParams(uuid, roomToken), new AbstractRoomCallbacks() {
            @Override
            public void onPhaseChanged(RoomPhase phase) {
                log.d("onPhaseChanged" + phase.name());
            }

            @Override
            public void onRoomStateChanged(RoomState modifyState) {
                log.d("onRoomStateChanged");
                logRoomInfo(gson.toJson(modifyState));
            }
        }, new Promise<Room>() {
            @Override
            public void then(Room wRoom) {
                log.d("then");
                logRoomInfo("join in white room success");
                room = wRoom;
                addCustomEventListener();
                if (mIvBtnPencil != null && UserConfig.getRole() != Constant.Role.AUDIENCE) {
                    mIvBtnPencil.callOnClick();
                }
                updateActionAuthorization(WhiteBoardFragment.this.teacherAttr);

                notifyJoinChannelState(MiniClassActivity.JOIN_STATE_JOIN_SUCCESS);
            }

            @Override
            public void catchEx(SDKError t) {
                log.d("catchEx" + t.getMessage());
                showToast(t.getMessage());

                isJoiningRoom = false;
                notifyJoinChannelState(MiniClassActivity.JOIN_STATE_JOIN_FAILED);
            }
        });
    }

    private void notifyJoinChannelState(int joinStateJoinSuccess) {
        if (mListener != null) {
            Event event = new Event(Event.EVENT_TYPE_NOTIFY_JOIN_STATE);
            event.value1 = joinStateJoinSuccess;
            mListener.onFragmentEvent(event);
        }
    }

    private void addCustomEventListener() {
        if (room == null)
            return;
        room.addMagixEventListener(EVENT_NAME, new EventListener() {
            @Override
            public void onEvent(EventEntry eventEntry) {
                logRoomInfo("customEvent payload: " + eventEntry.getPayload().toString());
            }
        });
    }

    public void getBroadcastState(View v) {
        if (room == null)
            return;
        logAction();
        room.getBroadcastState(new Promise<BroadcastState>() {
            @Override
            public void then(BroadcastState broadcastState) {
                logRoomInfo(gson.toJson(broadcastState));
            }

            @Override
            public void catchEx(SDKError t) {

            }
        });
    }

    public void dispatchCustomEvent(View v) {
        if (room == null)
            return;
        logAction();
        HashMap payload = new HashMap<>();
        payload.put("device", "android");

        room.dispatchMagixEvent(new AkkoEvent(EVENT_NAME, payload));
    }

    public void cleanScene(View v) {
        if (room == null)
            return;
        logAction();
        room.cleanScene(true);
    }

    public void insertNewScene(View v) {
        if (room == null)
            return;
        logAction();
        room.putScenes(SCENE_DIR, new Scene[]{new Scene("page1")}, 0);
        room.setScenePath(SCENE_DIR + "/page1");
    }

    public void insertPPT(View v) {
        if (room == null)
            return;
        logAction();
        room.putScenes(SCENE_DIR, new Scene[]{
                new Scene("page2", new PptPage("https://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/alin-rusu-1239275-unsplash_opt.jpg", 600d, 600d))
        }, 0);
        room.setScenePath(SCENE_DIR + "/page2");
    }

    public void insertImage(View v) {
        if (room == null)
            return;
        room.insertImage(new ImageInformationWithUrl(0d, 0d, 100d, 200d, "https://white-pan.oss-cn-shanghai.aliyuncs.com/40/image/mask.jpg"));
    }

    public void getScene(View v) {
        if (room == null)
            return;
        logAction();
        room.getScenes(new Promise<Scene[]>() {
            @Override
            public void then(Scene[] scenes) {
                logRoomInfo(gson.toJson(scenes));
            }

            @Override
            public void catchEx(SDKError t) {

            }
        });
    }

    public void getRoomPhase(View v) {
        if (room == null)
            return;
        logAction();
        room.getRoomPhase(new Promise<RoomPhase>() {
            @Override
            public void then(RoomPhase roomPhase) {
                logRoomInfo("RoomPhase: " + gson.toJson(roomPhase));

            }

            @Override
            public void catchEx(SDKError t) {

            }
        });
    }

    public void getRoomState(View v) {
        if (room == null)
            return;
        logAction();
        //获取房间状态，包含很多信息
        room.getRoomState(new Promise<RoomState>() {
            @Override
            public void then(RoomState roomState) {
                logRoomInfo("roomState: " + gson.toJson(roomState));
            }

            @Override
            public void catchEx(SDKError t) {

            }
        });
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        disconnect(null);
        mWhiteSdk = null;
    }

    public void disconnect(View v) {

        if (room == null)
            return;

        //如果需要房间断开连接后回调
        room.disconnect(new Promise<Object>() {
            @Override
            public void then(Object o) {
                logAction("disconnect success");
            }

            @Override
            public void catchEx(SDKError t) {

            }
        });

        //如果不需要，则直接断开连接即可
        //room.disconnect();
    }

    public void pencil() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.PENCIL);
        memberState.setStrokeWidth(mStrokeWidth);
        room.setMemberState(memberState);
    }

    public void text() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.TEXT);
        memberState.setTextSize(mTextWidth);
        room.setMemberState(memberState);
    }

    public void eraser() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.ERASER);
        memberState.setStrokeWidth(mStrokeWidth);
        room.setMemberState(memberState);
    }

    public void ellipse() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.ELLIPSE);
        memberState.setStrokeWidth(mStrokeWidth);
        room.setMemberState(memberState);
    }

    public void rectangle() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.RECTANGLE);
        memberState.setStrokeWidth(mStrokeWidth);
        room.setMemberState(memberState);
    }

    public void selector() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.SELECTOR);
        memberState.setStrokeWidth(mStrokeWidth);
        room.setMemberState(memberState);
    }

    public void color() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(mColor);
        memberState.setCurrentApplianceName(Appliance.PENCIL);
        memberState.setStrokeWidth(mStrokeWidth);
        room.setMemberState(memberState);
    }

    public void convertPoint() {
        if (room == null)
            return;
        //获取特定点，在白板内部的坐标点
        room.convertToPointInWorld(0, 0, new Promise<Point>() {
            @Override
            public void then(Point point) {
                logRoomInfo(gson.toJson(point));
            }

            @Override
            public void catchEx(SDKError t) {
                Logger.error("convertToPointInWorld  error", t);
                log.e("convertToPointInWorld  error");
            }
        });
    }

    public void externalEvent(View v) {
        if (room == null)
            return;
        logAction();
        room.disableOperations(true);
//        room.externalDeviceEventDown(new RoomMouseEvent(100, 300));
//        room.externalDeviceEventMove(new RoomMouseEvent(100, 400));
//        room.externalDeviceEventMove(new RoomMouseEvent(100, 500));
//        room.externalDeviceEventMove(new RoomMouseEvent(100, 600));
//        room.externalDeviceEventMove(new RoomMouseEvent(100, 700));
//        room.externalDeviceEventUp(new RoomMouseEvent(100, 700));
        room.disableOperations(false);
    }

    public void zoomChange(View v) {
        if (room == null)
            return;
        room.getZoomScale(new Promise<Number>() {
            @Override
            public void then(Number number) {
                if (number.intValue() != 1) {
                    room.zoomChange(1);
                } else {
                    room.zoomChange(5);
                }
            }

            @Override
            public void catchEx(SDKError t) {

            }
        });
    }

    void logRoomInfo(String str) {
        log.i(ROOM_INFO + Thread.currentThread().getStackTrace()[3].getMethodName() + " " + str);
    }

    void logAction(String str) {
        log.i(ROOM_ACTION + Thread.currentThread().getStackTrace()[3].getMethodName() + " " + str);
    }

    void logAction() {
        log.i(ROOM_ACTION + Thread.currentThread().getStackTrace()[3].getMethodName());
    }

}
