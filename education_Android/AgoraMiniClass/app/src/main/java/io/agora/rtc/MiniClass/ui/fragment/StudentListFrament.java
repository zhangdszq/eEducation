package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.bean.Mute;
import io.agora.rtc.MiniClass.model.bean.RtmRoomControl;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.MuteEvent;
import io.agora.rtc.MiniClass.model.event.UpdateMembersEvent;
import io.agora.rtc.MiniClass.model.util.ToastUtil;
import io.agora.rtc.MiniClass.ui.adapter.RcvStudentListAdapter;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;


public class StudentListFrament extends BaseFragment {

    private RecyclerView mRcvMsg;
    private RcvStudentListAdapter mRcvAdapter;

    private TextView mTvBtnMuteAll, mTvBtnUnMuteAll;

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
        mTvBtnMuteAll = root.findViewById(R.id.tv_btn_mute_all);
        mTvBtnUnMuteAll = root.findViewById(R.id.tv_btn_unmute_all);

        if (isNeedShowMuteButton)
            showMuteUI();

        mRcvMsg = root.findViewById(R.id.rcv_student_list);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager((Context) mListener, LinearLayoutManager.VERTICAL, false);
        mRcvMsg.setLayoutManager(linearLayoutManager);
        if (mRcvAdapter == null)
            mRcvAdapter = new RcvStudentListAdapter();
        mRcvMsg.setAdapter(mRcvAdapter);

        return root;
    }

    @Override
    public void onActivityMainThreadEvent(BaseEvent event) {
        if (event instanceof UpdateMembersEvent) {
            UpdateMembersEvent myEvent = (UpdateMembersEvent) event;
            if (myEvent.getTeacherAttr() != null && UserConfig.getRtmUserId().equals(myEvent.getTeacherAttr().streamId)) {
                showMuteUI();
            }

            if (mRcvAdapter == null) {
                mRcvAdapter = new RcvStudentListAdapter();
                mRcvAdapter.setList(myEvent.getUserAttrList());
            } else {
                mRcvAdapter.setList(myEvent.getUserAttrList());
                mRcvAdapter.notifyDataSetChanged();
            }
        } else if (event instanceof MuteEvent) {
            MuteEvent muteEvent = (MuteEvent) event;
            RtmRoomControl.UserAttr attr = muteEvent.getUserAttr();
            if (attr != null) {
                mRcvAdapter.updateItemById(attr.streamId, attr);
            }
        }
    }

    private boolean isNeedShowMuteButton = false;

    private void showMuteUI() {
        if (mTvBtnUnMuteAll == null) {
            isNeedShowMuteButton = true;
            return;
        }
        mTvBtnUnMuteAll.setVisibility(View.VISIBLE);
        mTvBtnMuteAll.setVisibility(View.VISIBLE);
        mTvBtnMuteAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                muteAll(true);
            }
        });

        mTvBtnUnMuteAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                muteAll(false);
            }
        });
    }

    ResultCallback<Void> resultCallback = new ResultCallback<Void>() {
        @Override
        public void onSuccess(Void aVoid) {

        }

        @Override
        public void onFailure(ErrorInfo errorInfo) {
            ToastUtil.showErrorShortFromSubThread((Activity) mListener, R.string.send_message_failed);
        }
    };

    private void muteAll(boolean isMute) {
        List<RtmRoomControl.UserAttr> attrList = UserConfig.getStudentAttrsList();
        List<String> uidList = new ArrayList<>();
        for (RtmRoomControl.UserAttr attr: attrList) {
            uidList.add(attr.streamId);
        }
        rtmManager().muteArray(isMute, Mute.VIDEO, uidList, resultCallback);
        rtmManager().muteArray(isMute, Mute.AUDIO, uidList, resultCallback);
    }

}
