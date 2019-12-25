package io.agora.rtc.education.room.miniclass;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

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
    private RecyclerView mRcvVideos;
    private View mLine1;
    private View mLine2;
    private ConstraintLayout mLayoutIm;
    private FrameLayout mLayoutWhiteboard;
    private TextView mTvBtnChatRoom;
    private TextView mTvBtnStudent;
    private FrameLayout mLayoutShareVideo;

    private WhiteboardFragment mWhiteboardFragment;
    private ChatroomFragment mChatroomFragment;
    private StudentListFrament mStudentListFrament;

    private VideoItemRcvAdapter mAdapter;
    private RtcDelegate mRtcDelegate;
    private IMStrategy mImStrategy;
    private ChannelDataReadOnly mChannelData;
    private List<Integer> uidList = new ArrayList<>();

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
                        mRtcDelegate.bindRemoteRtcVideoFitMode(uid, surfaceView);
                    }
                });
            } else {
                uidList.add(uid);
                refreshVideoItemRcvAdapter();
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
            } else {
                uidList.remove(Integer.valueOf(uid));
                refreshVideoItemRcvAdapter();
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
            refreshBoard();
            refreshVideoItemRcvAdapter();
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

    private void refreshBoard() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Teacher teacher = mChannelData.getTeacher();
                if (teacher == null) {
                    ToastUtil.showShort(R.string.There_is_no_teacher_in_this_classroom);
                    mChatroomFragment.setEditTextEnable(true);
                } else {
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

                    mChatroomFragment.setEditTextEnable(teacher.mute_chat != 1 && mChannelData.getMyAttr().chat == 1);
                }
            }
        });
    }

    private void refreshVideoItemRcvAdapter() {
        final ArrayList<User> users = new ArrayList<>();
        Teacher teacher = mChannelData.getTeacher();
        if (teacher != null) {
            if (uidList.contains(teacher.uid)) {
                users.add(teacher);
            }
        }
        ArrayList<Student> students = mChannelData.getStudents();
        if (students != null) {
            for (Student student : students) {
                if (uidList.contains(student.uid)) {
                    users.add(student);
                } else if (student.uid == getIntent().getIntExtra(IntentKey.USER_ID, 0)) {
                    users.add(student);
                }
            }
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                List<Integer> updatePositions = checkoutUpdatePositions(users, mAdapter.getList());
                mAdapter.setList(users);

                if (updatePositions == null) {
                    mAdapter.notifyDataSetChanged();
                } else {
                    for (int i : updatePositions) {
                        mAdapter.notifyItemChanged(i, new byte[0]);
                    }
                }
                mStudentListFrament.setList(users);
            }
        });
    }

    private List<Integer> checkoutUpdatePositions(ArrayList<User> users1, List<User> users2) {
        if (users1 == null || users2 == null || users1.size() != users2.size()) {
            return null;
        }
        List<Integer> integers = new LinkedList<>();
        for (int i = 0; i < users1.size(); i++) {
            User user1 = users1.get(i);
            User user2 = users2.get(i);
            if (user1.getUid() != user2.getUid()) {
                return null;
            }
            if (user1.account == null) {
                user1.account = "";
            }
            if (user2.account == null) {
                user2.account = "";
            }
            if (!user1.account.equals(user2.account) || user1.audio != user2.audio || user1.video != user2.video) {
                integers.add(i);
            }
        }
        return integers;
    }

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_mini_class);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcClose = findViewById(R.id.ic_close);
        mTvRoomName = findViewById(R.id.tv_room_name);
        mTimeView = findViewById(R.id.time_view);
        mRcvVideos = findViewById(R.id.rcv_videos);
        mLine1 = findViewById(R.id.line_1);
        mLine2 = findViewById(R.id.line_2);
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
        mStudentListFrament.setImStrategy(mImStrategy);
        mStudentListFrament.setMyUid(myAttr.uid);

        String room = intent.getStringExtra(IntentKey.ROOM_NAME_REAL);
        mImStrategy.joinChannel(room);
        mRtcDelegate.joinChannel(room, myAttr);

        mAdapter = new VideoItemRcvAdapter(myAttr.uid);
        LinearLayoutManager layoutManager = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        mRcvVideos.setLayoutManager(layoutManager);
        mRcvVideos.setAdapter(mAdapter);
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
        }, getString(R.string.confirm_leave_room_content)).show(getSupportFragmentManager(), "leave");
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
