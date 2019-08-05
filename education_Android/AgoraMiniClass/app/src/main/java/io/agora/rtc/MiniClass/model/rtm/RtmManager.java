package io.agora.rtc.MiniClass.model.rtm;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.LogRecord;

import io.agora.rtc.MiniClass.BuildConfig;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.ChannelAttrUpdatedResponse;
import io.agora.rtc.MiniClass.model.bean.ChannelMessage;
import io.agora.rtc.MiniClass.model.bean.JoinRequest;
import io.agora.rtc.MiniClass.model.bean.JoinSuccessResponse;
import io.agora.rtc.MiniClass.model.bean.MemberJoined;
import io.agora.rtc.MiniClass.model.bean.Mute;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.bean.UpdateChannelAttr;
import io.agora.rtc.MiniClass.model.bean.UpdateUserAttr;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmChannel;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmClient;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;

public class RtmManager {
    private final LogUtil log = new LogUtil("RtmManager");

    private Context mContext;
    private RtmClient mRtmClient;
    private List<MyRtmClientListener> mListenerList = new ArrayList<>();
    private RtmDemoAPI chatDemoAPI = new RtmDemoAPI();

    public RtmDemoAPI getRtmDemoAPI() {
        return chatDemoAPI;
    }

    public RtmManager(Context context) {
        mContext = context;
    }

