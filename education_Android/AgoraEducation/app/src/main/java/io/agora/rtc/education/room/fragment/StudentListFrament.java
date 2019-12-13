package io.agora.rtc.education.room.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.NonNull;

import java.util.ArrayList;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseFragment;
import io.agora.rtc.education.base.BaseListAdapter;
import io.agora.rtc.education.data.bean.User;
import io.agora.rtc.education.im.IMStrategy;


public class StudentListFrament extends BaseFragment {

    private ListView mLvStudents;
    private StudentListAdapter mAdapter;
    private int myUid;
    private IMStrategy mImStrategy;

    public void setMyUid(int myUid) {
        this.myUid = myUid;
    }

    public void setImStrategy(IMStrategy imStrategy) {
        this.mImStrategy = imStrategy;
    }

    public StudentListFrament() {
    }

    public static StudentListFrament newInstance() {
        StudentListFrament fragment = new StudentListFrament();
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_student_list, container, false);

        mLvStudents = root.findViewById(R.id.lv_students);
        mAdapter = new StudentListAdapter();
        mLvStudents.setAdapter(mAdapter);
        return root;
    }

    public void setList(ArrayList<User> users) {
        mAdapter.setList(users);
        mAdapter.notifyDataSetChanged();
    }

    private class StudentListAdapter extends BaseListAdapter<User> {

        @Override
        protected void onBindViewHolder(BaseViewHolder viewHolder, User user, int position) {
            final MyViewHolder vH = (MyViewHolder) viewHolder;
            vH.tvName.setText(user.account);
            if (myUid == user.getUid()) {
                vH.ivBtnMuteAudio.setVisibility(View.VISIBLE);
                vH.ivBtnMuteVideo.setVisibility(View.VISIBLE);
                vH.ivBtnMuteAudio.setSelected(user.audio == 1);
                vH.ivBtnMuteVideo.setSelected(user.video == 1);
                vH.ivBtnMuteAudio.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mImStrategy.muteLocalAudio(v.isSelected());
                    }
                });
                vH.ivBtnMuteVideo.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mImStrategy.muteLocalVideo(v.isSelected());
                    }
                });
            } else {
                vH.ivBtnMuteVideo.setVisibility(View.GONE);
                vH.ivBtnMuteAudio.setVisibility(View.GONE);
            }
        }

        @Override
        protected BaseViewHolder onCreateViewHolder(int itemViewType, ViewGroup parent) {
            return new MyViewHolder(
                    LayoutInflater.from(parent.getContext())
                            .inflate(R.layout.item_student_list, parent, false)
            );
        }
    }

    public static class MyViewHolder extends BaseListAdapter.BaseViewHolder {
        TextView tvName;
        ImageView ivBtnMuteAudio;
        ImageView ivBtnMuteVideo;

        public MyViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName = itemView.findViewById(R.id.tv_name);
            ivBtnMuteAudio = itemView.findViewById(R.id.iv_btn_mute_audio);
            ivBtnMuteVideo = itemView.findViewById(R.id.iv_btn_mute_video);
        }
    }
}
