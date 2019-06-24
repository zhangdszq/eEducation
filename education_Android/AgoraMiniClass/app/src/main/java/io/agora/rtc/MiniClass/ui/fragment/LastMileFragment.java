package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;


public class LastMileFragment extends Fragment {

    private OnFragmentInteractionListener mInteractionListener;

    public LastMileFragment() {
    }

    public static LastMileFragment newInstance() {
        LastMileFragment fragment = new LastMileFragment();
//        Bundle args = new Bundle();
//        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_last_mile, container, false);
        TextView tvBtnOK = root.findViewById(R.id.tv_btn_ok);
        tvBtnOK.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mInteractionListener != null) {
                    mInteractionListener.onLastMileFragmentEvent(OnFragmentInteractionListener.EVENT_CLICK_OK);
                }
            }
        });
        return root;
    }


    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnFragmentInteractionListener) {
            mInteractionListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mInteractionListener = null;
    }

    public interface OnFragmentInteractionListener {
        String EVENT_CLICK_OK = "click ok";
        void onLastMileFragmentEvent(String eventType);
    }
}
