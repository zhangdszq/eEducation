package io.agora.rtc.MiniClass.ui.adapter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.StudentIMBean;
import io.agora.rtc.MiniClass.model.bean.StudentVideoBean;

public class RcvStudentListAdapter extends RcvBaseAdapter<StudentIMBean, RcvStudentListAdapter.MyViewHolder> {
    private Context mContext;

    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        mContext = viewGroup.getContext();
        View itemView = View.inflate(mContext, R.layout.rcv_item_student_list, null);
        return new MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull MyViewHolder myViewHolder, int i) {
        StudentIMBean student = getItem(i);
        myViewHolder.tvName.setText(student.name);
        myViewHolder.ivBtnMuteAudio.setSelected(student.isMuteAudio);
        myViewHolder.ivBtnMuteVideo.setSelected(student.isMuteVideo);
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
