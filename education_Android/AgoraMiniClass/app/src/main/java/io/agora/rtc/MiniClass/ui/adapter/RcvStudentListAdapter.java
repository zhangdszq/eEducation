package io.agora.rtc.MiniClass.ui.adapter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.Mute;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.bean.StudentIMBean;
import io.agora.rtc.MiniClass.model.bean.StudentVideoBean;
import io.agora.rtc.MiniClass.model.rtm.ChatManager;

public class RcvStudentListAdapter extends RcvBaseAdapter<RtmRoomControl.UserAttr, RcvStudentListAdapter.MyViewHolder> {
    private Context mContext;

    private ChatManager chatManager() {
        return AGApplication.the().getChatManager();
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
                student.isMuteAudio = !student.isMuteAudio;
                myViewHolder.ivBtnMuteAudio.setSelected(student.isMuteAudio);
                chatManager().mute(student.isMuteAudio, Mute.AUDIO, student.streamId);
            }
        });

        myViewHolder.ivBtnMuteVideo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                student.isMuteVideo = !student.isMuteVideo;
                myViewHolder.ivBtnMuteVideo.setSelected(student.isMuteVideo);
                chatManager().mute(student.isMuteVideo, Mute.VIDEO, student.streamId);
            }
        });
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
