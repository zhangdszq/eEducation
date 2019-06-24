package io.agora.rtc.MiniClass.ui.fragment;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;


public class PreviewFragment extends Fragment {

    private OnFragmentInteractionListener mInteractionListener;

    public PreviewFragment() {
    }

    public static PreviewFragment newInstance() {
        PreviewFragment fragment = new PreviewFragment();
//        Bundle args = new Bundle();
//        args.putString(ARG_PARAM1, param1);
//        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        if (getArguments() != null) {
//            mParam1 = getArguments().getString(ARG_PARAM1);
//        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_preview, container, false);
        TextView tvBtnNext = root.findViewById(R.id.tv_btn_next);
        tvBtnNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mInteractionListener != null) {
                    mInteractionListener.onPreviewFragmentEvent(OnFragmentInteractionListener.EVENT_CLICK_NEXT);
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
        String EVENT_CLICK_NEXT = "click next";

        void onPreviewFragmentEvent(String eventType);
    }
}
