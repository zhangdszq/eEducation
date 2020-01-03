package io.agora.rtc.education.room.onetoone;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

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
    private FrameLayout mLayoutShareVideo;
    private FrameLayout mLayoutWhiteboard;

    private ChatroomFragment mChatroomFragment;
    private WhiteboardFragment mWhiteboardFragment;
    private IMStrategy mImStrategy;
    private ChannelDataReadOnly mChannelData;
    private RtcDelegate mRtcDelegate;

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
                runOnUiThread(() -> {
                    int uid1 = Constant.SHARE_UID;
                    mLayoutWhiteboard.setVisibility(View.INVISIBLE);
                    if (mLayoutShareVideo.getVisibility() != View.VISIBLE) {
                        mLayoutShareVideo.setVisibility(View.VISIBLE);
                    }

                    mLayoutShareVideo.removeAllViews();
                    SurfaceView surfaceView = RtcEngine.CreateRendererView(OneToOneActivity.this);
                    mLayoutShareVideo.addView(surfaceView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                    mRtcDelegate.bindRemoteRtcVideoFitMode(uid1, surfaceView);
                });
            }
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            if (uid == Constant.SHARE_UID) {
                runOnUiThread(() -> {
                    mLayoutShareVideo.removeAllViews();
                    mLayoutShareVideo.setVisibility(View.GONE);
                    mLayoutWhiteboard.setVisibility(View.VISIBLE);
                });
            }
        }

        @Override
        public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
            log.i("join rtc success.");
            runOnUiThread(() -> mVideoItemStudent.showVideo(true));
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
        public void onMemberLeft(RtmChannelMember rtmChannelMember) {
            if (rtmChannelMember != null && rtmChannelMember.getUserId() != null
                    && mChannelData.getTeacher() != null
                    && rtmChannelMember.getUserId().equals(String.valueOf(mChannelData.getTeacher().uid))) {
                runOnUiThread(() -> mWhiteboardFragment.finishRoomPage());
            }
        }

        @Override
        public void onChannelAttributesUpdated() {
            final Teacher teacher = mChannelData.getTeacher();
            runOnUiThread(() -> {
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
                    surfaceView = RtcEngine.CreateRendererView(OneToOneActivity.this);
                    surfaceView.setTag(teacher.uid);
                    mVideoItemTeacher.setVideoView(surfaceView);
                    mRtcDelegate.bindRemoteRtcVideo(teacher.uid, surfaceView);
                }
                mVideoItemTeacher.showVideo(teacher.video == 1);
                mVideoItemTeacher.setIcVideoSelect(teacher.video == 1);
                mVideoItemTeacher.setIcAudioState(teacher.audio == 0 ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
                mVideoItemTeacher.setName(teacher.account);
                if (!mTimeView.isStarted() && teacher.class_state == 1) {
                    mTimeView.start();
                } else if (mTimeView.isStarted() && teacher.class_state == 0) {
                    mTimeView.stop();
                }

                mChatroomFragment.setEditTextEnable(teacher.mute_chat != 1 && mChannelData.getMyAttr().chat == 1);
            });
        }

        @Override
        public void onMessageReceived(P2PMessage p2PMessage, String peerId) {
            final int cmd = p2PMessage.cmd;
            runOnUiThread(() -> {
                switch (cmd) {
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
                    case IMCmd.MUTE_CHAT:
                        muteLocalChat(true);
                        break;
                    case IMCmd.UNMUTE_CAHT:
                        muteLocalChat(false);
                        break;
                }
            });

        }

        @Override
        public void onChannelMessageReceived(final ChannelMsg channelMsg, RtmChannelMember channelMember) {
            mChatroomFragment.addMessage(channelMsg);
        }
    };

    private void muteLocalAudio(boolean isMute) {
        mRtcDelegate.muteLocalAudio(isMute);
        mImStrategy.muteLocalAudio(isMute);
        mVideoItemStudent.setIcAudioState(isMute ? SpeakerView.STATE_CLOSED : SpeakerView.STATE_OPENED);
    }

    private void muteLocalVideo(boolean isMute) {
        mRtcDelegate.muteLocalVideo(isMute);
        mImStrategy.muteLocalVideo(isMute);
        mVideoItemStudent.showVideo(!isMute);
        mVideoItemStudent.setIcVideoSelect(!isMute);
    }

    private void muteLocalChat(boolean isMute) {
        mImStrategy.muteLocalChat(isMute);
        mChatroomFragment.setEditTextEnable(!isMute);
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
        mLayoutShareVideo = findViewById(R.id.layout_share_video);
        mLayoutWhiteboard = findViewById(R.id.layout_whiteboard);

        mChatroomFragment = ChatroomFragment.newInstance();
        mWhiteboardFragment = WhiteboardFragment.newInstance(false);
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.fl_chat_room, mChatroomFragment)
                .add(R.id.layout_whiteboard, mWhiteboardFragment)
                .commit();

        mIcClose.setOnClickListener(v -> showLeaveDialog());

        mTvRoomName.setText(getIntent().getStringExtra(IntentKey.ROOM_NAME));

        mVideoItemStudent.setOnClickAudioListener(v -> muteLocalAudio(mVideoItemStudent.getIcAudioState() != SpeakerView.STATE_CLOSED));

        mVideoItemStudent.setOnClickVideoListener(v -> muteLocalVideo(mVideoItemStudent.isIcVideoSelected()));

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
        SurfaceView surfaceView = RtcEngine.CreateRendererView(this);
        mRtcDelegate.bindLocalRtcVideo(surfaceView);
        mVideoItemStudent.setVideoView(surfaceView);

        String room = intent.getStringExtra(IntentKey.ROOM_NAME_REAL);
        mImStrategy.joinChannel(room);
        mRtcDelegate.joinChannel(room, myAttr);
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

    public void onClickShowChat(View view) {
        view.setSelected(!view.isSelected());
        mLayoutChatRoom.setVisibility(view.isSelected() ? View.GONE : View.VISIBLE);
    }

}
