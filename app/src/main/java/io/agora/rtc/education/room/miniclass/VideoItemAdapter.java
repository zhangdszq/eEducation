package io.agora.rtc.education.room.miniclass;

import android.content.Context;
import android.view.SurfaceView;
import android.view.ViewGroup;

import io.agora.rtc.RtcEngine;
import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseListAdapter;
import io.agora.rtc.education.data.bean.User;
import io.agora.rtc.education.room.view.SpeakerView;
import io.agora.rtc.education.room.view.UserVideoItem;
import io.agora.rtc.video.VideoCanvas;

public class VideoItemAdapter extends BaseListAdapter<User> {
    private int myUid;

    public VideoItemAdapter(int myUid) {
        this.myUid = myUid;
    }

    @Override
    protected void onBindViewHolder(BaseViewHolder viewHolder, User user, int position) {
        UserVideoItem item = (UserVideoItem) viewHolder.itemView;
        item.setIcVideoSelect(user.video == 1);
        item.setIcAudioState(user.audio == 1 ? SpeakerView.STATE_OPENED : SpeakerView.STATE_CLOSED);
        item.setName(user.account);
        item.showVideo(user.video == 1);
        SurfaceView surfaceView = item.getSurfaceView();
        if (surfaceView == null || user.getUid() != (int)(surfaceView.getTag())) {
            surfaceView = RtcEngine.CreateRendererView(viewHolder.itemView.getContext());
            surfaceView.setTag(user.getUid());
            item.setVideoView(surfaceView);
            if (user.getUid() == myUid) {
                AGApplication.the().getRtcWorker().getRtcEngine().setupLocalVideo(new VideoCanvas(surfaceView));
            } else {
                AGApplication.the().getRtcWorker().getRtcEngine().setupRemoteVideo(
                        new VideoCanvas(surfaceView, VideoCanvas.RENDER_MODE_HIDDEN, user.getUid())
                );
            }
        }
    }

    @Override
    protected BaseViewHolder onCreateViewHolder(int itemViewType, ViewGroup parent) {
        Context c = parent.getContext();
        UserVideoItem item = new UserVideoItem(c);
        item.init(R.layout.item_user_video_mini_class, false);
        int height = parent.getHeight() - parent.getPaddingTop() - parent.getPaddingBottom();
        item.setLayoutParams(new ViewGroup.LayoutParams(c.getResources().getDimensionPixelSize(R.dimen.dp_92), height));
        return new BaseViewHolder(item);
    }
}
