package io.agora.rtc.MiniClass.ui.fragment;


import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.SimpleEvent;

/**
 * A simple {@link Fragment} subclass.
 */
public class HomeFragment extends Fragment {

    private OnFragmentInteractionListener mListener;
    private TextView tvBtnRoleTeacher, tvBtnRoleStudent, tvBtnRoleAudience;
    private int roleType = Constant.ROLE_STUDENT;

    public HomeFragment() {
    }

    public static HomeFragment newInstance() {
        HomeFragment fragment = new HomeFragment();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_home, container, false);
        initView(root);
        return root;
    }

    private void initView(View root) {
        TextView tvBtnJoin = root.findViewById(R.id.tv_btn_join);
        tvBtnJoin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mListener != null) {
                    SimpleEvent event = new SimpleEvent(OnFragmentInteractionListener.EVENT_TYPE_CLICK_JOIN);
                    event.value = roleType;
                    mListener.onHomeFragmentEvent(event);
                }
            }
        });
        tvBtnRoleTeacher = root.findViewById(R.id.tv_select_role_teacher);
        tvBtnRoleAudience = root.findViewById(R.id.tv_select_role_audience);
        tvBtnRoleStudent = root.findViewById(R.id.tv_select_role_student);

        tvBtnRoleTeacher.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearRoleSelected();
                tvBtnRoleTeacher.setSelected(true);
            }
        });

        tvBtnRoleStudent.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearRoleSelected();
                tvBtnRoleStudent.setSelected(true);
            }
        });

        tvBtnRoleAudience.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearRoleSelected();
                tvBtnRoleAudience.setSelected(true);
            }
        });
    }

    private void clearRoleSelected() {
        tvBtnRoleTeacher.setSelected(false);
        tvBtnRoleStudent.setSelected(false);
        tvBtnRoleAudience.setSelected(false);
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
        int EVENT_TYPE_CLICK_JOIN = 100;

        void onHomeFragmentEvent(BaseEvent event);
    }
}
