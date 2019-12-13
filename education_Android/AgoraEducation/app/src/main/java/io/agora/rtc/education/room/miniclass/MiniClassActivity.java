package io.agora.rtc.education.room.miniclass;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.FragmentTransaction;

import java.util.ArrayList;

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
import io.agora.rtc.education.data.bean.User;
import io.agora.rtc.education.im.ChannelMsg;
import io.agora.rtc.education.im.IMCmd;
import io.agora.rtc.education.im.IMStrategy;
import io.agora.rtc.education.im.P2PMessage;
import io.agora.rtc.education.im.rtm.RtmStrategy;
import io.agora.rtc.education.room.fragment.ChatroomFragment;
import io.agora.rtc.education.room.fragment.StudentListFrament;
import io.agora.rtc.education.room.fragment.WhiteboardFragment;
import io.agora.rtc.education.room.view.TimeView;
import io.agora.rtc.education.widget.dialog.ConfirmDialogFragment;
import io.agora.rtc.lib.util.LogUtil;
import io.agora.rtc.lib.util.ToastUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.RtmChannelMember;

public class MiniClassActivity extends BaseActivity {

    private LogUtil log = new LogUtil("MiniClassActivity");
    private ImageView mIcWifi;
    private ImageView mIcClose;
    private TextView mTvRoomName;
    private TimeView mTimeView;
    private ListView mLvVideos;
    private View mLine1;
    private View mLine2;
    private FrameLayout mFlChatRoom;
    private ConstraintLayout mLayoutIm;
    private FrameLayout mLayoutWhiteboard;
    private TextView mTvBtnChatRoom;
    private TextView mTvBtnStudent;
    private FrameLayout mLayoutShareVideo;

    private WhiteboardFragment mWhiteboardFragment;
    private ChatroomFragment mChatroomFragment;
    private StudentListFrament mStudentListFrament;

    private VideoItemAdapter mAdapter;
    private RtcDelegate mRtcDelegate;
    private IMStrategy mImStrategy;
    private ChannelDataReadOnly mChannelData;

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
                        mLayoutWhiteboard.setVisibility(View.INVISIBLE);
                        if (mLayoutShareVideo.getVisibility() != View.VISIBLE) {
                            mLayoutShareVideo.setVisibility(View.VISIBLE);
                        }