    RtmClientListener mClientListener = new RtmClientListener() {
        @Override
        public void onConnectionStateChanged(int state, int reason) {
            log.i("state:" + state + ",reason:" + reason);
            for (MyRtmClientListener listener : mListenerList) {
                if (listener != null)
                    listener.onConnectionStateChanged(state, reason);
            }
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String peerId) {
            log.i("msgArgs:" + rtmMessage.getText() + ", peerId：" + peerId);

            String s = rtmMessage.getText();
            if (TextUtils.equals(peerId, UserConfig.getRtmServerId())) {
                try {
                    JSONObject object = new JSONObject(s);
                    String name = object.getString("name");
                    if ("JoinSuccess".equals(name)) {
                        JoinSuccessResponse response = new Gson().fromJson(s, JoinSuccessResponse.class);

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onJoinSuccess(response);
                        }
                    } else if ("ChannelMessage".equals(name)) {
                        ChannelMessage msg = new Gson().fromJson(s, ChannelMessage.class);

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onChannelMsg(msg);
                        }

                    } else if ("MemberJoined".equals(name)) {
                        MemberJoined joined = new Gson().fromJson(s, MemberJoined.class);

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onMemberJoined(joined);
                        }

                    } else if ("MemberLeft".equals(name)) {
                        JsonObject o = new Gson().fromJson(s, JsonObject.class);
                        String uid = o.getAsJsonObject("args").get("uid").getAsString();

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onMemberLeft(uid);
                        }

                    } else if (Mute.MUTE_RESPONSE.equals(name) || Mute.UN_MUTE_RESPONSE.equals(name)) {
                        Mute mute = new Gson().fromJson(s, Mute.class);

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onMute(mute);
                        }

                    } else if ("ChannelAttrUpdated".equals(name)) {
                        ChannelAttrUpdatedResponse channelAttrUpdatedResponse = new Gson().fromJson(s, ChannelAttrUpdatedResponse.class);

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onChannelAttrUpdate(channelAttrUpdatedResponse);
                        }

                    } else if ("JoinFailure".equals(name)) {
                        JsonObject o = new Gson().fromJson(s, JsonObject.class);
                        String info = o.getAsJsonObject("args").get("info").getAsString();

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onJoinFailure(info);
                        }
                    } else {

                        for (MyRtmClientListener listener : mListenerList) {
                            if (listener != null)
                                listener.onMessageReceived(rtmMessage, peerId);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void onTokenExpired() {
            log.i("onTokenExpired");
        }
    };

    private Handler mHandler = new Handler(Looper.getMainLooper());

    public void init() {
        String appID = mContext.getString(R.string.agora_app_id);

        try {
            mRtmClient = RtmClient.createInstance(mContext, appID, mClientListener);

            chatDemoAPI.getRTMId(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    log.e("Get rtm id failed." + e.toString());
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    try {
                        if (response.code() == 200) {
//                                    JsonObject rtmId = new Gson().fromJson(response.body().string(), JsonObject.class);
                            final String rtmId = response.body().string();

                            log.i("getRtmId:" + rtmId);

                            if (!TextUtils.isEmpty(rtmId)) {
                                mHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        UserConfig.setRtmServerId(rtmId);
                                        log.d("setRtmSererId" + rtmId);
                                        if (mLoginStatus == LOGIN_STATUS_ONLINE) {
                                            changeLoginStatus(LOGIN_STATUS_ONLINE_AND_SEVER_ENABLE);
                                        }
                                    }
                                });
                            }

                        } else {
                            onFailure(call, new IOException(response.body().string()));
                        }
                    } catch (Throwable e) {
                        onFailure(call, new IOException(e.toString()));
                    }
                }
            });

            if (BuildConfig.DEBUG) {
                mRtmClient.setParameters("{\"rtm.log_filter\": 65535}");
            }
        } catch (Exception e) {
            log.e(Log.getStackTraceString(e));
            throw new RuntimeException("NEED TO check rtm sdk init fatal error\n" + Log.getStackTraceString(e));
        }
    }

    public final static int LOGIN_STATUS_IDLE = -1;
    public final static int LOGIN_STATUS_LOGINING = 100;
    public final static int LOGIN_STATUS_ONLINE = 101;
    public final static int LOGIN_STATUS_LOGIN_FAILED = 102;
    public final static int LOGIN_STATUS_ONLINE_AND_SEVER_ENABLE = 103;

    private volatile int mLoginStatus = LOGIN_STATUS_IDLE;

    /**
     * API CALL: login RTM server
     */
    public void login() {
        String userId = UserConfig.getRtmUserId();
        if (TextUtils.isEmpty(userId))
            return;

        log.i("login " + userId);
        changeLoginStatus(LOGIN_STATUS_LOGINING);
        mRtmClient.login(null, userId, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void responseInfo) {
                changeLoginStatus(LOGIN_STATUS_ONLINE);
                log.i("login success");
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
//                changeLoginStatus(LOGIN_STATUS_LOGIN_FAILED);
                login();
                log.e("login failed, info:" + errorInfo.toString());
            }
        });
    }


    public RtmChannel createAndJoinChannel(String channel, RtmChannelListener rtmChannelListener, ResultCallback callback) {
        if (TextUtils.isEmpty(channel))
            return null;

        try {
            log.i("create channel." + channel);
            mRtmChannel = mRtmClient.createChannel(channel, rtmChannelListener);

            mRtmChannel.join(callback);
        } catch (RuntimeException e) {
            log.e("Fails to create channel. Maybe the channel ID is invalid," +
                    " or already in use. See the API reference for more information.");
        }

        return mRtmChannel;
    }

