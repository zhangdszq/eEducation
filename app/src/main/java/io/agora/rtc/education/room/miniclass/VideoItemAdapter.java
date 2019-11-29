package io.agora.rtc.education.room.miniclass;

import android.content.Context;
import android.view.ViewGroup;

import androidx.core.content.ContextCompat;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseListAdapter;
import io.agora.rtc.education.room.bean.User;
import io.agora.rtc.education.room.view.UserVideoItem;

public class VideoItemAdapter extends BaseListAdapter<User> {
    @Override
    protected void onBindViewHolder(BaseViewHolder viewHolder, User user, int position) {

    }

    @Override
    protected BaseViewHolder onCreateViewHolder(int itemViewType, ViewGroup parent) {
        Context c = parent.getContext();
        UserVideoItem item = new UserVideoItem(c);
        item.setLayoutParams(new ViewGroup.LayoutParams(c.getResources().getDimensionPixelSize(R.dimen.dp_92), ViewGroup.LayoutParams.MATCH_PARENT));
        return new BaseViewHolder(item);
    }
}
