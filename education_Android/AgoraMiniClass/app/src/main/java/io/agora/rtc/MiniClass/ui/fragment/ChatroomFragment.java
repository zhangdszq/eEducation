package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.ChannelMessage;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.util.ToastUtil;
import io.agora.rtc.MiniClass.ui.adapter.RcvChatRoomMsgAdapter;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;

public class ChatroomFragment extends BaseFragment {

    private RecyclerView mRcvMsg;
    private RcvChatRoomMsgAdapter mRcvAdapter;
    private EditText mEdtSendMsg;

    public ChatroomFragment() {
    }

    public static ChatroomFragment newInstance() {
        ChatroomFragment fragment = new ChatroomFragment();
        return fragment;
    }

    private ResultCallback<Void> msgCallback = new ResultCallback<Void>() {
        @Override
        public void onSuccess(Void aVoid) {
        }

        @Override
        public void onFailure(ErrorInfo errorInfo) {
            if (mListener != null)
                ToastUtil.showErrorShortFromSubThread((Activity) mListener, R.string.send_message_failed);
        }
    };

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_chatroom, container, false);

        mRcvMsg = root.findViewById(R.id.rcv_chat_room_msg);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager((Context) mListener, LinearLayoutManager.VERTICAL, false);
        linearLayoutManager.setStackFromEnd(true);
        mRcvMsg.setLayoutManager(linearLayoutManager);
        mRcvAdapter = new RcvChatRoomMsgAdapter();
        mRcvMsg.setAdapter(mRcvAdapter);

        mEdtSendMsg = root.findViewById(R.id.edt_send_msg);
        mEdtSendMsg.setEnabled(true);
        mEdtSendMsg.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                String text = mEdtSendMsg.getText().toString();
                if (KeyEvent.KEYCODE_ENTER == keyCode && KeyEvent.ACTION_DOWN == event.getAction() && !TextUtils.isEmpty(text)) {
                    final ChannelMessage channelMessage = new ChannelMessage();
                    channelMessage.name = ChannelMessage.SEND_NAME;
                    channelMessage.args = new ChannelMessage.Args();
                    channelMessage.args.uid = UserConfig.getRtmUserId();
                    channelMessage.args.message = text;
                    channelMessage.args.role = UserConfig.getRole().intValue();
                    rtmManager().sendChatMsg(channelMessage, msgCallback);

                    mEdtSendMsg.setText("");
                    return true;
                }
                return false;
            }
        });
        return root;
    }

    @Override
    public void onResume() {
        super.onResume();
        mRcvMsg.scrollToPosition(mRcvAdapter.getItemCount() - 1);
    }

    @Override
    public void onActivityMainThreadEvent(BaseEvent event) {
        if (event instanceof Event) {
            Event msgEvent = (Event) event;
            if (msgEvent.msgArgs == null
                    || msgEvent.msgArgs.uid == null
                /*|| msgEvent.msgArgs.uid.equals(UserConfig.getRtmUserId())*/)
                return;

            addMsg(msgEvent.msgArgs);
        }
    }

    private void addMsg(ChannelMessage.Args msg) {
        mRcvAdapter.addItem(msg);
        if (mRcvAdapter.getItemCount() > 1) {
            mRcvMsg.smoothScrollToPosition(mRcvAdapter.getItemCount() - 1);
        }
        mRcvAdapter.notifyDataSetChanged();
    }

    public static class Event extends BaseEvent {
        public static final int EVENT_TYPE_UPDATE_MESSAGE = 1;

        public ChannelMessage.Args msgArgs;

        public Event(int eventType) {
            super(eventType);
        }
    }

}
