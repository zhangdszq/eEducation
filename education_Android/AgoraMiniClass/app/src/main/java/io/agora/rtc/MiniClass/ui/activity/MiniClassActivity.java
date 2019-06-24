package io.agora.rtc.MiniClass.ui.activity;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.ui.adapter.RcvStudentVideoListAdapter;
import io.agora.rtc.MiniClass.model.bean.StudentVideoBean;
import io.agora.rtc.MiniClass.model.event.AlertEvent;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.MiniClass.model.event.ShowToastEvent;
import io.agora.rtc.MiniClass.ui.fragment.ChatroomFragment;
import io.agora.rtc.MiniClass.ui.fragment.StudentListFrament;
import io.agora.rtc.MiniClass.ui.fragment.VideoCallFragment;
import io.agora.rtc.MiniClass.ui.fragment.WhiteBoardFragment;

public class MiniClassActivity extends AppCompatActivity implements
        WhiteBoardFragment.OnFragmentInteractionListener,
        ChatroomFragment.OnFragmentInteractionListener,
        StudentListFrament.OnFragmentInteractionListener,
        VideoCallFragment.OnFragmentInteractionListener {

    private TextView mTvTabChatRoom, mTvTabStudentList;
    private View mLineTabChatRoomBottom, mLineTabStudentListBottom;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mini_class);

        initVideoCallLayout();

        initWhiteBoardLayout();

        initIMLayout();
    }

    private void initVideoCallLayout() {
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_video_call_layout, VideoCallFragment.newInstance()).commit();
    }


    private void initIMLayout() {
        mTvTabChatRoom = findViewById(R.id.tv_tab_chatroom);
        mTvTabStudentList = findViewById(R.id.tv_tab_student_list);
        mLineTabChatRoomBottom = findViewById(R.id.line_tab_chat_room_bottom);
        mLineTabStudentListBottom = findViewById(R.id.line_tab_student_list_bottom);

        onClickTabChatRoom(mTvTabChatRoom);
    }

    private void initWhiteBoardLayout() {
        getSupportFragmentManager().beginTransaction().replace(R.id.fl_white_board_layout, WhiteBoardFragment.newInstance(null)).commit();
    }

    @Override
    public void onWhiteBoardFragmentEvent(BaseEvent event) {
        if (event instanceof AlertEvent) {
            final AlertEvent alertEvent = (AlertEvent) event;
            runOnUiThread(new Runnable() {
                public void run() {
                    AlertDialog alertDialog = new AlertDialog.Builder(MiniClassActivity.this).create();
                    alertDialog.setTitle(alertEvent.title);
                    alertDialog.setMessage(alertEvent.detail);
                    alertDialog.setButton(AlertDialog.BUTTON_NEUTRAL, "OK",
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                    finish();
                                }
                            });
                    alertDialog.show();
                }
            });
        } else if (event instanceof ShowToastEvent) {
            ShowToastEvent toastEvent = (ShowToastEvent) event;
            Toast.makeText(this, toastEvent.content, Toast.LENGTH_SHORT).show();
        }
    }


    public void onClickTabStudentList(View view) {

        mTvTabChatRoom.setSelected(false);
        mTvTabStudentList.setSelected(true);
        mLineTabChatRoomBottom.setVisibility(View.VISIBLE);
        mLineTabStudentListBottom.setVisibility(View.INVISIBLE);

        getSupportFragmentManager().beginTransaction().replace(R.id.fl_im, StudentListFrament.newInstance()).commit();
    }

    public void onClickTabChatRoom(View view) {

        mTvTabChatRoom.setSelected(true);
        mTvTabStudentList.setSelected(false);
        mLineTabChatRoomBottom.setVisibility(View.INVISIBLE);
        mLineTabStudentListBottom.setVisibility(View.VISIBLE);

        getSupportFragmentManager().beginTransaction().replace(R.id.fl_im, ChatroomFragment.newInstance()).commit();
    }

    @Override
    public void onChatRoomFragmentEvent(BaseEvent event) {

    }

    @Override
    public void onStudentListFragmentEvent(BaseEvent event) {

    }

    @Override
    public void onVideoCallFragmentEvent(BaseEvent event) {

    }
}
