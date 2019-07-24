package io.agora.rtc.MiniClass.ui.adapter;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.ChannelMessage;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;

public class RcvChatRoomMsgAdapter extends RcvBaseAdapter<ChannelMessage.Args, RcvChatRoomMsgAdapter.UserViewHolder> {

    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        View itemView;
        if (i == Constant.Role.TEACHER.intValue()) {
            itemView = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.rcv_item_teacher_msg, viewGroup, false);
        } else {
            itemView = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.rcv_item_student_msg, viewGroup, false);
        }
        return new UserViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull UserViewHolder viewHolder, int i) {
        ChannelMessage.Args bean = getItem(i);
        RtmRoomControl.UserAttr userAttr = UserConfig.getUserAttrByUserId(bean.uid);
        if (userAttr != null) {
            viewHolder.tvName.setText(userAttr.name);
        }
        viewHolder.tvContent.setText(bean.message);
    }

    @Override
    public int getItemViewType(int position) {
        return getItem(position).role;
    }

    public static class UserViewHolder extends RecyclerView.ViewHolder {

        public TextView tvName;
        public TextView tvContent;

        public UserViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tv_name);
            tvContent = itemView.findViewById(R.id.tv_content);
        }
    }

}
