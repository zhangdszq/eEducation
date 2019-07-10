package io.agora.rtc.MiniClass.ui.activity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import io.agora.rtc.Constants;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.ChannelMessage;
import io.agora.rtc.MiniClass.model.bean.JoinSuccessResponse;
import io.agora.rtc.MiniClass.model.bean.MemberJoined;
import io.agora.rtc.MiniClass.model.bean.Mute;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.MuteEvent;
import io.agora.rtc.MiniClass.model.event.UpdateMembersEvent;
import io.agora.rtc.MiniClass.model.rtm.ChatManager;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.MiniClass.model.util.ToastUtil;
import io.agora.rtc.MiniClass.ui.fragment.BaseFragment;
import io.agora.rtc.MiniClass.ui.fragment.ChatroomFragment;
import io.agora.rtc.MiniClass.ui.fragment.MyDialogFragment;
import io.agora.rtc.MiniClass.ui.fragment.StudentListFrament;
import io.agora.rtc.MiniClass.ui.fragment.VideoCallFragment;
import io.agora.rtc.MiniClass.ui.fragment.WhiteBoardFragment;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmChannelListener;
import io.agora.rtm.RtmChannelMember;
import io.agora.rtm.RtmClientListener;
import io.agora.rtm.RtmMessage;

public class MiniClassActivity extends BaseActivity {

    private TextView mTvTabChatRoom, mTvTabStudentList;
    private View mLineTabChatRoomBottom, mLineTabStudentListBottom;
    private static final LogUtil log = new LogUtil("MiniClassActivity");

    private BaseFragment mChatRoomFragment, mStudentListFragment, mWhiteBoardFragment, mVideoCallFragment;
    private FrameLayout mFlWhiteBoardLayout;
    private ConstraintLayout mClRTMLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mini_class);

