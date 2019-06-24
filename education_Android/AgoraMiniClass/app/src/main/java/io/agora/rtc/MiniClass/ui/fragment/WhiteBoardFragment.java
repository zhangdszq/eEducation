package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.herewhite.sdk.AbstractRoomCallbacks;
import com.herewhite.sdk.Environment;
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
import com.herewhite.sdk.domain.RoomMouseEvent;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.RoomState;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.Scene;
import com.herewhite.sdk.domain.UrlInterrupter;
import com.herewhite.sdk.domain.ViewMode;

import java.io.IOException;
import java.util.HashMap;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.whiteboard.DemoAPI;
import io.agora.rtc.MiniClass.model.event.AlertEvent;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.ShowToastEvent;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;

import static io.agora.rtc.MiniClass.model.whiteboard.DemoAPI.TEST_ROOM_TOKEN;
import static io.agora.rtc.MiniClass.model.whiteboard.DemoAPI.TEST_UUID;


public class WhiteBoardFragment extends Fragment {
    public static final String PARAM_UUID = "whiteSDKDemo.UUID";
    /*和 iOS 名字一致*/
    final String EVENT_NAME = "WhiteCommandCustomEvent";

    final String SCENE_DIR = "/dir";
    final String ROOM_INFO = "room info";
    final String ROOM_ACTION = "room action";

    WhiteBroadView whiteBroadView;
    Room room;
    Gson gson = new Gson();
    DemoAPI demoAPI = new DemoAPI();


    private OnFragmentInteractionListener mListener;

    public WhiteBoardFragment() {
    }


    public static WhiteBoardFragment newInstance(String paramUUID) {
        WhiteBoardFragment fragment = new WhiteBoardFragment();
        Bundle args = new Bundle();
        args.putString(PARAM_UUID, paramUUID);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_white_board, container, false);
        whiteBroadView = root.findViewById(R.id.white);

        String uuid = null;
        if (getArguments() != null) {
            uuid = getArguments().getString(PARAM_UUID);
        }
        if (uuid == null) {
            createRoom();
        } else {
            getRoomToken(uuid);
        }
        return root;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {

        void onWhiteBoardFragmentEvent(BaseEvent event);
    }

    public void alert(final String title, final String detail) {
        if (mListener != null)
            mListener.onWhiteBoardFragmentEvent(new AlertEvent(title, detail));
    }

    void showToast(Object o) {
        if (mListener != null)
            mListener.onWhiteBoardFragmentEvent(new ShowToastEvent(o.toString()));
    }

