package io.agora.rtc.MiniClass.ui.adapter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.Space;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.StudentVideoBean;

public class RcvStudentVideoListAdapter extends RcvBaseAdapter<StudentVideoBean, RcvStudentVideoListAdapter.MyViewHolder> {
    private Context mContext;

    public RcvStudentVideoListAdapter() {
        super();
    }


    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        mContext = viewGroup.getContext();
        View itemView = View.inflate(mContext, R.layout.rcv_item_student_video_list, null);
        return new MyViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull MyViewHolder myViewHolder, int i) {
        StudentVideoBean studentVideoBean = getItem(i);
        myViewHolder.tvName.setText(studentVideoBean.name);
        if (i == 0) {
            myViewHolder.spaceFirstItemEnd.setVisibility(View.VISIBLE);
        } else {
            myViewHolder.spaceFirstItemEnd.setVisibility(View.GONE);
        }
//        myViewHolder.flStudentVideo.add
    }

    public static class MyViewHolder extends RecyclerView.ViewHolder {
        TextView tvName;
        FrameLayout flStudentVideo;
        Space spaceFirstItemEnd;

        public MyViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tv_name);
            flStudentVideo = itemView.findViewById(R.id.fl_student_video);
            spaceFirstItemEnd = itemView.findViewById(R.id.space_first_item_end);
        }
    }
}
