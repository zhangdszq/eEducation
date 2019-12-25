package io.agora.rtc.education.room.largeclass;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.constant.Constant;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.data.ChannelDataReadOnly;
import io.agora.rtc.education.data.ChannelDataRepository;
import io.agora.rtc.education.data.bean.Student;
import io.agora.rtc.education.data.bean.Teacher;
import io.agora.rtc.education.im.ChannelMsg;
import io.agora.rtc.education.im.IMCmd;
import io.agora.rtc.education.im.IMStrategy;
import io.agora.rtc.education.im.P2PMessage;
import io.agora.rtc.education.im.rtm.RtmStrategy;
import io.agora.rtc.education.room.fragment.ChatroomFragment;
import io.agora.rtc.education.room.fragment.WhiteboardFragment;
import io.agora.rtc.education.room.view.SpeakerView;
import io.agora.rtc.education.room.view.UserVideoItem;
import io.agora.rtc.education.widget.dialog.ConfirmDialogFragment;
import io.agora.rtc.lib.util.LogUtil;
import io.agora.rtc.lib.util.ToastUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.RtmChannelMember;

public class LargeClassActivity extends BaseActivity {

    private final LogUtil log = new LogUtil("LargeClassActivity");
    // all
    private ImageView mIcExit;
    private TextView mTvRoomName;
    private FrameLayout mLayoutShareVideo;
    private FrameLayout mLayoutItemTeacher;
    private FrameLayout mLayoutItemStudent;

    private FrameLayout mFlWhiteboard;
    private FrameLayout mFlChatroom;
    private FrameLayout mFlShareVideo;
    private UserVideoItem mVideoItemStudent;
    private UserVideoItem mVideoItemTeacher;

    //portrait
    private TextView mTvBtnWhiteboard;
    private TextView mTvBtnChatroom;

    //landscape
    private ImageView mIcWifi;

    private WhiteboardFragment mWhiteboardFragment;
    private ChatroomFragment mChatroomFragment;

    private RtcDelegate mRtcDelegate;
    private IMStrategy mImStrategy;
    private ChannelDataReadOnly mChannelData;
    private volatile int roomUserCount = 0;

