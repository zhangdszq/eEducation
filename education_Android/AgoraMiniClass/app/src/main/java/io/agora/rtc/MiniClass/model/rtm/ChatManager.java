package io.agora.rtc.MiniClass.model.rtm;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;

import java.io.IOException;
import java.util.ArrayList;
import java.util.IllegalFormatCodePointException;
import java.util.List;

import io.agora.rtc.MiniClass.BuildConfig;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.ChannelMessage;
import io.agora.rtc.MiniClass.model.bean.Chat;
import io.agora.rtc.MiniClass.model.bean.JoinRequest;
import io.agora.rtc.MiniClass.model.bean.Mute;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmChannel;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClient;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;
import io.agora.rtm.internal.RtmManager;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Response;

public class ChatManager {
    private final LogUtil log = new LogUtil("ChatManager");

    private Context mContext;
    private RtmClient mRtmClient;
    private List<RtmClientListener> mListenerList = new ArrayList<>();
    private ChatDemoAPI chatDemoAPI = new ChatDemoAPI();

    public ChatDemoAPI getChatDemoAPI() {
        return chatDemoAPI;
    }

    public ChatManager(Context context) {
        mContext = context;
    }

    RtmClientListener mClientListener = new RtmClientListener() {
        @Override
        public void onConnectionStateChanged(int state, int reason) {
            log.i("state:" + state + ",reason:" + reason);
            for (RtmClientListener listener : mListenerList) {
                if (listener != null)
                    listener.onConnectionStateChanged(state, reason);
            }
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String peerId) {
            log.i("msgArgs:" + rtmMessage.getText() + ", peerId：" + peerId);
            for (RtmClientListener listener : mListenerList) {
                if (listener != null)
                    listener.onMessageReceived(rtmMessage, peerId);
            }
        }

        @Override
        public void onTokenExpired() {
            log.i("onTokenExpired");
        }
    };

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
                            String rtmId = response.body().string();

                            log.i("getRtmId:" + rtmId);

                            if (!TextUtils.isEmpty(rtmId)) {
                                UserConfig.setRtmServerId(rtmId);
                                log.d("setRtmSererId" + rtmId);
                                if (mLoginStatus == LOGIN_STATUS_ONLINE) {
                                    changeLoginStatus(LOGIN_STATUS_ONLINE_AND_SEVER_ENABLE);
                                }
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

        changeLoginStatus(LOGIN_STATUS_LOGINING);
        mRtmClient.login(null, userId, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void responseInfo) {
                changeLoginStatus(LOGIN_STATUS_ONLINE);
                log.i("login success");
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                changeLoginStatus(LOGIN_STATUS_LOGIN_FAILED);
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

    private void changeLoginStatus(int loginStatus) {
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
            mRtmChannel.leave(null);
            mRtmChannel.release();
            mRtmChannel = null;
        }
    }

    public void mute(boolean isMute, String type, String streamId) {
        Mute mute = new Mute();
        mute.name = isMute ? Mute.MUTE : Mute.UN_MUTE;
        mute.args = new Mute.Args();
        mute.args.uid = streamId;
        mute.args.target = new ArrayList<>();
        mute.args.target.add(streamId);
        mute.args.type = type;

        sendChatMsg(UserConfig.getRtmServerId(), mute);
    }

    public void muteArray(boolean isMute, String type, List<String> target) {
        Mute mute = new Mute();
        mute.name = isMute ? Mute.MUTE : Mute.UN_MUTE;
        mute.args = new Mute.Args();
        mute.args.target = target;
        mute.args.type = type;

        sendChatMsg(UserConfig.getRtmServerId(), mute);
    }

    public interface LoginStatusListener {
        void onLoginStatusChanged(int loginStatus);
    }

    public RtmClient getRtmClient() {
        return mRtmClient;
    }

    public void registerListener(RtmClientListener listener) {
        mListenerList.add(listener);
    }

    public void unregisterListener(RtmClientListener listener) {
        mListenerList.remove(listener);
    }


    public void sendJoinMsg(String rtmId, ResultCallback callback) {
        RtmMessage msg = mRtmClient.createMessage();
        JoinRequest bean = new JoinRequest();
        bean.args = new JoinRequest.Args();
        bean.args.channel = UserConfig.getRtmChannelName();

        RtmRoomControl.UserAttr attr = new RtmRoomControl.UserAttr();
        attr.name = UserConfig.getRtmUserName();
        attr.role = String.valueOf(UserConfig.getRole().intValue());
        attr.streamId = UserConfig.getRtmUserId();
        bean.args.userAttr = attr;

        Gson gson = new Gson();
        String json = gson.toJson(bean);
        msg.setText(json);

        mRtmClient.sendMessageToPeer(rtmId, msg, callback);

        log.i("send message:" + json + ", peerId: " + rtmId);
    }

    public void sendChatMsg(String rtmId, Object msg) {
        if (msg == null)
            return;

        RtmMessage rtmMessage = mRtmClient.createMessage();

        String json = new Gson().toJson(msg);
        log.d("send:" + json);
        rtmMessage.setText(json);
        mRtmClient.sendMessageToPeer(rtmId, rtmMessage, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                log.d("send channel msgArgs success.");
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                log.d("send channel msgArgs fail." + errorInfo.toString());
            }
        });
    }


}
