package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.StudentVideoBean;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.ui.adapter.RcvStudentVideoListAdapter;


public class VideoCallFragment extends Fragment {

    private OnFragmentInteractionListener mListener;

    private RecyclerView mRcvStudentVideoList;
    private RcvStudentVideoListAdapter mRcvAdapter;
    private SurfaceView surfaceViewTeacher;

    public static VideoCallFragment newInstance() {
        VideoCallFragment fragment = new VideoCallFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        View root = inflater.inflate(R.layout.fragment_video_call, container, false);
        initStudentsLayout(root);
        return root;
    }

    private void initStudentsLayout(View root) {
        mRcvStudentVideoList = root.findViewById(R.id.rcv_student_list_video);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager((Context)mListener, LinearLayoutManager.HORIZONTAL, true);
        linearLayoutManager.setStackFromEnd(true);
        mRcvStudentVideoList.setLayoutManager(linearLayoutManager);
        mRcvAdapter = new RcvStudentVideoListAdapter();
        mRcvStudentVideoList.setAdapter(mRcvAdapter);
        mRcvAdapter.addItem(new StudentVideoBean("ahua"));
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean());
        mRcvAdapter.addItem(new StudentVideoBean("agou"));
        mRcvAdapter.notifyDataSetChanged();
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
        mRcvStudentVideoList.smoothScrollToPosition(0);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {
        void onVideoCallFragmentEvent(BaseEvent event);
    }
}