//        mFlRTCLayout = findViewById(R.id.fl_video_call_layout);
        mClRTMLayout = findViewById(R.id.cl_im_layout);
        mFlWhiteBoardLayout = findViewById(R.id.fl_white_board_layout);

        initVideoCallLayout();

        initWhiteBoardLayout();

        initIMLayout();
    }

    private void initVideoCallLayout() {
        mVideoCallFragment = VideoCallFragment.newInstance();
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_video_call_layout, mVideoCallFragment).commit();
    }


    public RtmChannelListener mRtmChannelListener = new RtmChannelListener() {
        @Override
        public void onMessageReceived(final RtmMessage rtmMessage, final RtmChannelMember rtmChannelMember) {
            String s = rtmMessage.getText();
            if (TextUtils.isEmpty(s))
                return;

            log.i("channel msgArgs:" + s);
        }

        @Override
        public void onMemberJoined(RtmChannelMember rtmChannelMember) {
        }

        @Override
        public void onMemberLeft(RtmChannelMember rtmChannelMember) {
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        chatManager().leaveChannel();
        chatManager().unregisterListener(mRtmClientListener);
        mRtmChannelListener = null;
    }

    @Override
    public void onBackPressed() {
        MyDialogFragment.newInstance(new MyDialogFragment.DialogClickListener() {

            @Override
            public void clickYes() {
                chatManager().logout();
                workerThread().leaveChannel();
                finish();
            }

            @Override
            public void clickNo() {
            }
        }, getString(R.string.Dialog_warning_content_when_click_out)).show(getSupportFragmentManager(), "dialog_exit");
    }

    private RtmClientListener mRtmClientListener = new RtmClientListener() {
        @Override
        public void onConnectionStateChanged(int i, int i1) {

        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String peerId) {
            String s = rtmMessage.getText();
            if (TextUtils.equals(peerId, UserConfig.getRtmServerId())) {
                try {
                    JSONObject object = new JSONObject(s);
                    String name = object.getString("name");
                    if ("JoinSuccess".equals(name)) {
                        JoinSuccessResponse response = new Gson().fromJson(s, JoinSuccessResponse.class);
                        log.d("joinsucces");
                        final JoinSuccessResponse.Args args = response.args;
                        if (args == null)
                            return;
                        log.d("joinsucces");
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                ToastUtil.showShort("join rtm success");
                                updateMembersAttr(args.members);
                            }
                        });

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                UserConfig.setChannelAttr(args.channelAttr);

                                updateWhiteboardUUid(args.channelAttr);
                            }
                        });
                    } else if ("ChannelMessage".equals(name)) {
                        final ChannelMessage msg = new Gson().fromJson(s, ChannelMessage.class);
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                onMessageUpdate(msg.args);
                            }
                        });
                    } else if ("MemberJoined".equals(name)) {
                        MemberJoined joined = new Gson().fromJson(s, MemberJoined.class);
                        final RtmRoomControl.UserAttr attr = joined.args;
                        if (attr != null && !TextUtils.isEmpty(attr.streamId)) {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    UserConfig.putMember(attr);
                                    notifyUpdateMembers();
                                }
                            });
                        }
                    } else if ("MemberLeft".equals(name)) {
                        JsonObject o = new Gson().fromJson(s, JsonObject.class);
                        final String uid = o.getAsJsonObject("args").get("uid").getAsString();

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                UserConfig.removeMember(uid);

                                notifyUpdateMembers();
                            }
                        });
                    } else if (Mute.MUTE_RESPONSE.equals(name) || Mute.UN_MUTE_RESPONSE.equals(name)) {
                        Mute mute = new Gson().fromJson(s, Mute.class);
                        final Mute.Args args = mute.args;
//                        if (args.ta)
                        if (args != null && !TextUtils.isEmpty(args.type)) {
                            RtmRoomControl.UserAttr userAttr = UserConfig.getUserAttrByUserId(UserConfig.getRtmUserId());
                            if (userAttr == null)
                                return;


                            boolean isMute = (Mute.MUTE_RESPONSE.equals(mute.name));
                            if (args.type.equals(Mute.CHAT)) {
                                userAttr.isMuteVideo = isMute;
                                userAttr.isMuteAudio = isMute;
                            } else if (args.type.equals(Mute.AUDIO)) {
                                userAttr.isMuteAudio = isMute;
                            } else if (args.type.equals(Mute.VIDEO)) {
                                userAttr.isMuteVideo = isMute;
                            }

//                            UserConfig.putMember(userAttr);

                            final RtmRoomControl.UserAttr finalAttr = new RtmRoomControl.UserAttr();
                            finalAttr.name = userAttr.name;
                            finalAttr.isMuteVideo = userAttr.isMuteVideo;
                            finalAttr.isMuteAudio = userAttr.isMuteAudio;
                            finalAttr.streamId = userAttr.streamId;
                            finalAttr.role = userAttr.role;

                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    notifyMuteMember(args.type, finalAttr);
                                }
                            });
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }

        @Override
        public void onTokenExpired() {

        }
    };

    private void notifyMuteMember(String muteType, RtmRoomControl.UserAttr userAttr) {
        MuteEvent event = new MuteEvent(userAttr);
        event.muteType = muteType;
        mVideoCallFragment.onActivityEvent(event);
        mStudentListFragment.onActivityEvent(event);
//        mWhiteBoardFragment.onActivityEvent(event);
    }

    private void updateWhiteboardUUid(RtmRoomControl.ChannelAttr channelAttr) {
        WhiteBoardFragment.Event event = new WhiteBoardFragment.Event(WhiteBoardFragment.Event.EVENT_TYPE_UUID);
        if (channelAttr == null) {
            event.uuid = null;
        } else {
            event.uuid = channelAttr.whiteboardId;
        }

        mWhiteBoardFragment.onActivityEvent(event);
    }

    private void initIMLayout() {
        mTvTabChatRoom = findViewById(R.id.tv_tab_chatroom);
        mTvTabStudentList = findViewById(R.id.tv_tab_student_list);
        mLineTabChatRoomBottom = findViewById(R.id.line_tab_chat_room_bottom);
        mLineTabStudentListBottom = findViewById(R.id.line_tab_student_list_bottom);

        mChatRoomFragment = ChatroomFragment.newInstance();
        mStudentListFragment = StudentListFrament.newInstance();

        getSupportFragmentManager().beginTransaction()
                .add(R.id.fl_im, mChatRoomFragment)
                .add(R.id.fl_im, mStudentListFragment)
                .commit();

        onClickTabChatRoom(mTvTabChatRoom);

        chatManager().registerListener(mRtmClientListener);

        chatManager().setLoginStatusListener(new ChatManager.LoginStatusListener() {
            @Override
            public void onLoginStatusChanged(int loginStatus) {
                log.d("logStatus:" + loginStatus);
                if (loginStatus == ChatManager.LOGIN_STATUS_ONLINE_AND_SEVER_ENABLE) {
                    log.d("start send msgArgs");

                    chatManager().sendJoinMsg(UserConfig.getRtmServerId(), new ResultCallback<Void>() {
                        @Override
                        public void onSuccess(Void o) {
                            log.d("sendRtmJoin success");
                        }

                        @Override
                        public void onFailure(ErrorInfo errorInfo) {
                            log.d("sendRtmJoin fail" + errorInfo);
                        }
                    });

                    chatManager().createAndJoinChannel(UserConfig.getRtmChannelName(), mRtmChannelListener, new ResultCallback<Void>() {
                        @Override
                        public void onSuccess(Void responseInfo) {
                            log.d("join success");
                        }

                        @Override
                        public void onFailure(ErrorInfo errorInfo) {
                            log.d("join failed");
                        }
                    });

                }
            }
        });

    }


    private void onMessageUpdate(ChannelMessage.Args args) {
        if (args == null)
            return;

        ChatroomFragment.Event event = new ChatroomFragment.Event(ChatroomFragment.Event.EVENT_TYPE_UPDATE_MESSAGE);
        RtmRoomControl.UserAttr attr = UserConfig.getUserAttrByUserId(args.uid);
        if (attr != null && !TextUtils.isEmpty(attr.role)) {
            args.role = Integer.parseInt(attr.role);
        }
        event.msgArgs = args;
        mChatRoomFragment.onActivityEvent(event);
    }

    private void updateMembersAttr(List<RtmRoomControl.UserAttr> members) {

        List<RtmRoomControl.UserAttr> students = new ArrayList<>();

        RtmRoomControl.UserAttr teacherAttr = null;
        if (members != null) {
            for (int i = 0; i < members.size(); i++) {
                RtmRoomControl.UserAttr attr = members.get(i);
                if (Constant.Role.TEACHER.strValue().equals(attr.role)) {
                    teacherAttr = members.get(i);
                } else if (Constant.Role.STUDENT.strValue().equals(attr.role)) {
                    students.add(members.get(i));
                }
            }
        }
        UserConfig.setTeacherAttr(teacherAttr);
        UserConfig.setChannelStudentsAttrs(students);

        notifyUpdateMembers();

    }

    private void notifyUpdateMembers() {

        UpdateMembersEvent updateMembersEvent = new UpdateMembersEvent();
        updateMembersEvent.setTeacherAttr(UserConfig.getTeacherAttr());
        updateMembersEvent.setUserAttrList(UserConfig.getChannelStudentsAttrsList());

        mStudentListFragment.onActivityEvent(updateMembersEvent);
        mVideoCallFragment.onActivityEvent(updateMembersEvent);
        mWhiteBoardFragment.onActivityEvent(updateMembersEvent);
    }

    private void initWhiteBoardLayout() {
        mWhiteBoardFragment = WhiteBoardFragment.newInstance(null);
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_white_board_layout, mWhiteBoardFragment).commit();
    }

    public void onClickTabStudentList(View view) {
        mTvTabChatRoom.setSelected(false);
        mTvTabStudentList.setSelected(true);
        mLineTabChatRoomBottom.setVisibility(View.VISIBLE);
        mLineTabStudentListBottom.setVisibility(View.INVISIBLE);

        getSupportFragmentManager().beginTransaction()
                .hide(mChatRoomFragment)
                .show(mStudentListFragment).commit();
    }

    public void onClickTabChatRoom(View view) {
        mTvTabChatRoom.setSelected(true);
        mTvTabStudentList.setSelected(false);
        mLineTabChatRoomBottom.setVisibility(View.INVISIBLE);
        mLineTabStudentListBottom.setVisibility(View.VISIBLE);

        getSupportFragmentManager().beginTransaction()
                .hide(mStudentListFragment)
                .show(mChatRoomFragment).commit();
    }

    @Override
    public void onFragmentEvent(final BaseEvent event) {
        if (event instanceof WhiteBoardFragment.Event) {
            switch (event.getEventType()) {
                case WhiteBoardFragment.Event.EVENT_TYPE_ALERT:
                    runOnUiThread(new Runnable() {
                        public void run() {
                            AlertDialog alertDialog = new AlertDialog.Builder(MiniClassActivity.this).create();
                            alertDialog.setTitle(event.text1);
                            alertDialog.setMessage(event.text2);
                            alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                                    new DialogInterface.OnClickListener() {
                                        public void onClick(DialogInterface dialog, int which) {
                                            dialog.dismiss();
                                            finish();
                                        }
                                    });
                            alertDialog.show();
                        }
                    });
                    break;
                case WhiteBoardFragment.Event.EVENT_TYPE_EXIT:
                    onBackPressed();
                    break;
                case WhiteBoardFragment.Event.EVENT_TYPE_MAX:
                    mClRTMLayout.setVisibility(View.GONE);
                    ConstraintLayout.LayoutParams layoutParamsMax = (ConstraintLayout.LayoutParams) mFlWhiteBoardLayout.getLayoutParams();
                    layoutParamsMax.topMargin = 0;
                    mFlWhiteBoardLayout.setLayoutParams(layoutParamsMax);
                    mVideoCallFragment.onActivityEvent(new VideoCallFragment.Event(VideoCallFragment.Event.EVENT_TYPE_MAX));
                    break;
                case WhiteBoardFragment.Event.EVENT_TYPE_MIN:
                    mClRTMLayout.setVisibility(View.VISIBLE);
                    ConstraintLayout.LayoutParams layoutParamsMin = (ConstraintLayout.LayoutParams) mFlWhiteBoardLayout.getLayoutParams();
                    layoutParamsMin.topMargin = getResources().getDimensionPixelSize(R.dimen.dp_99);
                    mFlWhiteBoardLayout.setLayoutParams(layoutParamsMin);
                    mVideoCallFragment.onActivityEvent(new VideoCallFragment.Event(VideoCallFragment.Event.EVENT_TYPE_MIN));
                    break;
            }

        }
    }
}
