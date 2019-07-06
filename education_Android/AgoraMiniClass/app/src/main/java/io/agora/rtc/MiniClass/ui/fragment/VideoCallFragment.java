package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.MuteEvent;
import io.agora.rtc.MiniClass.model.event.UpdateMembersEvent;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.MiniClass.ui.adapter.RcvStudentVideoListAdapter;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;


public class VideoCallFragment extends BaseFragment {

    final LogUtil log = new LogUtil("VideoCallFragment");

    private RecyclerView mRcvStudentVideoList;
    private RcvStudentVideoListAdapter mRcvAdapter;
    private FrameLayout mFlTeacherVideo, mFlStudentVideoList;
    private TextView mTvTeacherName;
    private ImageView mIvBgTeacher;

    public static VideoCallFragment newInstance() {
        VideoCallFragment fragment = new VideoCallFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_video_call, container, false);

        mFlTeacherVideo = root.findViewById(R.id.fl_video_teacher);
        mFlStudentVideoList = root.findViewById(R.id.fl_student_video_list);
        mTvTeacherName = root.findViewById(R.id.tv_name_teacher);
        mIvBgTeacher = root.findViewById(R.id.iv_bg_teacher);
        initStudentsLayout(root);

        initAgoraRTC();

        return root;
    }

    private void initAgoraRTC() {
        workerThread().setRtcEventHandler(new IRtcEngineEventHandler() {
            @Override
            public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
                super.onJoinChannelSuccess(channel, uid, elapsed);
                log.d("join rtc success");
            }

            @Override
            public void onUserJoined(int uid, int elapsed) {
                super.onUserJoined(uid, elapsed);
                log.d("onUserJoined:" + (uid & 0xFFFFFFFFL));
            }

            @Override
            public void onUserOffline(int uid, int reason) {
                super.onUserOffline(uid, reason);
                log.d("onUserOffline:" + (uid & 0xFFFFFFFFL));
            }
        });

        int rtcRole;
        Constant.Role role = UserConfig.getRole();

        if (role == Constant.Role.TEACHER) {
            rtcRole = Constants.CLIENT_ROLE_BROADCASTER;
        } else if (role == Constant.Role.STUDENT) {
            rtcRole = Constants.CLIENT_ROLE_BROADCASTER;
        } else {
            rtcRole = Constants.CLIENT_ROLE_AUDIENCE;
        }

        workerThread().joinChannel(rtcRole, UserConfig.getRtcChannelName(), UserConfig.getRtcUserId(), null);
    }

    private void initStudentsLayout(final View root) {
        mRcvStudentVideoList = root.findViewById(R.id.rcv_student_list_video);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager((Context) mListener, LinearLayoutManager.HORIZONTAL, true);
//        linearLayoutManager.setStackFromEnd(true);
        mRcvStudentVideoList.setLayoutManager(linearLayoutManager);
        mRcvAdapter = new RcvStudentVideoListAdapter();
        mRcvStudentVideoList.setAdapter(mRcvAdapter);
    }

    private void updateTeacher(RtmRoomControl.UserAttr teacherAttr) {
        if (mListener == null || teacherAttr == null || TextUtils.isEmpty(teacherAttr.streamId)) {
            mFlTeacherVideo.removeAllViews();
            mIvBgTeacher.setVisibility(View.VISIBLE);
            return;
        }

        mIvBgTeacher.setVisibility(View.GONE);
        SurfaceView teacherView = RtcEngine.CreateRendererView((Context) mListener);
        int teacherUid = Integer.parseInt(teacherAttr.streamId);

        if (teacherUid == UserConfig.getRtcUserId()) {
            rtcEngine().setupLocalVideo(new VideoCanvas(teacherView));
        } else {
            rtcEngine().setupRemoteVideo(new VideoCanvas(teacherView, Constants.RENDER_MODE_HIDDEN, teacherUid));
        }

        teacherView.setZOrderMediaOverlay(true);
        mFlTeacherVideo.removeAllViews();
        mFlTeacherVideo.addView(teacherView);
        mTvTeacherName.setText(teacherAttr.name);
    }

    @Override
    public void onActivityEvent(BaseEvent event) {
        if (event instanceof UpdateMembersEvent) {
            UpdateMembersEvent updateMembersEvent = (UpdateMembersEvent) event;

            log.i("updateMembers");
            updateTeacher(updateMembersEvent.getTeacherAttr());
            if (mRcvAdapter == null)
                return;

            mRcvAdapter.setList(updateMembersEvent.getUserAttrList());
            mRcvAdapter.notifyDataSetChanged();

            RtmRoomControl.UserAttr myAttr = UserConfig.getUserAttrByUserId(UserConfig.getRtmUserId());
            if (myAttr != null) {
                rtcEngine().muteLocalVideoStream(myAttr.isMuteVideo);
                rtcEngine().muteLocalAudioStream(myAttr.isMuteAudio);
            }
        } else if (event instanceof Event) {
            switch (event.getEventType()) {
                case Event.EVENT_TYPE_MAX:
                    mFlStudentVideoList.setVisibility(View.GONE);
                    break;
                case Event.EVENT_TYPE_MIN:
                    mFlStudentVideoList.setVisibility(View.VISIBLE);
                    break;
            }
        } else if (event instanceof MuteEvent) {
            MuteEvent muteEvent = (MuteEvent) event;
            RtmRoomControl.UserAttr attr = muteEvent.getUserAttr();
            RtmRoomControl.UserAttr attr1 = mRcvAdapter.getList().get(0);
            log.i("attr:" + attr.hashCode() + ", attr1:" + attr1.hashCode());
            if (attr != null) {
                mRcvAdapter.updateItemById(attr.streamId, attr);
            }
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        rtcEngine().startPreview();
    }

    @Override
    public void onPause() {
        super.onPause();
        rtcEngine().stopPreview();
    }

    public static class Event extends BaseEvent {

        public static final int EVENT_TYPE_MIN = 104;
        public static final int EVENT_TYPE_MAX = 105;

        public Event(int eventType) {
            super(eventType);
        }
    }
}
