package io.agora.rtc.MiniClass.ui.adapter;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
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
        RtmRoomControl.UserAttr studentVideoBean = getItem(i);
        myViewHolder.tvName.setText(studentVideoBean.name);
        if (i == 0) {
            myViewHolder.spaceFirstItemEnd.setVisibility(View.VISIBLE);
        } else {
            myViewHolder.spaceFirstItemEnd.setVisibility(View.GONE);
        }

        RtcEngine rtcEngine = AGApplication.the().getWorkerThread().getRtcEngine();

        if (rtcEngine != null &&
                (Constant.Role.TEACHER.strValue().equals(studentVideoBean.role) ||
                        Constant.Role.STUDENT.strValue().equals(studentVideoBean.role))) {

            try {
                SurfaceView surfaceView = RtcEngine.CreateRendererView(mContext);
                surfaceView.setZOrderMediaOverlay(true);
                int uid = Integer.parseInt(studentVideoBean.streamId);
                if (uid == UserConfig.getRtcUserId()) {
                    rtcEngine.setupLocalVideo(new VideoCanvas(surfaceView));
                } else {
                    rtcEngine.setupRemoteVideo(new VideoCanvas(surfaceView, Constants.RENDER_MODE_HIDDEN, uid));
                }

                myViewHolder.flStudentVideo.addView(surfaceView);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }
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
