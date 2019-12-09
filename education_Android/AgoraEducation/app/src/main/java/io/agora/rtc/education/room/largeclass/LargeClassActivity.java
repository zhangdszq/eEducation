package io.agora.rtc.education.room.largeclass;

import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.room.bean.Student;
import io.agora.rtc.education.room.bean.Teacher;
import io.agora.rtc.education.room.fragment.ChatroomFragment;
import io.agora.rtc.education.room.fragment.WhiteboardFragment;
import io.agora.rtc.education.room.rtm.ChannelMsg;
import io.agora.rtc.education.room.rtm.MyRtmMessage;
import io.agora.rtc.education.room.rtm.RtmCmd;
import io.agora.rtc.education.room.rtm.RtmRepository;
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
    private UserVideoItem mVideoItemStudent;
    private UserVideoItem mVideoItemTeacher;
    private ImageView mIcExit;
    private TextView mTvRoomName;

    //portrait
    private TextView mTvBtnWhiteboard;
    private TextView mTvBtnChatroom;

    //landscape
    private ImageView mIcWifi;

    private WhiteboardFragment mWhiteboardFragment;
    private ChatroomFragment mChatroomFragment;

    private boolean isLandscape;
    private RtmRepository mRtmRepository;
    private RtcDelegate mRtcDelegate;

    private FrameLayout mFlWhiteboard;
    private FrameLayout mFlChatroom;

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
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            log.i("join rtc success.");
        }
    };

    private RtmRepository.EventListener mRtmEventListener = new RtmRepository.EventListener() {
        @Override
        public void onJoinRtmChannelFailure(ErrorInfo errorInfo) {
            log.e("join rtm failed" + errorInfo);
        }

        @Override
        public void onJoinRtmChannelSuccess() {
            log.i("join rtm success");
        }

        @Override
        public void onAttributesUpdated() {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Teacher teacher = mRtmRepository.getTeacher();
                    if (teacher == null) {
                        ToastUtil.showShort(R.string.There_is_no_teacher_in_this_classroom);
                        mChatroomFragment.setEditTextEnable(true);
                        return;
                    }
                    if (mWhiteboardFragment.getUuid() == null) {
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
                    if (surfaceView == null) {
                        surfaceView = RtcEngine.CreateRendererView(LargeClassActivity.this);
                    }
                    mVideoItemTeacher.setVideoView(surfaceView);
                    mRtcDelegate.bindRemoteRtcVideo(teacher.uid, surfaceView);
                    mVideoItemTeacher.showVideo(teacher.video == 1);
                    mVideoItemTeacher.setIcVideoSelect(teacher.video == 1);
                    mVideoItemTeacher.setIcAudioState(teacher.audio == 0 ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                    mVideoItemTeacher.setName(teacher.account);

                    mChatroomFragment.setEditTextEnable(teacher.mute_chat != 1);

                    if (teacher.link_uid != 0) {
                        int linkUid = teacher.link_uid;
                        Student student = mRtmRepository.getStudent(linkUid);
                        if (student != null) {
                            mVideoItemStudent.setVisibility(View.VISIBLE);

                            mVideoItemStudent.setVideoView(surfaceView);
                            if (mRtmRepository.myAttr().uid == linkUid) {
                                mRtcDelegate.bindLocalRtcVideo(surfaceView);
                            } else {
                                mRtcDelegate.bindRemoteRtcVideo(linkUid, surfaceView);
                            }
                            mVideoItemStudent.showVideo(student.video == 1);
                            mVideoItemStudent.setIcVideoSelect(student.video == 1);
                            mVideoItemStudent.setIcAudioState(student.audio == 0 ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                            mVideoItemStudent.setName(student.account);
                        }
                    }
                }
            });
        }

        @Override
        public void onMessageReceived(MyRtmMessage myRtmMessage, String peerId) {
            switch (myRtmMessage.cmd) {
                case RtmCmd.MUTE_AUDIO:
                    muteLocalAudio(true);
                    break;
                case RtmCmd.UNMUTE_AUDIO:
                    muteLocalAudio(false);
                    break;
                case RtmCmd.MUTE_VIDEO:
                    muteLocalVideo(true);
                    break;
                case RtmCmd.UNMUTE_VIDEO:
                    muteLocalVideo(false);
                    break;
            }
        }

        @Override
        public void onChannelMessageReceived(final ChannelMsg channelMsg, RtmChannelMember channelMember) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mChatroomFragment.addMessage(channelMsg);
                }
            });
        }
    };
    private View mLineWhiteboard;
    private View mLineChatroom;

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        initFragment();
        mFlChatroom = new FrameLayout(this);
        mFlWhiteboard = new FrameLayout(this);

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
        myAttr.uid = intent.getIntExtra(IntentKey.USER_ID, 0);
        myAttr.account = intent.getStringExtra(IntentKey.YOUR_NAME);

        mRtmRepository = new RtmRepository(rtmManager(), mRtmEventListener, myAttr);
        mRtcDelegate = new RtcDelegate(rtcWorker(), mRtcHandler);
        mChatroomFragment.setRtmRepository(mRtmRepository);

        String room = intent.getStringExtra(IntentKey.ROOM_NAME_REAL);
        mRtmRepository.joinChannel(room);
        mRtcDelegate.joinChannel(room, myAttr);
    }

    private void initCommonUI() {
        mVideoItemStudent = findViewById(R.id.video_item_student);
        mVideoItemTeacher = findViewById(R.id.video_item_teacher);
        mVideoItemStudent.init(R.layout.item_user_video_mini_class, true);
        mVideoItemTeacher.init(R.layout.item_user_video_large_class_teacher, false);

        String room = getIntent().getStringExtra(IntentKey.ROOM_NAME);
        mTvRoomName.setText(room);

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
        isLandscape = true;
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_large_class_lanscape);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcExit = findViewById(R.id.ic_close);
        findViewById(R.id.time_view).setVisibility(View.GONE);
        mTvRoomName = findViewById(R.id.tv_room_name);
        initCommonUI();

        mTvBtnChatroom = null;
        mTvBtnWhiteboard = null;
        mLineWhiteboard = null;
        mLineChatroom = null;

        ViewGroup parentChatroom = (ViewGroup) mFlChatroom.getParent();
        if (parentChatroom != null) {
            parentChatroom.removeAllViews();
        }
        ViewGroup parentWhiteboard = (ViewGroup) mFlWhiteboard.getParent();
        if (parentWhiteboard != null) {
            parentWhiteboard.removeAllViews();
        }
        FrameLayout layoutWhiteboard = findViewById(R.id.layout_whiteboard);
        FrameLayout layoutChatroom = findViewById(R.id.layout_chatroom);
        layoutWhiteboard.addView(mFlWhiteboard);
        layoutChatroom.addView(mFlChatroom);
        mFlWhiteboard.setVisibility(View.VISIBLE);
        mFlChatroom.setVisibility(View.VISIBLE);
    }

    private void initLayoutPortrait() {
        isLandscape = false;
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_large_class_portrait);
        mTvRoomName = findViewById(R.id.tv_title_room);
        mIcExit = findViewById(R.id.ic_exit);

        initCommonUI();

        mTvBtnWhiteboard = findViewById(R.id.tv_btn_whiteboard);
        mTvBtnChatroom = findViewById(R.id.tv_btn_chatroom);
        mLineWhiteboard = findViewById(R.id.line_whiteboard);
        mLineChatroom = findViewById(R.id.line_chatroom);

        mTvBtnWhiteboard.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLineWhiteboard.setVisibility(View.VISIBLE);
                mLineChatroom.setVisibility(View.GONE);
                mFlChatroom.setVisibility(View.INVISIBLE);
                mFlWhiteboard.setVisibility(View.VISIBLE);
            }
        });
        mTvBtnChatroom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLineChatroom.setVisibility(View.VISIBLE);
                mLineWhiteboard.setVisibility(View.GONE);
                mFlChatroom.setVisibility(View.VISIBLE);
                mFlWhiteboard.setVisibility(View.INVISIBLE);
            }
        });
        mIcWifi = null;

        ViewGroup parentChatroom = (ViewGroup) mFlChatroom.getParent();
        if (parentChatroom != null) {
            parentChatroom.removeAllViews();
        }
        ViewGroup parentWhiteboard = (ViewGroup) mFlWhiteboard.getParent();
        if (parentWhiteboard != null) {
            parentWhiteboard.removeAllViews();
        }
        FrameLayout layoutChatroomWhitboard = findViewById(R.id.layout_whiteboard_chatroom);
        layoutChatroomWhitboard.addView(mFlChatroom);
        layoutChatroomWhitboard.addView(mFlWhiteboard);
        mFlWhiteboard.setVisibility(View.VISIBLE);
        mFlChatroom.setVisibility(View.GONE);
    }

    @Override
    public void finish() {
        mWhiteboardFragment.finishRoomPage();
        mRtmRepository.leaveChannel();
        mRtcDelegate.leaveChannel();
        super.finish();
    }

    private void muteLocalAudio(boolean isMute) {
        mRtcDelegate.muteLocalAudio(true);
        mRtmRepository.muteLocalAudio(true);
    }

    private void muteLocalVideo(boolean isMute) {
        mRtcDelegate.muteLocalVideo(true);
        mRtmRepository.muteLocalVideo(true);
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
        }, getString(R.string.confirm_leave_room_content))
                .show(getSupportFragmentManager(), "leave");
    }

}
