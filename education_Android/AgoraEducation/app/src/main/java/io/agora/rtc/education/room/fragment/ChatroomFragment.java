package io.agora.rtc.education.room.fragment;

import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Paint;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.base.BaseListAdapter;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.im.ChannelMsg;
import io.agora.rtc.education.im.IMStrategy;
import io.agora.rtc.education.room.replay.ReplayActivity;

public class ChatroomFragment extends BaseFragment {

    private ListView mLvMsg;
    private MsgListAdapter mAdapter;
    private EditText mEdtSendMsg;
    private IMStrategy mImStrategy;

    public static ChatroomFragment newInstance() {
        return new ChatroomFragment();
    }

    @Override
    protected View initUI(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_chatroom, container, false);

        mLvMsg = view.findViewById(R.id.lv_msg);
        mAdapter = new MsgListAdapter();
        mLvMsg.setAdapter(mAdapter);

        mEdtSendMsg = view.findViewById(R.id.edt_send_msg);
        mEdtSendMsg.setEnabled(false);
        mEdtSendMsg.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (!mEdtSendMsg.isEnabled() || mImStrategy == null) {
                    return false;
                }
                String text = mEdtSendMsg.getText().toString();
                if (KeyEvent.KEYCODE_ENTER == keyCode && KeyEvent.ACTION_DOWN == event.getAction() && text.trim().length() > 0) {
                    ChannelMsg msg = mImStrategy.sendChannelMessage(text);
                    mEdtSendMsg.setText("");
                    addMessage(msg);
                    return true;
                }
                return false;
            }
        });
        return view;
    }

    public void setEditTextEnable(final boolean isEnable) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mEdtSendMsg != null) {
                    mEdtSendMsg.setEnabled(isEnable);
                    if (isEnable) {
                        mEdtSendMsg.setHint(R.string.hint_im_message);
                    } else {
                        mEdtSendMsg.setHint(R.string.chat_muting);
                    }
                }
            }
        });
    }

    public void addMessage(final ChannelMsg channelMsg) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mLvMsg != null) {
                    mAdapter.addItem(channelMsg);
                    mAdapter.notifyDataSetChanged();
                }
            }
        });
    }

    public void setImStrategy(IMStrategy imStrategy) {
        this.mImStrategy = imStrategy;
    }

    private class MsgListAdapter extends BaseListAdapter<ChannelMsg> {
        @Override
        protected void onBindViewHolder(BaseViewHolder viewHolder, final ChannelMsg msg, int position) {
            ViewHolder holder = (ViewHolder) viewHolder;
            Resources resources = holder.itemView.getContext().getResources();
            holder.tvName.setText(msg.account);
            if (TextUtils.isEmpty(msg.link)) {
                holder.tvContent.setText(msg.content);
                holder.tvContent.setTextColor(resources.getColor(R.color.gray_666666));
                holder.tvContent.getPaint().setFlags(0);
            } else {
                holder.tvContent.setText(resources.getString(R.string.replay_recording));
                holder.tvContent.setTextColor(resources.getColor(R.color.blue_1F3DE8));
                holder.tvContent.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
            }
            holder.tvContent.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (!TextUtils.isEmpty(msg.link)) {
                        String[] strings = msg.link.split("/");
                        String uuid = strings[2];
                        long startTime = Long.parseLong(strings[3]);
                        long endTime = Long.parseLong(strings[4]);
                        Intent intent = new Intent(ChatroomFragment.this.mContext, ReplayActivity.class);
                        intent.putExtra(IntentKey.WHITE_BOARD_UID, uuid);
                        intent.putExtra(IntentKey.WHITE_BOARD_START_TIME, startTime);
                        intent.putExtra(IntentKey.WHITE_BOARD_END_TIME, endTime);
                        intent.putExtra(IntentKey.WHITE_BOARD_URL, msg.url);
                        startActivity(intent);
                    }
                }
            });
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
