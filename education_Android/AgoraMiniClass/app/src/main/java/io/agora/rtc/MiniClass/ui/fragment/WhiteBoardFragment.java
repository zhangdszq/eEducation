package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Looper;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
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
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.BroadcastState;
import com.herewhite.sdk.domain.DeviceType;
import com.herewhite.sdk.domain.EventEntry;
import com.herewhite.sdk.domain.EventListener;
import com.herewhite.sdk.domain.ImageInformationWithUrl;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Point;
import com.herewhite.sdk.domain.PptPage;
import com.herewhite.sdk.domain.Promise;
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
import io.agora.rtc.MiniClass.model.event.UpdateMembersEvent;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.MiniClass.model.util.ToastUtil;
import io.agora.rtc.MiniClass.model.whiteboard.DemoAPI;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
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
    DemoAPI demoAPI = new DemoAPI();

    private ImageView /*mIvBtnHandUp,*/ mIvBtnText, mIvBtnEraser, mIvBtnOvalVertical, /*mIvBtnLineVertical,*/
            mIvBtnSquareVertical, /*mIvBtnSquareCollection,*/
            mIvBtnMoveCollection, mIvBtnPencil, mIvBtnExit,
            mIvBtnMinOrMax, /*mIvBtnSquareHorizontal,*/ /*mIvBtnLineHorizontal,*/
    /*mIvBtnOvalHorizontal,*/ mIvBtnMoveHorizontal, mIvBtnDelete;
    private LinearLayout /*mLlSquareHorizontal,*/ mLlMoveHorizontal;
    private View mSpaceOvalVerticalTop, mSpaceLineVerticalTop;

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
        return root;
    }

    private void initButtons(View root) {
//        mIvBtnHandUp = root.findViewById(R.id.iv_btn_hand_up);
        mIvBtnText = root.findViewById(R.id.iv_btn_text);
        mIvBtnEraser = root.findViewById(R.id.iv_btn_eraser);
        mIvBtnOvalVertical = root.findViewById(R.id.iv_btn_oval_vertical);
//        mIvBtnLineVertical = root.findViewById(R.id.iv_btn_line_vertical);
        mIvBtnSquareVertical = root.findViewById(R.id.iv_btn_square_vertical);
//        mIvBtnSquareCollection = root.findViewById(R.id.iv_btn_square_collection);
        mIvBtnMoveCollection = root.findViewById(R.id.iv_btn_move_collection);
        mIvBtnPencil = root.findViewById(R.id.iv_btn_pencil);
        mIvBtnExit = root.findViewById(R.id.iv_btn_exit);
        mIvBtnMinOrMax = root.findViewById(R.id.iv_btn_min_or_max);
//        mIvBtnSquareHorizontal = root.findViewById(R.id.iv_btn_square_horizontal);
//        mIvBtnLineHorizontal = root.findViewById(R.id.iv_btn_line_horizontal);
//        mIvBtnOvalHorizontal = root.findViewById(R.id.iv_btn_oval_horizontal);
        mIvBtnMoveHorizontal = root.findViewById(R.id.iv_btn_move_horizontal);
        mIvBtnDelete = root.findViewById(R.id.iv_btn_delete);

//        mLlSquareHorizontal = root.findViewById(R.id.ll_square_horizontal);
        mLlMoveHorizontal = root.findViewById(R.id.ll_move_horizontal);

        mSpaceOvalVerticalTop = root.findViewById(R.id.view_space_oval_vertical_top);
        mSpaceLineVerticalTop = root.findViewById(R.id.view_space_line_vertical_top);

//        mIvBtnHandUp.setOnClickListener(this);
        mIvBtnText.setOnClickListener(this);
        mIvBtnEraser.setOnClickListener(this);
        mIvBtnOvalVertical.setOnClickListener(this);
//        mIvBtnLineVertical.setOnClickListener(this);
        mIvBtnSquareVertical.setOnClickListener(this);
//        mIvBtnSquareCollection.setOnClickListener(this);
        mIvBtnMoveCollection.setOnClickListener(this);
        mIvBtnPencil.setOnClickListener(this);
        mIvBtnExit.setOnClickListener(this);
        mIvBtnMinOrMax.setOnClickListener(this);
//        mIvBtnSquareHorizontal.setOnClickListener(this);
//        mIvBtnLineHorizontal.setOnClickListener(this);
//        mIvBtnOvalHorizontal.setOnClickListener(this);
        mIvBtnMoveHorizontal.setOnClickListener(this);
        mIvBtnDelete.setOnClickListener(this);
    }

    private void clearSelected() {
//        if (mIvBtnHandUp.isSelected())
//            mIvBtnHandUp.setSelected(false);
        if (mIvBtnText.isSelected())
            mIvBtnText.setSelected(false);
        if (mIvBtnEraser.isSelected())
            mIvBtnEraser.setSelected(false);
        if (mIvBtnOvalVertical.isSelected())
            mIvBtnOvalVertical.setSelected(false);
//        if (mIvBtnLineVertical.isSelected())
//            mIvBtnLineVertical.setSelected(false);
        if (mIvBtnSquareVertical.isSelected())
            mIvBtnSquareVertical.setSelected(false);
//        if (mIvBtnSquareCollection.isSelected())
//            mIvBtnSquareCollection.setSelected(false);
        if (mIvBtnMoveCollection.isSelected())
            mIvBtnMoveCollection.setSelected(false);
        if (mIvBtnPencil.isSelected())
            mIvBtnPencil.setSelected(false);
//        if (mIvBtnSquareHorizontal.isSelected())
//            mIvBtnSquareHorizontal.setSelected(false);
//        if (mIvBtnLineHorizontal.isSelected())
//            mIvBtnLineHorizontal.setSelected(false);
//        if (mIvBtnOvalHorizontal.isSelected())
//            mIvBtnOvalHorizontal.setSelected(false);
        if (mIvBtnMoveHorizontal.isSelected())
            mIvBtnMoveHorizontal.setSelected(false);
        if (mIvBtnDelete.isSelected())
            mIvBtnDelete.setSelected(false);
    }

    private RtmRoomControl.UserAttr teacherAttr;

    @Override
    public void onActivityEvent(BaseEvent event) {
        if (event instanceof Event) {
            String uuid = event.text1;
            if (TextUtils.isEmpty(uuid)) {
                createRoom();
            } else {
                getRoomToken(uuid);
            }
        } else if (event instanceof UpdateMembersEvent) {
            UpdateMembersEvent updateMembersEvent = (UpdateMembersEvent) event;
            RtmRoomControl.UserAttr teacherAttr = updateMembersEvent.getTeacherAttr();
            if (room == null) {
                this.teacherAttr = teacherAttr;
                return;
            } else {
                updateMembersEvent(teacherAttr);
            }
        }
    }

    private void updateMembersEvent(RtmRoomControl.UserAttr teacherAttr) {
        if (teacherAttr != null && UserConfig.getRtmUserId().equals(teacherAttr.streamId)) {
//            mIvBtnHandUp.setImageResource(R.drawable.slt_teacher_hand_up);
            broadcast(null);
        } else {
//            mIvBtnHandUp.setImageResource(R.mipmap.icon_connecting12);
            follow(null);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_btn_hand_up:
                showToast("to do.");
                clearSelected();
//                mIvBtnHandUp.setSelected(true);
                break;
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
            case R.id.iv_btn_oval_horizontal:
            case R.id.iv_btn_oval_vertical:
                clearSelected();
//                mIvBtnOvalHorizontal.setSelected(true);
                mIvBtnOvalVertical.setSelected(true);
//                mIvBtnSquareCollection.setSelected(true);
//                if (mLlSquareHorizontal.getVisibility() != View.GONE)
//                    mLlSquareHorizontal.setVisibility(View.GONE);
                ellipse();
                break;
            case R.id.iv_btn_line_vertical:
            case R.id.iv_btn_line_horizontal:
                clearSelected();
//                mIvBtnLineVertical.setSelected(true);
//                mIvBtnLineHorizontal.setSelected(true);
//                mIvBtnSquareCollection.setSelected(true);
//                if (mLlSquareHorizontal.getVisibility() != View.GONE)
//                    mLlSquareHorizontal.setVisibility(View.GONE);
                showToast("to do.");
                break;
            case R.id.iv_btn_square_vertical:
            case R.id.iv_btn_square_horizontal:
                clearSelected();
//                mIvBtnSquareHorizontal.setSelected(true);
                mIvBtnSquareVertical.setSelected(true);
//                mIvBtnSquareCollection.setSelected(true);
//                if (mLlSquareHorizontal.getVisibility() != View.GONE)
//                    mLlSquareHorizontal.setVisibility(View.GONE);
                rectangle();
                break;
            case R.id.iv_btn_square_collection:
//                if (mLlSquareHorizontal.getVisibility() == View.GONE) {
//                    mLlSquareHorizontal.setVisibility(View.VISIBLE);
//                } else {
//                    mLlSquareHorizontal.setVisibility(View.GONE);
//                }
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
            case R.id.iv_btn_exit:
                if (mListener != null)
                    mListener.onFragmentEvent(new Event(Event.EVENT_TYPE_EXIT));
                break;
            case R.id.iv_btn_min_or_max:
                if (mListener == null)
                    return;
                if (mIvBtnMinOrMax.isSelected()) {
                    mIvBtnMinOrMax.setSelected(false);
                    mListener.onFragmentEvent(new Event(Event.EVENT_TYPE_MIN));
//                    mIvBtnOvalVertical.setVisibility(View.GONE);
//                    mSpaceOvalVerticalTop.setVisibility(View.GONE);
//                    mIvBtnLineVertical.setVisibility(View.GONE);
//                    mSpaceLineVerticalTop.setVisibility(View.GONE);
//                    mIvBtnSquareVertical.setVisibility(View.GONE);
//                    mIvBtnSquareCollection.setVisibility(View.VISIBLE);
                } else {
                    mIvBtnMinOrMax.setSelected(true);
                    mListener.onFragmentEvent(new Event(Event.EVENT_TYPE_MAX));
//                    mIvBtnOvalVertical.setVisibility(View.VISIBLE);
//                    mSpaceOvalVerticalTop.setVisibility(View.VISIBLE);
//                    mIvBtnLineVertical.setVisibility(View.VISIBLE);
//                    mSpaceLineVerticalTop.setVisibility(View.VISIBLE);
//                    mIvBtnSquareVertical.setVisibility(View.VISIBLE);
//                    mIvBtnSquareCollection.setVisibility(View.GONE);
//                    mLlSquareHorizontal.setVisibility(View.GONE);
                }
                break;
        }
    }

    public static class Event extends BaseEvent {
        public static final int EVENT_TYPE_ALERT = 101;
        public static final int EVENT_TYPE_UUID = 102;
        public static final int EVENT_TYPE_EXIT = 103;
        public static final int EVENT_TYPE_MIN = 104;
        public static final int EVENT_TYPE_MAX = 105;

        public String uuid = null;

        public Event(int eventType) {
            super(eventType);
        }
    }

    public void alert(final String title, final String detail) {
        if (mListener != null) {
            final Event event = new Event(Event.EVENT_TYPE_ALERT);
            event.text1 = title;
            event.text2 = detail;
            ((Activity) mListener).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mListener.onFragmentEvent(event);
                }
            });
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
        if (demoAPI == null)
            return;
        demoAPI.createRoom(UserConfig.getRtmChannelName(), 100, new Callback() {
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

    private void getRoomToken(final String uuid) {
        if (demoAPI == null)
            return;
        demoAPI.getRoomToken(uuid, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                alert("获取房间 token 请求失败", e.toString());
            }

            @Override
            public void onResponse(Call call, Response response) {
                try {

                    if (response.code() == 200) {
                        JsonObject room = gson.fromJson(response.body().string(), JsonObject.class);
                        String roomToken = room.getAsJsonObject("msgArgs").get("roomToken").getAsString();
//                        if (whiteBroadView.getEnv() == Environment.dev) {
//                            joinRoom(TEST_UUID, TEST_ROOM_TOKEN);
//                        } else {
                        joinRoom(uuid, roomToken);
//                        }
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

        logRoomInfo("room uuid: " + uuid + "roomToken" + roomToken);

        WhiteSdkConfiguration sdkConfiguration = new WhiteSdkConfiguration(DeviceType.touch, 10, 0.1, true);
        /*显示用户头像*/
        sdkConfiguration.setUserCursor(true);
        /*接受用户头像信息回调，自己实现头像回调。会导致 UserCursor 设置失效。*/
        sdkConfiguration.setCustomCursor(true);

        WhiteSdk whiteSdk = new WhiteSdk(
                whiteBroadView,
                (Context) mListener,
                sdkConfiguration,
                new UrlInterrupter() {
                    @Override
                    public String urlInterrupter(String sourceUrl) {
                        return sourceUrl;
                    }
                });

        log.d("join room");
        whiteSdk.joinRoom(new RoomParams(uuid, roomToken), new AbstractRoomCallbacks() {
            @Override
            public void onPhaseChanged(RoomPhase phase) {
                log.d("onPhaseChanged" + phase.name());
                showToast(phase.name());
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
                logRoomInfo("join in room success");
                room = wRoom;
                addCustomEventListener();

                updateMembersEvent(WhiteBoardFragment.this.teacherAttr);
            }

            @Override
            public void catchEx(SDKError t) {
                log.d("catchEx" + t.getMessage());
                showToast(t.getMessage());
            }
        });
    }

    private void addCustomEventListener() {
        if (room == null)
            return;
        room.addMagixEventListener(EVENT_NAME, new EventListener() {
            @Override
            public void onEvent(EventEntry eventEntry) {
                logRoomInfo("customEvent payload: " + eventEntry.getPayload().toString());
                showToast(gson.toJson(eventEntry.getPayload()));
            }
        });
    }

    public void broadcast(View v) {
        if (room == null)
            return;
        logAction();
        room.setViewMode(ViewMode.Broadcaster);
    }

    public void follow(View v) {
        if (room == null)
            return;
        logAction();
        room.setViewMode(ViewMode.Follower);
    }

    public void getBroadcastState(View v) {
        if (room == null)
            return;
        logAction();
        room.getBroadcastState(new Promise<BroadcastState>() {
            @Override
            public void then(BroadcastState broadcastState) {
                showToast(broadcastState.getMode().toString());
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

    public void readonly(View v) {
        if (room == null)
            return;
        logAction();
        room.disableOperations(true);
    }

    public void disableReadonly() {
        if (room == null)
            return;
        logAction();
        room.disableOperations(false);
    }

    public void pencil() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.PENCIL);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void text() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.TEXT);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void eraser() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.ERASER);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void ellipse() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.ELLIPSE);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void rectangle() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.RECTANGLE);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void selector() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.SELECTOR);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void color() {
        if (room == null)
            return;
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{200, 200, 200});
        memberState.setCurrentApplianceName(Appliance.PENCIL);
        memberState.setStrokeWidth(4);
        memberState.setTextSize(10);
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
