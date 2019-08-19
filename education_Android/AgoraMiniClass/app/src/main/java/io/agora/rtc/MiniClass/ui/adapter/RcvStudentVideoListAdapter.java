package io.agora.rtc.MiniClass.ui.adapter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.Space;
import android.widget.TextView;

import io.agora.rtc.Constants;
import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.bean.StudentVideoBean;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;

public class RcvStudentVideoListAdapter extends RcvBaseAdapter<RtmRoomControl.UserAttr, RcvStudentVideoListAdapter.MyViewHolder> {
    private Context mContext;

    @Override
    public void updateItemById(String id, RtmRoomControl.UserAttr item) {
        if (mList == null || id == null) {
            return;
        }
        for (int i = 0; i < mList.size(); i++) {
            if (id.equals(getItemStringId(i))) {
                mList.set(i, item);
                notifyItemChanged(i);
            }
        }
    }

    @Override
    protected String getItemStringId(int position) {
        return getItem(position) == null ? null : getItem(position).streamId;
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
        RtmRoomControl.UserAttr studentVideoBean = getItem(i);
        myViewHolder.tvName.setText(studentVideoBean.name);
        if (i == 0) {
            myViewHolder.spaceFirstItemEnd.setVisibility(View.VISIBLE);
        } else {
            myViewHolder.spaceFirstItemEnd.setVisibility(View.GONE);
        }

        RtcEngine rtcEngine = AGApplication.the().getWorkerThread().getRtcEngine();

        if (rtcEngine == null || studentVideoBean.isMuteVideo
                /*|| (!Constant.Role.TEACHER.strValue().equals(studentVideoBean.role)
                && !Constant.Role.STUDENT.strValue().equals(studentVideoBean.role))*/) {

            if (myViewHolder.flStudentVideo.getChildCount() > 0) {
                myViewHolder.flStudentVideo.removeAllViews();
            }
            myViewHolder.ivBgStudent.setVisibility(View.VISIBLE);
        } else {
            try {
                SurfaceView surfaceView = RtcEngine.CreateRendererView(mContext);
                surfaceView.setZOrderMediaOverlay(true);
                int uid = Integer.parseInt(studentVideoBean.streamId);
                if (uid == UserConfig.getRtcUserId()) {
                    rtcEngine.setupLocalVideo(new VideoCanvas(surfaceView));
                } else {
                    rtcEngine.setupRemoteVideo(new VideoCanvas(surfaceView, Constants.RENDER_MODE_HIDDEN, uid));
                }
                if (myViewHolder.flStudentVideo.getChildCount() > 0) {
                    myViewHolder.flStudentVideo.removeAllViews();
                }
                myViewHolder.flStudentVideo.addView(surfaceView);
                myViewHolder.ivBgStudent.setVisibility(View.GONE);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
    }

    public static class MyViewHolder extends RecyclerView.ViewHolder {
        TextView tvName;
        FrameLayout flStudentVideo;
        Space spaceFirstItemEnd;
        ImageView ivBgStudent;

        public MyViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tv_name);
            flStudentVideo = itemView.findViewById(R.id.fl_student_video);
            spaceFirstItemEnd = itemView.findViewById(R.id.space_first_item_end);
            ivBgStudent = itemView.findViewById(R.id.iv_bg_student);
        }
    }
}
