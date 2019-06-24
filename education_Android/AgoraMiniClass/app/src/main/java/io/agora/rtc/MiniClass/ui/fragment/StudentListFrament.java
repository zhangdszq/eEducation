package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.StudentIMBean;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.ui.adapter.RcvChatRoomMsgAdapter;
import io.agora.rtc.MiniClass.ui.adapter.RcvStudentListAdapter;


public class StudentListFrament extends Fragment {

    private RecyclerView mRcvMsg;
    private RcvStudentListAdapter mRcvAdapter;

    private OnFragmentInteractionListener mListener;

    public StudentListFrament() {
    }

    public static StudentListFrament newInstance() {
        StudentListFrament fragment = new StudentListFrament();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_student_list_frament, container, false);

        mRcvMsg = root.findViewById(R.id.rcv_student_list);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager((Context) mListener, LinearLayoutManager.VERTICAL, false);
        mRcvMsg.setLayoutManager(linearLayoutManager);
        mRcvAdapter = new RcvStudentListAdapter();
        mRcvAdapter.addItem(new StudentIMBean("jay", true, false));
        mRcvAdapter.addItem(new StudentIMBean("jay", true, false));
        mRcvAdapter.addItem(new StudentIMBean("jay", true, false));
        mRcvAdapter.addItem(new StudentIMBean("jay", true, true));
        mRcvAdapter.addItem(new StudentIMBean("jay", false, false));
        mRcvAdapter.addItem(new StudentIMBean("jay", true, false));
        mRcvMsg.setAdapter(mRcvAdapter);

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
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {
        void onStudentListFragmentEvent(BaseEvent event);
    }
}
