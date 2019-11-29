package io.agora.rtc.education.room.fragment;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.base.BaseListAdapter;
import io.agora.rtc.education.room.bean.User;

public class ChatroomFragment extends BaseFragment {

    private ListView mLvMsg;
    private MsgListAdapter mAdapter;
    private EditText mEdtSendMsg;

    public static ChatroomFragment newInstance() {
        ChatroomFragment fragment = new ChatroomFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_chatroom, container, false);

        mLvMsg = root.findViewById(R.id.lv_msg);
        mAdapter = new MsgListAdapter();
        mLvMsg.setAdapter(mAdapter);

        mEdtSendMsg = root.findViewById(R.id.edt_send_msg);
        mEdtSendMsg.setEnabled(true);
        mEdtSendMsg.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                String text = mEdtSendMsg.getText().toString();
                if (KeyEvent.KEYCODE_ENTER == keyCode && KeyEvent.ACTION_DOWN == event.getAction() && !TextUtils.isEmpty(text)) {
//                    final ChannelMessage channelMessage = new ChannelMessage();
//                    channelMessage.name = ChannelMessage.SEND_NAME;
//                    channelMessage.args = new ChannelMessage.Args();
//                    channelMessage.args.uid = UserConfig.getRtmUserId();
//                    channelMessage.args.message = text;
//                    channelMessage.args.role = UserConfig.getRole().intValue();
//                    rtmManager().sendChatMsg(channelMessage, msgCallback);

                    mEdtSendMsg.setText("");
                    return true;
                }
                return false;
            }
        });
        return root;
    }


    static class MsgListAdapter extends BaseListAdapter<User> {
        @Override
        protected void onBindViewHolder(BaseViewHolder viewHolder, User user, int position) {
            ViewHolder holder = (ViewHolder) viewHolder;
            holder.tvName.setText(user.name);
            holder.tvContent.setText(user.content);
        }

        @Override
        protected BaseViewHolder onCreateViewHolder(int itemViewType, ViewGroup parent) {
            View view;
            if (itemViewType == 0) {
                view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.item_msg_other, parent, false);
            } else {
                view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.item_msg_me, parent, false);
            }
            return new ViewHolder(view);
        }

        @Override
        public int getViewTypeCount() {
            return 2;
        }

        @Override
        public int getItemViewType(int position) {
            if (getList().get(position).isMe) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    private static class ViewHolder extends BaseListAdapter.BaseViewHolder {
        TextView tvName, tvContent;

        public ViewHolder(View itemView) {
            super(itemView);
            tvContent = itemView.findViewById(R.id.tv_content);
            tvName = itemView.findViewById(R.id.tv_name);
        }
    }
}
