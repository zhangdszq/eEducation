package io.agora.rtc.MiniClass.ui.adapter;

import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.zip.Inflater;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.MsgBean;

public class RcvChatRoomMsgAdapter extends RcvBaseAdapter<MsgBean, RcvChatRoomMsgAdapter.UserViewHolder> {

    @NonNull
    @Override
    public UserViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
        View itemView = null;
        switch (i) {
            case 0:
                itemView = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.rcv_item_student_msg, viewGroup, false);
                break;
            case 1:
                itemView = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.rcv_item_teacher_msg, viewGroup, false);
                break;
        }
        return new UserViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(@NonNull UserViewHolder viewHolder, int i) {
        MsgBean bean = getItem(i);
        viewHolder.tvName.setText(bean.name);
        viewHolder.tvContent.setText(bean.content);
    }

    @Override
    public int getItemViewType(int position) {
        return getItem(position).getUserType();
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
