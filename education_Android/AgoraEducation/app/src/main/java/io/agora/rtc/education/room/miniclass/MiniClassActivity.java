package io.agora.rtc.education.room.miniclass;

import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.fragment.app.FragmentTransaction;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.room.fragment.ChatroomFragment;
import io.agora.rtc.education.room.fragment.StudentListFrament;
import io.agora.rtc.education.room.fragment.WhiteboardFragment;
import io.agora.rtc.education.widget.dialog.ConfirmDialogFragment;

public class MiniClassActivity extends BaseActivity implements View.OnClickListener {

    private ImageView mIcWifi;
    private ImageView mIcClose;
    private TextView mTvRoomName;
    private TextView mTvTime;
    private LinearLayout mLayoutTime;
    private ListView mLvVideos;
    private View mLine1;
    private View mLine2;
    private FrameLayout mFlChatRoom;
    private ConstraintLayout mLayoutIm;
    private FrameLayout mLayoutWhiteboard;
    private ImageView mIcShowIm;
    private TextView mTvBtnChatRoom;
    private TextView mTvBtnStudent;

    private WhiteboardFragment whiteboardFragment;
    private ChatroomFragment chatroomFragment;
    private StudentListFrament studentListFrament;

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_mini_class);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcClose = findViewById(R.id.ic_close);
        mTvRoomName = findViewById(R.id.tv_room_name);
        mTvTime = findViewById(R.id.tv_time);
        mLayoutTime = findViewById(R.id.layout_time);
        mLvVideos = findViewById(R.id.lv_videos);
        mLine1 = findViewById(R.id.line_1);
        mLine2 = findViewById(R.id.line_2);
        mFlChatRoom = findViewById(R.id.fl_chat_room);
        mLayoutIm = findViewById(R.id.layout_im);
        mLayoutWhiteboard = findViewById(R.id.layout_whiteboard);
        mIcShowIm = findViewById(R.id.ic_show_im);
        mTvBtnChatRoom = findViewById(R.id.tv_btn_chat_room);
        mTvBtnStudent = findViewById(R.id.tv_btn_student);

        mIcClose.setOnClickListener(this);
        mIcShowIm.setOnClickListener(this);
        mTvBtnChatRoom.setOnClickListener(this);
        mTvBtnStudent.setOnClickListener(this);
    }

    @Override
    protected void initData() {
        whiteboardFragment = WhiteboardFragment.newInstance(false);
        studentListFrament = StudentListFrament.newInstance();
        chatroomFragment = ChatroomFragment.newInstance();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.layout_whiteboard, whiteboardFragment)
                .add(R.id.fl_chat_room, chatroomFragment)
                .add(R.id.fl_chat_room, studentListFrament)
                .hide(studentListFrament)
                .show(chatroomFragment)
                .commit();
    }

    @Override
    public void onClick(View v) {
        if (v == null) {
            return;
        }
        switch (v.getId()) {
            case R.id.ic_close:
                ConfirmDialogFragment.newInstance(new ConfirmDialogFragment.DialogClickListener() {
                    @Override
                    public void clickConfirm() {
                        finish();
                    }

                    @Override
                    public void clickCancel() {
                    }
                }, getString(R.string.confirm_leave_room_content))
                        .show(getSupportFragmentManager(), "leave");
                break;
            case R.id.ic_show_im:
                mIcShowIm.setSelected(!mIcShowIm.isSelected());
                if (mIcShowIm.isSelected()) {
                    mLayoutIm.setVisibility(View.GONE);
                } else {
                    mLayoutIm.setVisibility(View.VISIBLE);
                }
                break;
            case R.id.tv_btn_chat_room:
                showChatRoom(true);
                break;
            case R.id.tv_btn_student:
                showChatRoom(false);
                break;
        }
    }

    private void showChatRoom(boolean isShow) {
        mLine1.setVisibility(isShow ? View.VISIBLE : View.INVISIBLE);
        mLine2.setVisibility(isShow ? View.INVISIBLE : View.VISIBLE);
        mTvBtnChatRoom.setSelected(isShow);
        mTvBtnStudent.setSelected(!isShow);
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.hide(studentListFrament).hide(chatroomFragment)
                .show(isShow ? chatroomFragment : studentListFrament).commit();
    }
}
