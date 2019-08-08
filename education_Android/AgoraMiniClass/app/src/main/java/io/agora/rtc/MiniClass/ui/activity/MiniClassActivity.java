package io.agora.rtc.MiniClass.ui.activity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import java.util.List;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.ChannelAttrUpdatedResponse;
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
import io.agora.rtc.MiniClass.model.rtm.RtmManager;
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
import io.agora.rtm.RtmMessage;

public class MiniClassActivity extends BaseActivity {

    private TextView mTvTabChatRoom, mTvTabStudentList;
    private static final LogUtil log = new LogUtil("MiniClassActivity");

    private BaseFragment mChatRoomFragment, mStudentListFragment, mWhiteBoardFragment, mVideoCallFragment;
    private FrameLayout mFlWhiteBoardLayout, mFl_loading;
    private ConstraintLayout mClRTMLayout;

    public static final int JOIN_STATE_IDLE = 0;
    public static final int JOIN_STATE_JOINING = 1;
    public static final int JOIN_STATE_JOIN_SUCCESS = 2;
    public static final int JOIN_STATE_JOIN_FAILED = 3;

    private int mRtcJoinState = JOIN_STATE_IDLE;
    private int mRtmJoinState = JOIN_STATE_IDLE;
    private int mWhiteJoinState = JOIN_STATE_IDLE;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mini_class);

        mClRTMLayout = findViewById(R.id.cl_rtm_layout);
        mFlWhiteBoardLayout = findViewById(R.id.fl_white_board_layout);
        mFl_loading = findViewById(R.id.fl_progress_bar);

        mFl_loading.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return true;
            }
        });

        initRTCLayout();

        initWhiteBoardLayout();

        initRTMLayout();
    }

    private void initRTCLayout() {
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
        rtmManager().setLoginStatusListener(null);
        rtmManager().leaveChannel();
        rtmManager().unregisterListener(mRtmClientListener);
        mRtmChannelListener = null;
        UserConfig.reset();
    }

    @Override
    public void onBackPressed() {
        MyDialogFragment.newInstance(new MyDialogFragment.DialogClickListener() {

            @Override
            public void clickYes() {
                rtmManager().logout();
                rtcWorkerThread().leaveChannel();
                finish();
            }

            @Override
            public void clickNo() {
            }
        }, getString(R.string.Dialog_warning_content_when_click_out)).show(getSupportFragmentManager(), "dialog_exit");
    }

    private RtmManager.MyRtmClientListener mRtmClientListener = new RtmManager.MyRtmClientListener() {
        @Override
        public void onJoinSuccess(JoinSuccessResponse joinSuccessResponse) {
            final JoinSuccessResponse.Args args = joinSuccessResponse.args;
            if (args == null)
                return;

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (isFinishing())
                        return;

                    mRtmJoinState = JOIN_STATE_JOIN_SUCCESS;
                    checkIsAllSuccess();

                    updateMembersAttr(args.members);

                    UserConfig.setChannelAttr(args.channelAttr);
                    updateChannelAttr(args.channelAttr);

                }
            });
        }

        @Override
        public void onMute(Mute mute) {
            final Mute.Args args = mute.args;
            if (args != null && !TextUtils.isEmpty(args.type)) {
                final RtmRoomControl.UserAttr userAttr = UserConfig.getUserAttrByUserId(UserConfig.getRtmUserId());
                if (userAttr == null)
                    return;

                boolean isMute = (Mute.MUTE_RESPONSE.equals(mute.name));
                if (args.type.equals(Mute.AUDIO)) {
                    userAttr.isMuteAudio = isMute;
                } else if (args.type.equals(Mute.VIDEO)) {
                    userAttr.isMuteVideo = isMute;
                }

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinishing())
                            return;
                        notifyMuteMember(args.type, userAttr);
                    }
                });
            }
        }

        @Override
        public void onChannelAttrUpdate(final ChannelAttrUpdatedResponse channelAttrUpdated) {
            if (channelAttrUpdated != null && channelAttrUpdated.args != null && channelAttrUpdated.args.channelAttr != null) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinishing())
                            return;

                        RtmRoomControl.ChannelAttr attr = UserConfig.getChannelAttr();
                        RtmRoomControl.ChannelAttr attrUpdate = channelAttrUpdated.args.channelAttr;
                        if (attr == null) {
                            attr = attrUpdate;
                        } else {
                            if (!TextUtils.isEmpty(attrUpdate.teacherId))
                                attr.teacherId = attrUpdate.teacherId;
                            if (!TextUtils.isEmpty(attrUpdate.whiteboardId))
                                attr.whiteboardId = attrUpdate.whiteboardId;
                            if (attrUpdate.isRecording != 0)
                                attr.isRecording = attrUpdate.isRecording;
                            if (attrUpdate.isSharing != 0)
                                attr.isSharing = attrUpdate.isSharing;
                            if (attrUpdate.shareId != 0)
                                attr.shareId = attrUpdate.shareId;
                        }
                        UserConfig.setChannelAttr(attr);

                        updateChannelAttr(attr);
                    }
                });
            }
        }

        @Override
        public void onMemberJoined(MemberJoined memberJoined) {
            final RtmRoomControl.UserAttr attr = memberJoined.args;
            if (attr != null && !TextUtils.isEmpty(attr.streamId)) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isFinishing())
                            return;
                        UserConfig.putMember(attr);
                        if (Constant.Role.TEACHER.strValue().equals(attr.role)) {
                            ToastUtil.showErrorShort(MiniClassActivity.this, R.string.Teacher_joined);
                        }

                        notifyUpdateMembers();
                    }
                });
            }
        }

        @Override
        public void onMemberLeft(final String uid) {

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (isFinishing())
                        return;

                    RtmRoomControl.UserAttr userAttr = UserConfig.removeMember(uid);
                    if (userAttr != null) {
                        if (Constant.Role.TEACHER.strValue().equals(userAttr.role)) {
                            ToastUtil.showErrorShort(MiniClassActivity.this, R.string.Teacher_left);
                        }

                        notifyUpdateMembers();
                    }
                }
            });
        }

        @Override
        public void onChannelMsg(final ChannelMessage msg) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (isFinishing())
                        return;
                    onMessageUpdate(msg.args);
                }
            });
        }

        @Override
        public void onJoinFailure(final String failInfo) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mFl_loading != null) {
                        mFl_loading.setVisibility(View.GONE);
                        ToastUtil.showErrorShort(MiniClassActivity.this, failInfo);
                        finish();
                    }
                }
            });
        }

        @Override
        public void onConnectionStateChanged(int i, int i1) {
        }

        @Override
        public void onMessageReceived(RtmMessage rtmMessage, String peerId) {
        }

        @Override
        public void onTokenExpired() {
        }
    };

    private void checkIsAllSuccess() {
        if (mRtcJoinState == JOIN_STATE_JOIN_SUCCESS && mRtmJoinState == JOIN_STATE_JOIN_SUCCESS && mWhiteJoinState == JOIN_STATE_JOIN_SUCCESS) {
            mFl_loading.setVisibility(View.GONE);
            ToastUtil.showShort("Join classroom success");
        } else if (mRtcJoinState == JOIN_STATE_JOIN_FAILED || mRtmJoinState == JOIN_STATE_JOIN_FAILED || mWhiteJoinState == JOIN_STATE_JOIN_FAILED) {
            String failedReason;
            if (mRtcJoinState == JOIN_STATE_JOIN_FAILED) {
                failedReason = "Rtc join failed.";
            } else if (mRtmJoinState == JOIN_STATE_JOIN_FAILED) {
                failedReason = "Rtm join failed.";
            } else {
                failedReason = "White join failed.";
            }
            errorAlert("Join classroom failed", failedReason);
        }
    }

    private void notifyMuteMember(String muteType, RtmRoomControl.UserAttr userAttr) {
        MuteEvent event = new MuteEvent(userAttr);
        event.muteType = muteType;

        mVideoCallFragment.onActivityEvent(event);
        mStudentListFragment.onActivityEvent(event);
        mWhiteBoardFragment.onActivityEvent(event);
    }

    private void updateChannelAttr(RtmRoomControl.ChannelAttr channelAttr) {
        WhiteBoardFragment.Event event = new WhiteBoardFragment.Event(WhiteBoardFragment.Event.EVENT_TYPE_UPDATE_UUID);
        if (channelAttr == null) {
            event.text1 = null;
        } else {
            event.text1 = channelAttr.whiteboardId;
        }

        mWhiteBoardFragment.onActivityEvent(event);
    }

    private void initRTMLayout() {
        mTvTabChatRoom = findViewById(R.id.tv_tab_chatroom);
        mTvTabStudentList = findViewById(R.id.tv_tab_student_list);
        mChatRoomFragment = ChatroomFragment.newInstance();
        mStudentListFragment = StudentListFrament.newInstance();

        getSupportFragmentManager().beginTransaction()
                .add(R.id.fl_im, mChatRoomFragment)
                .add(R.id.fl_im, mStudentListFragment)
                .commit();

        onClickTabChatRoom(mTvTabChatRoom);

        rtmManager().registerListener(mRtmClientListener);

        rtmManager().setLoginStatusListener(new RtmManager.LoginStatusListener() {
            @Override
            public void onLoginStatusChanged(int loginStatus) {
                log.d("logStatus:" + loginStatus);
                if (loginStatus == RtmManager.LOGIN_STATUS_ONLINE_AND_SEVER_ENABLE) {
                    log.d("start send msgArgs");

                    rtmManager().sendJoinMsg(new ResultCallback<Void>() {
                        @Override
                        public void onSuccess(Void o) {
                            log.d("sendRtmJoin success");
                        }

                        @Override
                        public void onFailure(ErrorInfo errorInfo) {
                            log.d("sendRtmJoin fail" + errorInfo);
                        }
                    });

                    rtmManager().createAndJoinChannel(UserConfig.getRtmChannelName(), mRtmChannelListener, new ResultCallback<Void>() {
                        @Override
                        public void onSuccess(Void responseInfo) {
                            log.d("join in rtm success");
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

        if (members != null) {
            for (int i = 0; i < members.size(); i++) {
                RtmRoomControl.UserAttr attr = members.get(i);
                if (Constant.Role.TEACHER.strValue().equals(attr.role)) {
                    UserConfig.addTeacherAttr(attr);
                } else if (Constant.Role.STUDENT.strValue().equals(attr.role)) {
                    UserConfig.addStudentAttr(attr);
                } else {
                    UserConfig.addAudienceAttr(attr);
                }
            }
        }

        if (UserConfig.getTeacherAttr() == null) {
            ToastUtil.showErrorShort(MiniClassActivity.this, R.string.There_is_no_teacher_in_this_classroom);
        }

        notifyUpdateMembers();
    }

    private void notifyUpdateMembers() {

        UpdateMembersEvent updateMembersEvent = new UpdateMembersEvent();
        updateMembersEvent.setTeacherAttr(UserConfig.getTeacherAttr());
        updateMembersEvent.setUserAttrList(UserConfig.getStudentAttrsList());

        mVideoCallFragment.onActivityEvent(updateMembersEvent);
        mStudentListFragment.onActivityEvent(updateMembersEvent);
        mWhiteBoardFragment.onActivityEvent(updateMembersEvent);
    }

    private void initWhiteBoardLayout() {
        mWhiteBoardFragment = WhiteBoardFragment.newInstance(null);
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_white_board_layout, mWhiteBoardFragment).commit();
    }

    public void onClickTabStudentList(View view) {
        mTvTabChatRoom.setSelected(false);
        mTvTabStudentList.setSelected(true);

        getSupportFragmentManager().beginTransaction()
                .hide(mChatRoomFragment)
                .show(mStudentListFragment).commit();
    }

    public void onClickTabChatRoom(View view) {
        mTvTabChatRoom.setSelected(true);
        mTvTabStudentList.setSelected(false);

        getSupportFragmentManager().beginTransaction()
                .hide(mStudentListFragment)
                .show(mChatRoomFragment).commit();
    }

    private void errorAlert(String title, String msg) {
        AlertDialog alertDialog = new AlertDialog.Builder(MiniClassActivity.this).create();
        alertDialog.setTitle(title);
        alertDialog.setMessage(msg);
        alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        finish();
                    }
                });
        alertDialog.show();
    }

    @Override
    public void onFragmentMainThreadEvent(final BaseEvent event) {
        if (event instanceof WhiteBoardFragment.Event) {
            switch (event.getEventType()) {
                case WhiteBoardFragment.Event.EVENT_TYPE_ALERT:
                    errorAlert(event.text1, event.text2);
                    break;

                case WhiteBoardFragment.Event.EVENT_TYPE_MAX:
                    mClRTMLayout.setVisibility(View.GONE);
                    ConstraintLayout.LayoutParams layoutParamsMax = (ConstraintLayout.LayoutParams) mFlWhiteBoardLayout.getLayoutParams();
                    layoutParamsMax.topMargin = getResources().getDimensionPixelSize(R.dimen.dp_9);
                    layoutParamsMax.setMarginEnd(getResources().getDimensionPixelSize(R.dimen.dp_9));
                    mFlWhiteBoardLayout.setLayoutParams(layoutParamsMax);
                    mVideoCallFragment.onActivityEvent(new VideoCallFragment.Event(VideoCallFragment.Event.EVENT_TYPE_MAX));
                    break;

                case WhiteBoardFragment.Event.EVENT_TYPE_MIN:
                    mClRTMLayout.setVisibility(View.VISIBLE);
                    ConstraintLayout.LayoutParams layoutParamsMin = (ConstraintLayout.LayoutParams) mFlWhiteBoardLayout.getLayoutParams();
                    layoutParamsMin.topMargin = getResources().getDimensionPixelSize(R.dimen.dp_99);
                    layoutParamsMin.setMarginEnd(0);
                    mFlWhiteBoardLayout.setLayoutParams(layoutParamsMin);
                    mVideoCallFragment.onActivityEvent(new VideoCallFragment.Event(VideoCallFragment.Event.EVENT_TYPE_MIN));
                    break;

                case WhiteBoardFragment.Event.EVENT_TYPE_NOTIFY_CREATED_UUID:
                    RtmRoomControl.ChannelAttr channelAttr = UserConfig.getChannelAttr();
                    if (channelAttr == null)
                        channelAttr = new RtmRoomControl.ChannelAttr();

                    channelAttr.whiteboardId = event.text1;
                    rtmManager().updateChannelAttr(channelAttr, new ResultCallback<Void>() {
                        @Override
                        public void onSuccess(Void aVoid) {
                        }

                        @Override
                        public void onFailure(ErrorInfo errorInfo) {
                            MiniClassActivity.this.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    ToastUtil.showErrorShort(MiniClassActivity.this, R.string.send_message_failed);
                                }
                            });
                        }
                    });
                    break;

                case WhiteBoardFragment.Event.EVENT_TYPE_NOTIFY_JOIN_STATE:
                    mWhiteJoinState = event.value1;
                    checkIsAllSuccess();
                    break;

                case WhiteBoardFragment.Event.EVENT_TYPE_MUTE_LOCAL_AUDIO_BY_UI:
                    RtmRoomControl.UserAttr userAttr = UserConfig.getUserAttrByUserId(UserConfig.getRtmUserId());
                    if (userAttr != null) {
                        userAttr.isMuteAudio = event.bool1;
                    }
                    notifyMuteMember(Mute.AUDIO, userAttr);
                    break;

                case WhiteBoardFragment.Event.EVENT_TYPE_MUTE_LOCAL_VIDEO_BY_UI:
                    RtmRoomControl.UserAttr userAttr1 = UserConfig.getUserAttrByUserId(UserConfig.getRtmUserId());
                    if (userAttr1 == null)
                        return;

                    userAttr1.isMuteVideo = event.bool1;

                    notifyMuteMember(Mute.VIDEO, userAttr1);
                    break;
            }

        } else if (event instanceof VideoCallFragment.Event) {
            switch (event.getEventType()) {
                case VideoCallFragment.Event.EVENT_TYPE_NOTIFY_JOIN_STATE:
                    mRtcJoinState = event.value1;
                    checkIsAllSuccess();
                    break;

                case VideoCallFragment.Event.EVENT_TYPE_MUTE_AUDIO_FROM_RTC:
                    RtmRoomControl.UserAttr userAttr = UserConfig.getUserAttrByUserId(event.text1);

                    if (userAttr != null) {
                        userAttr.isMuteAudio = event.bool1;
                        if (Constant.Role.TEACHER.strValue().equals(userAttr.role)) {
                            String muteStr = userAttr.isMuteAudio ? "closed audio." : "opened audio.";
                            ToastUtil.showShort("Teacher " + muteStr);
                        }
                    }

                    notifyMuteMember(Mute.AUDIO, userAttr);
                    break;

                case VideoCallFragment.Event.EVENT_TYPE_MUTE_VIDEO_FROM_RTC:
                    RtmRoomControl.UserAttr userAttr1 = UserConfig.getUserAttrByUserId(event.text1);
                    if (userAttr1 == null)
                        return;

                    userAttr1.isMuteVideo = event.bool1;
                    if (Constant.Role.TEACHER.strValue().equals(userAttr1.role)) {
                        String muteStr = userAttr1.isMuteVideo ? "closed video." : "opened video.";
                        ToastUtil.showShort("Teacher " + muteStr);
                    }

                    notifyMuteMember(Mute.VIDEO, userAttr1);
                    break;
            }
        }
    }

    public void onClickPower(View view) {
        onBackPressed();
    }
}
