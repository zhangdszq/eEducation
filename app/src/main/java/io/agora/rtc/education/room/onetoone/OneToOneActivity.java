package io.agora.rtc.education.room.onetoone;

import android.content.Intent;
import android.os.Bundle;
import android.view.SurfaceView;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

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
import io.agora.rtc.education.room.view.TimeView;
import io.agora.rtc.education.room.view.UserVideoItem;
import io.agora.rtc.education.widget.dialog.ConfirmDialogFragment;
import io.agora.rtc.lib.util.LogUtil;
import io.agora.rtc.lib.util.ToastUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.RtmChannelMember;

public class OneToOneActivity extends BaseActivity {

    private LogUtil log = new LogUtil("OneToOneActivity");
    private ImageView mIcWifi;
    private ImageView mIcClose;
    private TextView mTvRoomName;
    private TimeView mTimeView;
    private UserVideoItem mVideoItemTeacher;
    private UserVideoItem mVideoItemStudent;
    private RelativeLayout mLayoutChatRoom;

    private ChatroomFragment mChatroomFragment;
    private WhiteboardFragment mWhiteboardFragment;
    private RtmRepository mRtmRepository;
    private RtcDelegate mRtcDelegate;

    private IRtcEngineEventHandler mRtcHandler = new IRtcEngineEventHandler() {
        @Override
        public void onFirstLocalVideoFrame(int width, int height, int elapsed) {
            log.d("onFirstLocalVideoFrame");

        }

        @Override
        public void onRtcStats(RtcStats stats) {
        }

        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            log.i("join rtc success.");
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mVideoItemStudent.showVideo(true);
                }
            });
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
            final Teacher teacher = mRtmRepository.getTeacher();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
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
                        surfaceView = RtcEngine.CreateRendererView(OneToOneActivity.this);
                    }
                    mVideoItemTeacher.setVideoView(surfaceView);
                    mRtcDelegate.bindRemoteRtcVideo(teacher.uid, surfaceView);
                    mVideoItemTeacher.showVideo(teacher.video == 1);
                    mVideoItemTeacher.setIcVideoSelect(teacher.video == 1);
                    mVideoItemTeacher.setIcAudioState(teacher.audio == 0 ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                    mVideoItemTeacher.setName(teacher.account);
                    if (!mTimeView.isStarted() && teacher.class_state == 1) {
                        mTimeView.start();
                    } else if (mTimeView.isStarted() && teacher.class_state == 0) {
                        mTimeView.stop();
                    }

                    mChatroomFragment.setEditTextEnable(teacher.mute_chat != 1);
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

    private void muteLocalAudio(boolean isMute) {
        mRtcDelegate.muteLocalAudio(true);
        mRtmRepository.muteLocalAudio(true);
    }

    private void muteLocalVideo(boolean isMute) {
        mRtcDelegate.muteLocalVideo(true);
        mRtmRepository.muteLocalVideo(true);
    }

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_one_to_one);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcClose = findViewById(R.id.ic_close);
        mTvRoomName = findViewById(R.id.tv_room_name);
        mTimeView = findViewById(R.id.time_view);
        mVideoItemTeacher = findViewById(R.id.video_item_teacher);
        mVideoItemStudent = findViewById(R.id.video_item_student);
        mVideoItemTeacher.init(R.layout.item_user_video_one_to_one, false);
        mVideoItemStudent.init(R.layout.item_user_video_one_to_one, true);
        mLayoutChatRoom = findViewById(R.id.layout_chat_room);

        mChatroomFragment = ChatroomFragment.newInstance();
        mWhiteboardFragment = WhiteboardFragment.newInstance(false);
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.fl_chat_room, mChatroomFragment)
                .add(R.id.layout_whiteboard, mWhiteboardFragment)
                .commit();

        mIcClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLeaveDialog();
            }
        });

        mTvRoomName.setText(getIntent().getStringExtra(IntentKey.ROOM_NAME));

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

        mVideoItemStudent.setIcVideoSelect(true);
        mVideoItemStudent.setIcAudioState(SpeakerView.STATE_OPENED);
        mVideoItemStudent.setName(getIntent().getStringExtra(IntentKey.YOUR_NAME));
    }

    @Override
    protected void initData() {
        Intent intent = getIntent();
        Student myAttr = new Student();
        myAttr.audio = 1;
        myAttr.video = 1;
        myAttr.uid = intent.getIntExtra(IntentKey.USER_ID, 0);
        myAttr.account = intent.getStringExtra(IntentKey.YOUR_NAME);

        mRtmRepository = new RtmRepository(rtmManager(), mRtmEventListener, myAttr);
        mRtcDelegate = new RtcDelegate(rtcWorker(), mRtcHandler);

        mChatroomFragment.setRtmRepository(mRtmRepository);
        SurfaceView surfaceView = RtcEngine.CreateRendererView(this);
        mRtcDelegate.bindLocalRtcVideo(surfaceView);
        mVideoItemStudent.setVideoView(surfaceView);

        String room = intent.getStringExtra(IntentKey.ROOM_NAME_REAL);
        mRtmRepository.joinChannel(room);
        mRtcDelegate.joinChannel(room, myAttr);
    }

    @Override
    public void finish() {
        mWhiteboardFragment.finishRoomPage();
        mRtmRepository.leaveChannel();
        mRtcDelegate.leaveChannel();
        super.finish();
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

    public void onClickShowChat(View view) {
        view.setSelected(!view.isSelected());
        mLayoutChatRoom.setVisibility(view.isSelected() ? View.GONE : View.VISIBLE);
    }
}
