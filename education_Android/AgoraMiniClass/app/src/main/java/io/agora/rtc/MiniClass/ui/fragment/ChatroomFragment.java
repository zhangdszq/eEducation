package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.MsgBean;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.ui.adapter.RcvChatRoomMsgAdapter;

public class ChatroomFragment extends Fragment {

    private RecyclerView mRcvMsg;
    private RcvChatRoomMsgAdapter mRcvAdapter;
    private OnFragmentInteractionListener mListener;

    public ChatroomFragment() {
    }

    public static ChatroomFragment newInstance() {
        ChatroomFragment fragment = new ChatroomFragment();
        return fragment;
    }

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
        mRcvAdapter.addItem(new MsgBean(0, "Jay", "我不懂"));
        mRcvAdapter.addItem(new MsgBean(0, "Jay", "我不懂"));
        mRcvAdapter.addItem(new MsgBean(0, "Jay", "我不懂"));
        mRcvAdapter.addItem(new MsgBean(0, "Jay", "我不懂"));
        mRcvAdapter.addItem(new MsgBean(1, "Ann", "你懂"));
        mRcvAdapter.addItem(new MsgBean(1, "Ann", "你懂"));
        mRcvAdapter.addItem(new MsgBean(1, "Ann", "你懂"));
        mRcvAdapter.notifyDataSetChanged();
        return root;
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        mRcvMsg.scrollToPosition(mRcvAdapter.getItemCount() - 1);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {
        void onChatRoomFragmentEvent(BaseEvent event);
    }
}
