package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.constraint.ConstraintLayout;
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
import io.agora.rtc.MiniClass.model.bean.Mute;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.MuteEvent;
import io.agora.rtc.MiniClass.model.event.UpdateMembersEvent;
import io.agora.rtc.MiniClass.model.util.LogUtil;
import io.agora.rtc.MiniClass.ui.activity.MiniClassActivity;
import io.agora.rtc.MiniClass.ui.adapter.RcvStudentVideoListAdapter;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;


public class VideoCallFragment extends BaseFragment {

    final LogUtil log = new LogUtil("VideoCallFragment");

    private RecyclerView mRcvStudentVideoList;
    private RcvStudentVideoListAdapter mRcvAdapter;
    private FrameLayout mFlTeacherVideo, mFlStudentVideoList, mFlTeacherVideoLayout;
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
        mFlTeacherVideoLayout = root.findViewById(R.id.fl_video_teacher_layout);
        mFlStudentVideoList = root.findViewById(R.id.fl_student_video_list);
        mTvTeacherName = root.findViewById(R.id.tv_name_teacher);
        mIvBgTeacher = root.findViewById(R.id.iv_bg_teacher);
        initStudentsLayout(root);

        initAgoraRTC();

        return root;
    }

    private void initAgoraRTC() {
        rtcWorkerThread().setRtcEventHandler(new IRtcEngineEventHandler() {
            @Override
            public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
                log.d("join in rtc success");

                notifyJoinChannelState(MiniClassActivity.JOIN_STATE_JOIN_SUCCESS);
            }

            @Override
            public void onUserJoined(int uid, int elapsed) {
                log.d("onUserJoined:" + (uid & 0xFFFFFFFFL));
            }

            @Override
            public void onUserOffline(int uid, int reason) {
                log.d("onUserOffline:" + (uid & 0xFFFFFFFFL));
            }

            @Override
            public void onUserEnableLocalVideo(int uid, boolean enabled) {

            }

            @Override
            public void onUserMuteVideo(int uid, boolean muted) {
                if (mListener != null) {
                    Event muteVideoEvent = new Event(Event.EVENT_TYPE_MUTE_VIDEO_FROM_RTC);
                    muteVideoEvent.bool1 = muted;
                    muteVideoEvent.text1 = String.valueOf(uid & 0xFFFFFFFFL);
                    mListener.onFragmentEvent(muteVideoEvent);
                }
            }

            @Override
            public void onUserMuteAudio(int uid, boolean muted) {
                if (mListener != null) {
                    Event muteAudioEvent = new Event(Event.EVENT_TYPE_MUTE_AUDIO_FROM_RTC);
                    muteAudioEvent.bool1 = muted;
                    muteAudioEvent.text1 = String.valueOf(uid & 0xFFFFFFFFL);
                    mListener.onFragmentEvent(muteAudioEvent);
                }
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

        rtcWorkerThread().joinChannel(rtcRole, UserConfig.getRtcChannelName(), UserConfig.getRtcUserId(), null);
    }

    private void initStudentsLayout(final View root) {
        mRcvStudentVideoList = root.findViewById(R.id.rcv_student_list_video);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager((Context) mListener, LinearLayoutManager.HORIZONTAL, false);
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

        mFlTeacherVideo.removeAllViews();
        if (teacherAttr.isMuteVideo) {
            mIvBgTeacher.setVisibility(View.VISIBLE);
        } else {
            mIvBgTeacher.setVisibility(View.GONE);
            SurfaceView teacherView = RtcEngine.CreateRendererView((Context) mListener);
            int teacherUid = Integer.parseInt(teacherAttr.streamId);

            if (teacherUid == UserConfig.getRtcUserId()) {
                rtcEngine().setupLocalVideo(new VideoCanvas(teacherView));
            } else {
                rtcEngine().setupRemoteVideo(new VideoCanvas(teacherView, Constants.RENDER_MODE_HIDDEN, teacherUid));
            }

            teacherView.setZOrderMediaOverlay(true);
            mFlTeacherVideo.addView(teacherView);
            mTvTeacherName.setText(teacherAttr.name);
        }
    }

    @Override
    public void onActivityMainThreadEvent(BaseEvent event) {
        if (event instanceof UpdateMembersEvent) {
            UpdateMembersEvent updateMembersEvent = (UpdateMembersEvent) event;

            log.i("updateMembers");
            updateTeacher(updateMembersEvent.getTeacherAttr());
            if (mRcvAdapter == null)
                return;

            mRcvAdapter.setList(updateMembersEvent.getUserAttrList());
            mRcvAdapter.notifyDataSetChanged();
            if (mRcvAdapter.getItemCount() > 3) {
                mRcvStudentVideoList.smoothScrollToPosition(mRcvAdapter.getItemCount() - 1);
            }

            RtmRoomControl.UserAttr myAttr = UserConfig.getUserAttrByUserId(UserConfig.getRtmUserId());
            if (myAttr != null) {
                rtcEngine().muteLocalVideoStream(myAttr.isMuteVideo);
                rtcEngine().muteLocalAudioStream(myAttr.isMuteAudio);
            }
        } else if (event instanceof Event) {
            switch (event.getEventType()) {
                case Event.EVENT_TYPE_MAX:
                    mFlStudentVideoList.setVisibility(View.GONE);
                    ConstraintLayout.LayoutParams lpMax = (ConstraintLayout.LayoutParams) mFlTeacherVideoLayout.getLayoutParams();
                    lpMax.topMargin = getResources().getDimensionPixelSize(R.dimen.dp_3);
                    lpMax.setMarginEnd(getResources().getDimensionPixelSize(R.dimen.dp_3));
                    mFlTeacherVideoLayout.setLayoutParams(lpMax);
                    break;
                case Event.EVENT_TYPE_MIN:
                    ConstraintLayout.LayoutParams lpMin = (ConstraintLayout.LayoutParams) mFlTeacherVideoLayout.getLayoutParams();
                    lpMin.topMargin = 0;
                    lpMin.setMarginEnd(0);
                    mFlTeacherVideoLayout.setLayoutParams(lpMin);
                    mFlStudentVideoList.setVisibility(View.VISIBLE);
                    break;
            }
        } else if (event instanceof MuteEvent) {
            MuteEvent muteEvent = (MuteEvent) event;
            RtmRoomControl.UserAttr attr = muteEvent.getUserAttr();
            if (attr != null) {
                if (Mute.AUDIO.equals(muteEvent.muteType)) {
                    if (UserConfig.getRtmUserId().equals(attr.streamId)) {
                        rtcEngine().muteLocalAudioStream(attr.isMuteAudio);
                    }
                } else if (Mute.VIDEO.equals(muteEvent.muteType)) {
                    if (UserConfig.getRtmUserId().equals(attr.streamId)) {
                        rtcEngine().muteLocalVideoStream(attr.isMuteVideo);
                    }
                    if (Constant.Role.TEACHER.strValue().equals(attr.role)) {
                        updateTeacher(attr);
                    } else {
                        mRcvAdapter.updateItemById(attr.streamId, attr);
                    }
                }
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

    private void notifyJoinChannelState(int joinStateJoinSuccess) {
        if (mListener != null) {
            Event event = new Event(Event.EVENT_TYPE_NOTIFY_JOIN_STATE);
            event.value1 = joinStateJoinSuccess;
            mListener.onFragmentEvent(event);
        }
    }

    public static class Event extends BaseEvent {

        public static final int EVENT_TYPE_MIN = 104;
        public static final int EVENT_TYPE_MAX = 105;
        public static final int EVENT_TYPE_NOTIFY_JOIN_STATE = 106;

        public static final int EVENT_TYPE_MUTE_AUDIO_FROM_RTC = 108;
        public static final int EVENT_TYPE_MUTE_VIDEO_FROM_RTC = 109;

        public Event(int eventType) {
            super(eventType);
        }
    }
}