    private IRtcEngineEventHandler mRtcHandler = new IRtcEngineEventHandler() {
        @Override
        public void onFirstLocalVideoFrame(int width, int height, int elapsed) {
            log.d("onFirstLocalVideoFrame");
        }

        @Override
        public void onRtcStats(RtcStats stats) {
            if (stats.rxPacketLossRate > 30 || stats.txPacketLossRate > 30) {
                mIcWifi.setColorFilter(getResources().getColor(R.color.red_FF0D19));
            } else {
                mIcWifi.clearColorFilter();
            }
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            if (uid == Constant.SHARE_UID) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        int uid = Constant.SHARE_UID;
                        mFlShareVideo.removeAllViews();
                        SurfaceView surfaceView = RtcEngine.CreateRendererView(LargeClassActivity.this);
                        mFlShareVideo.addView(surfaceView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                        mRtcDelegate.bindRemoteRtcVideoFitMode(uid, surfaceView);
                        updateShareVideoUI();
                    }
                });
            }
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            if (uid == Constant.SHARE_UID) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mFlShareVideo.removeAllViews();
                        updateShareVideoUI();
                    }
                });
            }
        }

        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            log.i("join rtc success.");
        }
    };

    private RtmStrategy.EventListener mRtmEventListener = new RtmStrategy.EventListener() {
        @Override
        public void onJoinRtmChannelFailure(ErrorInfo errorInfo) {
            log.e("join rtm failed" + errorInfo);
        }

        @Override
        public void onJoinRtmChannelSuccess() {
            log.i("join rtm success");
        }

        @Override
        public void onChannelMemberCountUpdated(int i) {
            roomUserCount = i;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    updateRoomName();
                }
            });
        }

        @Override
        public void onMemberLeft(RtmChannelMember rtmChannelMember) {
            if (rtmChannelMember != null && rtmChannelMember.getUserId() != null
                    && mChannelData.getTeacher() != null
                    && rtmChannelMember.getUserId().equals(String.valueOf(mChannelData.getTeacher().uid))) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mWhiteboardFragment.finishRoomPage();
                    }
                });
            }
        }

        @Override
        public void onChannelAttributesUpdated() {
            final Teacher teacher = mChannelData.getTeacher();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (teacher == null) {
                        ToastUtil.showShort(R.string.There_is_no_teacher_in_this_classroom);
                        mChatroomFragment.setEditTextEnable(true);
                        mVideoItemTeacher.showVideo(false);
                        mVideoItemTeacher.setIcVideoSelect(false);
                        mVideoItemTeacher.setIcAudioState(SpeakerView.STATE_CLOSED);
                        mVideoItemTeacher.setName("");
                        return;
                    }
                    if (mWhiteboardFragment.getUuid() == null && !TextUtils.isEmpty(teacher.whiteboard_uid) && !teacher.whiteboard_uid.equals("0")) {
                        mWhiteboardFragment.joinRoom(teacher.whiteboard_uid, new WhiteboardFragment.JoinRoomCallBack() {
                            @Override
                            public void onSuccess() {
                                ToastUtil.showShort("join whiteboard room success.");
                            }

                            @Override
                            public void onFailure(String err) {
                                ToastUtil.showShort("join whiteboard room fail: " + err);
                                finish();
                            }
                        });
                    }

                    SurfaceView surfaceView = mVideoItemTeacher.getSurfaceView();
                    if (surfaceView == null || surfaceView.getTag() == null || teacher.uid != (int) surfaceView.getTag()) {
                        surfaceView = RtcEngine.CreateRendererView(LargeClassActivity.this);
                        surfaceView.setTag(teacher.uid);
                        mVideoItemTeacher.setVideoView(surfaceView);
                        mRtcDelegate.bindRemoteRtcVideo(teacher.uid, surfaceView);
                    }
                    mVideoItemTeacher.showVideo(teacher.video == 1);
                    mVideoItemTeacher.setIcVideoSelect(teacher.video == 1);
                    mVideoItemTeacher.setIcAudioState(teacher.audio == 0 ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                    mVideoItemTeacher.setName(teacher.account);

                    mChatroomFragment.setEditTextEnable(teacher.mute_chat != 1 && mChannelData.getMyAttr().chat == 1);

                    if (teacher.link_uid != 0) {
                        int linkUid = teacher.link_uid;
                        Student student = mChannelData.getStudent(linkUid);
                        if (student != null) {
                            mVideoItemStudent.setVisibility(View.VISIBLE);

                            SurfaceView surfaceViewStudent = mVideoItemStudent.getSurfaceView();
                            if (surfaceViewStudent == null || surfaceViewStudent.getTag() == null || linkUid != (int) surfaceViewStudent.getTag()) {
                                surfaceViewStudent = RtcEngine.CreateRendererView(LargeClassActivity.this);
                                surfaceViewStudent.setTag(linkUid);
                                surfaceViewStudent.setZOrderMediaOverlay(true);
                                mVideoItemStudent.setVideoView(surfaceViewStudent);
                                if (mChannelData.getMyAttr().uid == linkUid) {
                                    mRtcDelegate.bindLocalRtcVideo(surfaceViewStudent);
                                    mWhiteboardFragment.acceptLink(true);
                                } else {
                                    mRtcDelegate.bindRemoteRtcVideo(linkUid, surfaceViewStudent);
                                }
                                mVideoItemStudent.setVideoView(surfaceViewStudent);
                            }
                            mVideoItemStudent.showVideo(student.video == 1);
                            mVideoItemStudent.setIcVideoSelect(student.video == 1);
                            mVideoItemStudent.setIcAudioState(student.audio == 0 ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                            mVideoItemStudent.setName(student.account);
                        }
                    } else {
                        mVideoItemStudent.setVideoView(null);
                        mVideoItemStudent.setVisibility(View.GONE);
                        if (mWhiteboardFragment.isApplyingOrLinking()) {
                            mWhiteboardFragment.acceptLink(false);
                            mRtcDelegate.changeRoleToAudience();
                        }
                    }
                }
            });
        }

        @Override
        public void onMessageReceived(P2PMessage p2PMessage, String peerId) {
            switch (p2PMessage.cmd) {
                case IMCmd.MUTE_AUDIO:
                    muteLocalAudio(true);
                    break;
                case IMCmd.UNMUTE_AUDIO:
                    muteLocalAudio(false);
                    break;
                case IMCmd.MUTE_VIDEO:
                    muteLocalVideo(true);
                    break;
                case IMCmd.UNMUTE_VIDEO:
                    muteLocalVideo(false);
                    break;
                case IMCmd.ACCEPT:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mWhiteboardFragment.acceptLink(true);
                            mRtcDelegate.changeRoleToBroadcaster();
                            muteLocalAudio(false);
                            muteLocalVideo(false);
                        }
                    });
                    break;
                case IMCmd.REJECT:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            mWhiteboardFragment.acceptLink(false);
                        }
                    });
                    break;
                case IMCmd.MUTE_CHAT:
                    muteLocalChat(true);
                    break;
                case IMCmd.UNMUTE_CAHT:
                    muteLocalChat(false);
                    break;
            }
        }

        @Override
        public void onChannelMessageReceived(final ChannelMsg channelMsg, RtmChannelMember channelMember) {
            mChatroomFragment.addMessage(channelMsg);
        }

    };
    private View mLineWhiteboard;
    private View mLineChatroom;

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        initFragment();
        mFlChatroom = new FrameLayout(this);
        mFlWhiteboard = new FrameLayout(this);
        mFlShareVideo = new FrameLayout(this);

        mVideoItemStudent = new UserVideoItem(this);
        mVideoItemStudent.setVisibility(View.GONE);
        mVideoItemTeacher = new UserVideoItem(this);
        mVideoItemStudent.init(R.layout.item_user_video_mini_class, true);
        mVideoItemTeacher.init(R.layout.item_user_video_large_class_teacher, false);

        mFlChatroom.setId(View.generateViewId());
        mFlWhiteboard.setId(View.generateViewId());
        getSupportFragmentManager().beginTransaction()
                .add(mFlWhiteboard.getId(), mWhiteboardFragment)
                .add(mFlChatroom.getId(), mChatroomFragment)
                .commit();

        Configuration configuration = getResources().getConfiguration();
        if (configuration.orientation == Configuration.ORIENTATION_PORTRAIT) {
            initLayoutPortrait();
        } else {
            initLayoutLandscape();
        }

        Intent intent = getIntent();
        Student myAttr = new Student();
        myAttr.audio = 0;
        myAttr.video = 0;
        myAttr.chat = 1;
        myAttr.uid = intent.getIntExtra(IntentKey.USER_ID, 0);
        myAttr.account = intent.getStringExtra(IntentKey.YOUR_NAME);

        ChannelDataRepository repository = new ChannelDataRepository();
        repository.setMyAttr(myAttr);
        mImStrategy = new RtmStrategy(rtmManager(), mRtmEventListener);
        mImStrategy.setChannelDataRepository(repository);
        mChannelData = repository;

        mRtcDelegate = new RtcDelegate(rtcWorker(), mRtcHandler);
        mChatroomFragment.setImStrategy(mImStrategy);
        mWhiteboardFragment.setHandUpOperateListener(new WhiteboardFragment.HandUpOperateListener() {
            @Override
            public void onApply() {
                Teacher teacher = mChannelData.getTeacher();
                if (teacher == null) {
                    ToastUtil.showShort("老师不在房间，不能申请上麦！");
                    return;
                }
                String teacherUid = String.valueOf(teacher.getUid());
                mImStrategy.sendMessage(teacherUid, IMCmd.APPLY);
            }

            @Override
            public void onCancel() {
                Teacher teacher = mChannelData.getTeacher();
                if (teacher != null) {
                    String teacherUid = String.valueOf(teacher.getUid());
                    mImStrategy.sendMessage(teacherUid, IMCmd.CANCEL);
                }
                mRtcDelegate.changeRoleToAudience();
            }
        });

        String room = intent.getStringExtra(IntentKey.ROOM_NAME_REAL);
        mImStrategy.joinChannel(room);
        mRtcDelegate.joinChannel(room, myAttr);
    }

    private void updateShareVideoUI() {
        if (mFlShareVideo.getChildCount() > 0 && (mLineWhiteboard == null || mLineWhiteboard.getVisibility() == View.VISIBLE)) {
            mFlWhiteboard.setVisibility(View.INVISIBLE);
            mFlShareVideo.setVisibility(View.VISIBLE);
        } else if (mLineChatroom != null && mLineChatroom.getVisibility() == View.VISIBLE) {
            mFlShareVideo.setVisibility(View.INVISIBLE);
            mFlWhiteboard.setVisibility(View.INVISIBLE);
        } else {
            mFlShareVideo.setVisibility(View.INVISIBLE);
            mFlWhiteboard.setVisibility(View.VISIBLE);
        }
    }

    private void initCommonUI() {
        ViewGroup parentChatRoom = (ViewGroup) mFlChatroom.getParent();
        if (parentChatRoom != null) {
            parentChatRoom.removeAllViews();
        }
        ViewGroup parentWhiteboard = (ViewGroup) mFlWhiteboard.getParent();
        if (parentWhiteboard != null) {
            parentWhiteboard.removeAllViews();
        }

        ViewGroup parentShareVideo = (ViewGroup) mFlShareVideo.getParent();
        if (parentShareVideo != null) {
            parentShareVideo.removeAllViews();
        }

        ViewGroup parentStudentVideo = (ViewGroup) mVideoItemStudent.getParent();
        if (parentStudentVideo != null) {
            parentStudentVideo.removeAllViews();
        }

        ViewGroup parentTeacherVideo = (ViewGroup) mVideoItemTeacher.getParent();
        if (parentTeacherVideo != null) {
            parentTeacherVideo.removeAllViews();
        }

        mLayoutItemStudent = findViewById(R.id.layout_item_student);
        mLayoutItemTeacher = findViewById(R.id.layout_item_teacher);
        mLayoutShareVideo = findViewById(R.id.layout_share_video);
        mLayoutItemStudent.addView(mVideoItemStudent, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        mLayoutItemTeacher.addView(mVideoItemTeacher, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        mLayoutShareVideo.addView(mFlShareVideo, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

        updateRoomName();

        updateShareVideoUI();

        mIcExit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLeaveDialog();
            }
        });

        mVideoItemStudent.setOnClickAudioListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean isToMute = mVideoItemStudent.getIcAudioState() != SpeakerView.STATE_CLOSED;
                mVideoItemStudent.setIcAudioState(isToMute ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                muteLocalAudio(isToMute);
            }
        });

        mVideoItemStudent.setOnClickVideoListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean isToMute = mVideoItemStudent.isIcVideoSelected();
                mVideoItemStudent.setIcVideoSelect(!isToMute);
                muteLocalVideo(isToMute);
            }
        });
    }

    private void updateRoomName() {
        String room = getIntent().getStringExtra(IntentKey.ROOM_NAME);
        mTvRoomName.setText(room + "(" + roomUserCount + ")");
    }

    private void initFragment() {
        mWhiteboardFragment = WhiteboardFragment.newInstance(true);
        mChatroomFragment = ChatroomFragment.newInstance();
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
            initLayoutPortrait();
        } else {
            initLayoutLandscape();
        }
    }

    private void initLayoutLandscape() {
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_large_class_lanscape);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcExit = findViewById(R.id.ic_close);
        findViewById(R.id.time_view).setVisibility(View.GONE);
        mTvRoomName = findViewById(R.id.tv_room_name);

        mTvBtnChatroom = null;
        mTvBtnWhiteboard = null;
        mLineWhiteboard = null;
        mLineChatroom = null;

        initCommonUI();

        FrameLayout layoutWhiteboard = findViewById(R.id.layout_whiteboard);
        FrameLayout layoutChatroom = findViewById(R.id.layout_chatroom);
        layoutWhiteboard.addView(mFlWhiteboard);
        layoutChatroom.addView(mFlChatroom);
        mFlWhiteboard.setVisibility(View.VISIBLE);
        mFlChatroom.setVisibility(View.VISIBLE);
    }

    private void initLayoutPortrait() {
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_large_class_portrait);
        mTvRoomName = findViewById(R.id.tv_title_room);
        mIcExit = findViewById(R.id.ic_exit);

        mTvBtnWhiteboard = findViewById(R.id.tv_btn_whiteboard);
        mTvBtnChatroom = findViewById(R.id.tv_btn_chatroom);
        mLineWhiteboard = findViewById(R.id.line_whiteboard);
        mLineChatroom = findViewById(R.id.line_chatroom);

        initCommonUI();

        mTvBtnWhiteboard.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLineWhiteboard.setVisibility(View.VISIBLE);
                mLineChatroom.setVisibility(View.GONE);
                mFlChatroom.setVisibility(View.INVISIBLE);
                updateShareVideoUI();
            }
        });
        mTvBtnChatroom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLineChatroom.setVisibility(View.VISIBLE);
                mLineWhiteboard.setVisibility(View.GONE);
                mFlChatroom.setVisibility(View.VISIBLE);
                mFlWhiteboard.setVisibility(View.INVISIBLE);
                mFlShareVideo.setVisibility(View.GONE);
            }
        });
        mIcWifi = null;

        FrameLayout layoutChatroomWhitboard = findViewById(R.id.layout_whiteboard_chatroom);
        layoutChatroomWhitboard.addView(mFlChatroom);
        layoutChatroomWhitboard.addView(mFlWhiteboard);
        mFlWhiteboard.setVisibility(View.VISIBLE);
        mFlChatroom.setVisibility(View.GONE);
    }

    @Override
    public void finish() {
        mWhiteboardFragment.finishRoomPage();
        mImStrategy.leaveChannel();
        mRtcDelegate.leaveChannel();
        mImStrategy.release();
        mRtcDelegate.release();
        super.finish();
    }

    private void muteLocalAudio(boolean isMute) {
        mRtcDelegate.muteLocalAudio(isMute);
        mImStrategy.muteLocalAudio(isMute);
    }

    private void muteLocalVideo(boolean isMute) {
        mRtcDelegate.muteLocalVideo(isMute);
        mImStrategy.muteLocalVideo(isMute);
    }

    private void muteLocalChat(boolean isMute) {
        mImStrategy.muteLocalChat(isMute);
        mChatroomFragment.setEditTextEnable(!isMute);
    }

    @Override
    public void onBackPressed() {
        showLeaveDialog();
    }

    private void showLeaveDialog() {
        ConfirmDialogFragment.newInstance(new ConfirmDialogFragment.DialogClickListener() {
            @Override
            public void clickConfirm() {
                finish();
            }

            @Override
            public void clickCancel() {
            }
        }, getString(R.string.confirm_leave_room_content)).show(getSupportFragmentManager(), "leave");
    }

}