                        mLayoutShareVideo.removeAllViews();
                        SurfaceView surfaceView = RtcEngine.CreateRendererView(MiniClassActivity.this);
                        mLayoutShareVideo.addView(surfaceView, ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                        mRtcDelegate.bindRemoteRtcVideo(uid, surfaceView);
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
                        mLayoutShareVideo.removeAllViews();
                        mLayoutShareVideo.setVisibility(View.GONE);
                        mLayoutWhiteboard.setVisibility(View.VISIBLE);
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
        public void onMemberLeft(RtmChannelMember rtmChannelMember) {
            if (rtmChannelMember != null && rtmChannelMember.getUserId() != null
                    && mChannelData.getTeacher() != null
                    && rtmChannelMember.getUserId().equals(String.valueOf(mChannelData.getTeacher().uid))) {
                mWhiteboardFragment.finishRoomPage();
            }
        }

        @Override
        public void onChannelAttributesUpdated() {
            final ArrayList<User> users = new ArrayList<>();

            Teacher teacher = mChannelData.getTeacher();
            if (teacher != null) {
                users.add(teacher);
            }
            ArrayList<Student> students = mChannelData.getStudents();
            if (students != null && !students.isEmpty()) {
                users.addAll(students);
            }
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (users.isEmpty() || !(users.get(0) instanceof Teacher)) {
                        ToastUtil.showShort(R.string.There_is_no_teacher_in_this_classroom);
                        mChatroomFragment.setEditTextEnable(true);
                    } else {
                        Teacher teacher = (Teacher) users.get(0);
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

                        if (!mTimeView.isStarted() && teacher.class_state == 1) {
                            mTimeView.start();
                        } else if (mTimeView.isStarted() && teacher.class_state == 0) {
                            mTimeView.stop();
                        }

                        mChatroomFragment.setEditTextEnable(teacher.mute_chat != 1);
                    }

                    mAdapter.setList(users);
                    mAdapter.notifyDataSetChanged();
                    mStudentListFrament.setList(users);
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

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_mini_class);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcClose = findViewById(R.id.ic_close);
        mTvRoomName = findViewById(R.id.tv_room_name);
        mTimeView = findViewById(R.id.time_view);
        mLvVideos = findViewById(R.id.lv_videos);
        mLine1 = findViewById(R.id.line_1);
        mLine2 = findViewById(R.id.line_2);
        mFlChatRoom = findViewById(R.id.fl_chat_room);
        mLayoutIm = findViewById(R.id.layout_im);
        mLayoutWhiteboard = findViewById(R.id.layout_whiteboard);
        mTvBtnChatRoom = findViewById(R.id.tv_btn_chat_room);
        mTvBtnStudent = findViewById(R.id.tv_btn_student);
        mLayoutShareVideo = findViewById(R.id.layout_share_video);

        mTvRoomName.setText(getIntent().getStringExtra(IntentKey.ROOM_NAME));
        mIcClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showLeaveDialog();
            }
        });
    }

    @Override
    protected void initData() {
        mWhiteboardFragment = WhiteboardFragment.newInstance(false);
        mStudentListFrament = StudentListFrament.newInstance();
        mChatroomFragment = ChatroomFragment.newInstance();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.layout_whiteboard, mWhiteboardFragment)
                .add(R.id.fl_chat_room, mChatroomFragment)
                .add(R.id.fl_chat_room, mStudentListFrament)
                .hide(mStudentListFrament)
                .show(mChatroomFragment)
                .commit();


        Intent intent = getIntent();
        Student myAttr = new Student();
        myAttr.audio = 1;
        myAttr.video = 1;
        myAttr.uid = intent.getIntExtra(IntentKey.USER_ID, 0);
        myAttr.account = intent.getStringExtra(IntentKey.YOUR_NAME);

        ChannelDataRepository repository = new ChannelDataRepository();
        repository.setMyAttr(myAttr);
        mImStrategy = new RtmStrategy(rtmManager(), mRtmEventListener);
        mImStrategy.setChannelDataRepository(repository);
        mChannelData = repository;

        mRtcDelegate = new RtcDelegate(rtcWorker(), mRtcHandler);

        mChatroomFragment.setImStrategy(mImStrategy);
        mStudentListFrament.setImStrategy(mImStrategy);
        mStudentListFrament.setMyUid(mChannelData.getMyAttr().uid);

        String room = intent.getStringExtra(IntentKey.ROOM_NAME_REAL);
        mImStrategy.joinChannel(room);
        mRtcDelegate.joinChannel(room, myAttr);

        this.mAdapter = new VideoItemAdapter(myAttr.uid);
        mLvVideos.setAdapter(mAdapter);
    }

    private void showChatRoom(boolean isShow) {
        mLine1.setVisibility(isShow ? View.VISIBLE : View.INVISIBLE);
        mLine2.setVisibility(isShow ? View.INVISIBLE : View.VISIBLE);
        mTvBtnChatRoom.setSelected(isShow);
        mTvBtnStudent.setSelected(!isShow);
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.hide(mStudentListFrament).hide(mChatroomFragment)
                .show(isShow ? mChatroomFragment : mStudentListFrament).commit();
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

    @Override
    public void finish() {
        mWhiteboardFragment.finishRoomPage();
        mImStrategy.leaveChannel();
        mRtcDelegate.leaveChannel();
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

    public void onClickShowChat(View view) {
        view.setSelected(!view.isSelected());
        mLayoutIm.setVisibility(view.isSelected() ? View.GONE : View.VISIBLE);
    }

    public void onClickTabChatRoom(View view) {
        showChatRoom(true);
    }

    public void onClickTabStudent(View view) {
        showChatRoom(false);
    }
}
