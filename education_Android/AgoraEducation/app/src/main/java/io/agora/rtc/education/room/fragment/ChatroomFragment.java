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
import io.agora.rtc.education.im.ChannelMsg;
import io.agora.rtc.education.im.IMStrategy;

public class ChatroomFragment extends BaseFragment {

    private ListView mLvMsg;
    private MsgListAdapter mAdapter;
    private EditText mEdtSendMsg;
    private View mViewRoot;
    private IMStrategy mImStrategy;

    public static ChatroomFragment newInstance() {
        ChatroomFragment fragment = new ChatroomFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        if (mViewRoot != null) {
            ViewGroup parent = (ViewGroup) mViewRoot.getParent();
            if (parent != null) {
                parent.removeView(mViewRoot);
            }
            return mViewRoot;
        }
        mViewRoot = inflater.inflate(R.layout.fragment_chatroom, container, false);

        mLvMsg = mViewRoot.findViewById(R.id.lv_msg);
        mAdapter = new MsgListAdapter();
        mLvMsg.setAdapter(mAdapter);

        mEdtSendMsg = mViewRoot.findViewById(R.id.edt_send_msg);
        mEdtSendMsg.setEnabled(false);
        mEdtSendMsg.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (!mEdtSendMsg.isEnabled() || mImStrategy == null) {
                    return false;
                }
                String text = mEdtSendMsg.getText().toString();
                if (KeyEvent.KEYCODE_ENTER == keyCode && KeyEvent.ACTION_DOWN == event.getAction() && !TextUtils.isEmpty(text)) {
                    ChannelMsg msg = mImStrategy.sendChannelMessage(text);
                    mEdtSendMsg.setText("");
                    addMessage(msg);
                    return true;
                }
                return false;
            }
        });
        return mViewRoot;
    }

    public void setEditTextEnable(boolean isEnable) {
        if (mEdtSendMsg != null) {
            mEdtSendMsg.setEnabled(isEnable);
        }
    }

    public void addMessage(ChannelMsg channelMsg) {
        if (mLvMsg != null) {
            mAdapter.addItem(channelMsg);
            mAdapter.notifyDataSetChanged();
        }
    }

    public void setImStrategy(IMStrategy imStrategy) {
        this.mImStrategy = imStrategy;
    }

    static class MsgListAdapter extends BaseListAdapter<ChannelMsg> {
        @Override
        protected void onBindViewHolder(BaseViewHolder viewHolder, ChannelMsg msg, int position) {
            ViewHolder holder = (ViewHolder) viewHolder;
            holder.tvName.setText(msg.account);
            holder.tvContent.setText(msg.content);
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