//    public void sendChannelMessage(RtmChannel rtmChannel, String msgArgs) {
//        RtmMessage message = mRtmClient.createMessage();
//        message.setText(msgArgs);
//
//        rtmChannel.sendMessage(message, new ResultCallback<Void>() {
//            @Override
//            public void onSuccess(Void aVoid) {
//            }
//
//            @Override
//            public void onFailure(ErrorInfo errorInfo) {
//            }
//        });
//    }

    public void logout() {
        if (mLoginStatus == LOGIN_STATUS_IDLE)
            return;

        if (mLoginStatus != LOGIN_STATUS_LOGIN_FAILED) {
            mRtmClient.logout(null);
        }

        mLoginStatus = LOGIN_STATUS_IDLE;
    }

    private void changeLoginStatus(final int loginStatus) {

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mLoginStatus = loginStatus;
                log.d("loginstatus" + mLoginStatus);

                log.d("getRtmServerId" + UserConfig.getRtmServerId());
                if (mLoginStatus == LOGIN_STATUS_ONLINE && !TextUtils.isEmpty(UserConfig.getRtmServerId())) {
                    changeLoginStatus(LOGIN_STATUS_ONLINE_AND_SEVER_ENABLE);
                } else {
                    if (loginStatusListener != null) {
                        loginStatusListener.onLoginStatusChanged(loginStatus);
                    }
                }
            }
        });
    }

    private LoginStatusListener loginStatusListener;

    public void setLoginStatusListener(LoginStatusListener listener) {
        log.d("registerStatus");
        if (listener != null)
            listener.onLoginStatusChanged(mLoginStatus);
        loginStatusListener = listener;
    }

    private RtmChannel mRtmChannel;

    public void leaveChannel() {
        if (mRtmChannel != null) {
            mRtmChannel.leave(new ResultCallback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    log.d("leave success");
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {

                }
            });
            mRtmChannel.release();
            mRtmChannel = null;
        }
    }

    public interface LoginStatusListener {
        void onLoginStatusChanged(int loginStatus);
    }

    public RtmClient getRtmClient() {
        return mRtmClient;
    }

    public void registerListener(MyRtmClientListener listener) {
        mListenerList.add(listener);
    }

    public interface MyRtmClientListener extends RtmClientListener {
        void onJoinSuccess(JoinSuccessResponse joinSuccessResponse);
        void onMute(Mute mute);
        void onChannelAttrUpdate(ChannelAttrUpdatedResponse channelAttrUpdated);
        void onMemberJoined(MemberJoined memberJoined);
        void onMemberLeft(String uid);
        void onChannelMsg(ChannelMessage msg);
        void onJoinFailure(String failInfo);
    }

    public void unregisterListener(MyRtmClientListener listener) {
        mListenerList.remove(listener);
    }


    public void mute(boolean isMute, String type, String streamId, ResultCallback<Void> callback) {
        Mute mute = new Mute();
        mute.name = isMute ? Mute.MUTE_REQUEST : Mute.UN_MUTE_REQUEST;
        mute.args = new Mute.Args();
        mute.args.target = new ArrayList<>();
        mute.args.target.add(streamId);
        mute.args.type = type;

        sendChatMsg(mute, callback);
    }

    public void muteArray(boolean isMute, String type, List<String> target, ResultCallback<Void> callback) {
        Mute mute = new Mute();
        mute.name = isMute ? Mute.MUTE_REQUEST : Mute.UN_MUTE_REQUEST;
        mute.args = new Mute.Args();
        mute.args.target = target;
        mute.args.type = type;

        sendChatMsg(mute, callback);
    }

    public void updateChannelAttr(RtmRoomControl.ChannelAttr channelAttr, ResultCallback<Void> callback) {
        UpdateChannelAttr attr = new UpdateChannelAttr();
        attr.args = new UpdateChannelAttr.Args();
        attr.args.channelAttr = channelAttr;

        sendChatMsg(attr, callback);
    }

    public void updateUserAttr(RtmRoomControl.UserAttr attr, ResultCallback<Void> callback) {
        if (attr == null || TextUtils.isEmpty(attr.streamId))
            return;

        UpdateUserAttr updateUserAttr = new UpdateUserAttr();
        updateUserAttr.args = new UpdateUserAttr.Args();
        updateUserAttr.args.uid = attr.streamId;
        updateUserAttr.args.userAttr = attr;

        sendChatMsg(updateUserAttr, callback);
    }

    public void sendJoinMsg(ResultCallback<Void> callback) {
        JoinRequest bean = new JoinRequest();
        bean.args = new JoinRequest.Args();
        bean.args.channel = UserConfig.getRtmChannelName();

        RtmRoomControl.UserAttr attr = new RtmRoomControl.UserAttr();
        attr.name = UserConfig.getRtmUserName();
        attr.role = String.valueOf(UserConfig.getRole().intValue());
        attr.streamId = UserConfig.getRtmUserId();
        bean.args.userAttr = attr;

        sendChatMsg(bean, callback);
    }

    public void sendChatMsg(Object msg, final ResultCallback<Void> callback) {
        if (msg == null)
            return;

        RtmMessage rtmMessage = mRtmClient.createMessage();
        String json = new Gson().toJson(msg);
        rtmMessage.setText(json);

        mRtmClient.sendMessageToPeer(UserConfig.getRtmServerId(), rtmMessage, callback);
        log.d("send:" + json);
    }


}
