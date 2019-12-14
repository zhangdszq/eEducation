package io.agora.rtc.education.room.miniclass;

import android.content.Context;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseRcvAdapter;
import io.agora.rtc.education.data.bean.User;
import io.agora.rtc.education.room.view.SpeakerView;
import io.agora.rtc.education.room.view.UserVideoItem;
import io.agora.rtc.video.VideoCanvas;

public class VideoItemRcvAdapter extends BaseRcvAdapter<VideoItemRcvAdapter.ViewHolder, User> {
    private int myUid;

    public VideoItemRcvAdapter(int myUid) {
        this.myUid = myUid;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        Context c = parent.getContext();
        UserVideoItem item = new UserVideoItem(c);
        item.init(R.layout.item_user_video_mini_class, false);
        int height = parent.getHeight() - parent.getPaddingTop() - parent.getPaddingBottom();
        item.setLayoutParams(new ViewGroup.LayoutParams(c.getResources().getDimensionPixelSize(R.dimen.dp_92), height));
        return new ViewHolder(item);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        User user = getItem(position);
        UserVideoItem item = (UserVideoItem) holder.itemView;
        item.setIcVideoSelect(user.video == 1);
        item.setIcAudioState(user.audio == 1 ? SpeakerView.STATE_OPENED : SpeakerView.STATE_CLOSED);
        item.setName(user.account);
        item.showVideo(user.video == 1);
        SurfaceView surfaceView = item.getSurfaceView();
        if (surfaceView == null || user.getUid() != (int)(surfaceView.getTag())) {
            surfaceView = RtcEngine.CreateRendererView(holder.itemView.getContext());
            surfaceView.setTag(user.getUid());
            item.setVideoView(surfaceView);

        }
        if (user.getUid() == myUid) {
            AGApplication.the().getRtcWorker().getRtcEngine().setupLocalVideo(new VideoCanvas(surfaceView));
        } else {
            AGApplication.the().getRtcWorker().getRtcEngine().setupRemoteVideo(
                    new VideoCanvas(surfaceView, VideoCanvas.RENDER_MODE_HIDDEN, user.getUid())
            );
        }
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
        }
    }
}
