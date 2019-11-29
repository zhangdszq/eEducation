package io.agora.rtc.education.room.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.base.RcvBaseAdapter;
import io.agora.rtc.education.constant.Constant;
import io.agora.rtc.education.constant.Role;
import io.agora.rtc.education.room.bean.RtmRoomControl;
import io.agora.rtc.lib.rtm.RtmManager;
import io.agora.rtc.lib.util.ToastUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;


public class StudentListFrament extends BaseFragment {

    private RecyclerView mRcvMsg;
    private RcvStudentListAdapter mRcvAdapter;

    private TextView mTvBtnMuteAll, mTvBtnUnMuteAll;

    public StudentListFrament() {
    }

    public static StudentListFrament newInstance() {
        StudentListFrament fragment = new StudentListFrament();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_student_list, container, false);
        if (isNeedShowMuteButton)
            showMuteUI();

        mRcvMsg = root.findViewById(R.id.rcv_student_list);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(mContext, LinearLayoutManager.VERTICAL, false);
        mRcvMsg.setLayoutManager(linearLayoutManager);
        if (mRcvAdapter == null)
            mRcvAdapter = new RcvStudentListAdapter();
        mRcvMsg.setAdapter(mRcvAdapter);

        return root;
    }

//    public void onActivityMainThreadEvent(BaseEvent event) {
//        if (event instanceof UpdateMembersEvent) {
//            UpdateMembersEvent myEvent = (UpdateMembersEvent) event;
//            if (myEvent.getTeacherAttr() != null && UserConfig.getRtmUserId().equals(myEvent.getTeacherAttr().streamId)) {
//                showMuteUI();
//            }
//
//            if (mRcvAdapter == null) {
//                mRcvAdapter = new RcvStudentListAdapter();
//                mRcvAdapter.setList(myEvent.getUserAttrList());
//            } else {
//                mRcvAdapter.setList(myEvent.getUserAttrList());
//                mRcvAdapter.notifyDataSetChanged();
//            }
//        } else if (event instanceof MuteEvent) {
//            MuteEvent muteEvent = (MuteEvent) event;
//            RtmRoomControl.UserAttr attr = muteEvent.getUserAttr();
//            if (attr != null) {
//                mRcvAdapter.updateItemById(attr.streamId, attr);
//            }
//        }
//    }

    private boolean isNeedShowMuteButton = false;

    private void showMuteUI() {
        if (mTvBtnUnMuteAll == null) {
            isNeedShowMuteButton = true;
            return;
        }
        mTvBtnUnMuteAll.setVisibility(View.VISIBLE);
        mTvBtnMuteAll.setVisibility(View.VISIBLE);
        mTvBtnMuteAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                muteAll(true);
            }
        });

        mTvBtnUnMuteAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                muteAll(false);
            }
        });
    }

    ResultCallback<Void> resultCallback = new ResultCallback<Void>() {
        @Override
        public void onSuccess(Void aVoid) {

        }

        @Override
        public void onFailure(ErrorInfo errorInfo) {
//            ToastUtil.showErrorShortFromSubThread(mContext, R.string.send_message_failed);
        }
    };

    private void muteAll(boolean isMute) {
    }


    public static class RcvStudentListAdapter extends RcvBaseAdapter<RtmRoomControl.UserAttr, MyViewHolder> {
        private Context mContext;

        private RtmManager rtmManager() {
            return AGApplication.the().getRtmManager();
        }

        @NonNull
        @Override
        public MyViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
            mContext = viewGroup.getContext();
            View itemView = View.inflate(mContext, R.layout.rcv_item_student_list, null);
            return new MyViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull final MyViewHolder myViewHolder, int i) {
            final RtmRoomControl.UserAttr student = getItem(i);
            myViewHolder.tvName.setText(student.name);
            myViewHolder.ivBtnMuteAudio.setSelected(student.isMuteAudio);
            myViewHolder.ivBtnMuteVideo.setSelected(student.isMuteVideo);

            myViewHolder.ivBtnMuteAudio.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

//                    if (UserConfig.getRole() == Constant.Role.TEACHER) {
//                        student.isMuteAudio = !student.isMuteAudio;
//                        myViewHolder.ivBtnMuteAudio.setSelected(student.isMuteAudio);
//                        rtmManager().mute(student.isMuteAudio, Mute.AUDIO, student.streamId, new ResultCallback<Void>() {
//                            @Override
//                            public void onSuccess(Void aVoid) {
//                            }
//
//                            @Override
//                            public void onFailure(ErrorInfo errorInfo) {
//                                if (mContext instanceof Activity) {
//                                    ToastUtil.showErrorShortFromSubThread((Activity) mContext, R.string.send_message_failed);
//                                }
//                            }
//                        });
//                    } else {
//                        ToastUtil.showShort("Sorry, only the teacher can mute someone.");
//                    }
                }
            });

            myViewHolder.ivBtnMuteVideo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
//
//                    if (UserConfig.getRole() == Role.TEACHER) {
//                        student.isMuteVideo = !student.isMuteVideo;
//                        myViewHolder.ivBtnMuteVideo.setSelected(student.isMuteVideo);
//                        rtmManager().mute(student.isMuteVideo, Mute.VIDEO, student.streamId, new ResultCallback<Void>() {
//                            @Override
//                            public void onSuccess(Void aVoid) {
//                            }
//
//                            @Override
//                            public void onFailure(ErrorInfo errorInfo) {
//                                if (mContext instanceof Activity) {
//                                    ToastUtil.showErrorShortFromSubThread((Activity) mContext, R.string.send_message_failed);
//                                }
//                            }
//                        });
//                    } else {
//                        ToastUtil.showShort("Sorry, only the teacher can mute someone.");
//                    }
                }
            });
        }

        @Override
        protected String getItemStringId(int position) {
            return getItem(position) == null ? null : getItem(position).streamId;
        }

    }

    public static class MyViewHolder extends RecyclerView.ViewHolder {
        TextView tvName;
        ImageView ivBtnMuteAudio;
        ImageView ivBtnMuteVideo;

        public MyViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tv_name);
            ivBtnMuteAudio = itemView.findViewById(R.id.iv_btn_mute_audio);
            ivBtnMuteVideo = itemView.findViewById(R.id.iv_btn_mute_video);
        }
    }
}