    private void createRoom() {
        demoAPI.createRoom("sdk demo", 100, new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                alert("网络请求错误", e.toString());
            }

            @Override
            public void onResponse(Call call, Response response) {
                try {
                    if (response.code() == 200) {
                        JsonObject room = gson.fromJson(response.body().string(), JsonObject.class);
                        String uuid = room.getAsJsonObject("msg").getAsJsonObject("room").get("uuid").getAsString();
                        String roomToken = room.getAsJsonObject("msg").get("roomToken").getAsString();
                        if (whiteBroadView.getEnv() == Environment.dev) {
                            joinRoom(TEST_UUID, TEST_ROOM_TOKEN);
                        } else {
                            joinRoom(uuid, roomToken);
                        }
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
                        String roomToken = room.getAsJsonObject("msg").get("roomToken").getAsString();
                        if (whiteBroadView.getEnv() == Environment.dev) {
                            joinRoom(TEST_UUID, TEST_ROOM_TOKEN);
                        } else {
                            joinRoom(uuid, roomToken);
                        }
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

        whiteSdk.joinRoom(new RoomParams(uuid, roomToken), new AbstractRoomCallbacks() {
            @Override
            public void onPhaseChanged(RoomPhase phase) {
                showToast(phase.name());
            }

            @Override
            public void onRoomStateChanged(RoomState modifyState) {
                logRoomInfo(gson.toJson(modifyState));
            }
        }, new Promise<Room>() {
            @Override
            public void then(Room wRoom) {
                logRoomInfo("join in room success");
                room = wRoom;
                addCustomEventListener();
            }

            @Override
            public void catchEx(SDKError t) {
                showToast(t.getMessage());
            }
        });
    }

    private void addCustomEventListener() {
        room.addMagixEventListener(EVENT_NAME, new EventListener() {
            @Override
            public void onEvent(EventEntry eventEntry) {
                logRoomInfo("customEvent payload: " + eventEntry.getPayload().toString());
                showToast(gson.toJson(eventEntry.getPayload()));
            }
        });
    }

    public void broadcast(MenuItem item) {
        logAction();
        room.setViewMode(ViewMode.Broadcaster);
    }

    public void getBroadcastState(MenuItem item) {
        logAction();
        room.getBroadcastState(new Promise<BroadcastState>() {
            @Override
            public void then(BroadcastState broadcastState) {
                showToast(broadcastState.getMode());
                logRoomInfo(gson.toJson(broadcastState));
            }

            @Override
            public void catchEx(SDKError t) {

            }
        });
    }

    public void dispatchCustomEvent(MenuItem item) {
        logAction();
        HashMap payload = new HashMap<>();
        payload.put("device", "android");

        room.dispatchMagixEvent(new AkkoEvent(EVENT_NAME, payload));
    }

    public void cleanScene(MenuItem item) {
        logAction();
        room.cleanScene(true);
    }

    public void insertNewScene(MenuItem item) {
        logAction();
        room.putScenes(SCENE_DIR, new Scene[]{
                new Scene("page1")}, 0);
        room.setScenePath(SCENE_DIR + "/page1");
    }

    public void insertPPT(MenuItem item) {
        logAction();
        room.putScenes(SCENE_DIR, new Scene[]{
                new Scene("page2", new PptPage("https://white-pan.oss-cn-shanghai.aliyuncs.com/101/image/alin-rusu-1239275-unsplash_opt.jpg", 600d, 600d))
        }, 0);
        room.setScenePath(SCENE_DIR + "/page2");
    }

    public void insertImage(MenuItem item) {
        room.insertImage(new ImageInformationWithUrl(0d, 0d, 100d, 200d, "https://white-pan.oss-cn-shanghai.aliyuncs.com/40/image/mask.jpg"));
    }

    public void getScene(MenuItem item) {
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

    public void getRoomPhase(MenuItem item) {
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

    public void getRoomState(MenuItem item) {
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

    public void disconnect(MenuItem item) {

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

    public void readonly(MenuItem item) {
        logAction();
        room.disableOperations(true);
    }

    public void disableReadonly(MenuItem item) {
        logAction();
        room.disableOperations(false);
    }

    public void pencil(MenuItem item) {
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.PENCIL);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void rectangle(MenuItem item) {
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{99, 99, 99});
        memberState.setCurrentApplianceName(Appliance.RECTANGLE);
        memberState.setStrokeWidth(10);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void color(MenuItem item) {
        logAction();
        MemberState memberState = new MemberState();
        memberState.setStrokeColor(new int[]{200, 200, 200});
        memberState.setCurrentApplianceName(Appliance.PENCIL);
        memberState.setStrokeWidth(4);
        memberState.setTextSize(10);
        room.setMemberState(memberState);
    }

    public void convertPoint(MenuItem item) {
        //获取特定点，在白板内部的坐标点
        room.convertToPointInWorld(0, 0, new Promise<Point>() {
            @Override
            public void then(Point point) {
                logRoomInfo(gson.toJson(point));
            }

            @Override
            public void catchEx(SDKError t) {
                Logger.error("convertToPointInWorld  error", t);
            }
        });
    }

    public void externalEvent(MenuItem item) {
        logAction();
        room.disableOperations(true);
        room.externalDeviceEventDown(new RoomMouseEvent(100, 300));
        room.externalDeviceEventMove(new RoomMouseEvent(100, 400));
        room.externalDeviceEventMove(new RoomMouseEvent(100, 500));
        room.externalDeviceEventMove(new RoomMouseEvent(100, 600));
        room.externalDeviceEventMove(new RoomMouseEvent(100, 700));
        room.externalDeviceEventUp(new RoomMouseEvent(100, 700));
        room.disableOperations(false);
    }

    public void zoomChange(MenuItem item) {
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
        Log.i(ROOM_INFO, Thread.currentThread().getStackTrace()[3].getMethodName() + " " + str);
    }

    void logAction(String str) {
        Log.i(ROOM_ACTION, Thread.currentThread().getStackTrace()[3].getMethodName() + " " + str);
    }

    void logAction() {
        Log.i(ROOM_ACTION, Thread.currentThread().getStackTrace()[3].getMethodName());
    }

}
