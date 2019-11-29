package io.agora.rtc.education.room.onetoone;

import android.os.Bundle;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.room.fragment.ChatroomFragment;
import io.agora.rtc.education.room.fragment.WhiteboardFragment;
import io.agora.rtc.education.room.view.UserVideoItem;
import io.agora.rtc.education.widget.dialog.ConfirmDialogFragment;

public class OneToOneActivity extends BaseActivity {

    private ImageView mIcWifi;
    private ImageView mIcClose;
    private TextView mTvRoomName;
    private TextView mTvTime;
    private LinearLayout mLayoutTime;
    private UserVideoItem mVideoItemTeacher;
    private UserVideoItem mVideoItemStudent;
    private FrameLayout mFlChatRoom;
    private RelativeLayout mLayoutChatRoom;
    private ImageView mIcShowIm;

    private ChatroomFragment chatroomFragment;
    protected WhiteboardFragment whiteboardFragment;

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_one_to_one);
        mIcWifi = findViewById(R.id.ic_wifi);
        mIcClose = findViewById(R.id.ic_close);
        mTvRoomName = findViewById(R.id.tv_room_name);
        mTvTime = findViewById(R.id.tv_time);
        mLayoutTime = findViewById(R.id.layout_time);
        mVideoItemTeacher = findViewById(R.id.video_item_teacher);
        mVideoItemStudent = findViewById(R.id.video_item_student);
        mFlChatRoom = findViewById(R.id.fl_chat_room);
        mLayoutChatRoom = findViewById(R.id.layout_chat_room);
        mIcShowIm = findViewById(R.id.ic_show_im);

        chatroomFragment = ChatroomFragment.newInstance();
        whiteboardFragment = WhiteboardFragment.newInstance(false);
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.fl_chat_room, chatroomFragment)
                .add(R.id.layout_whiteboard, whiteboardFragment)
                .commit();

        mIcClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
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
            }
        });

        mVideoItemTeacher.showVideoIcon(false);
        mVideoItemStudent.setOnClickAudioListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });

        mVideoItemStudent.setOnClickVideoListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
    }
}
