package io.agora.education.classroom;

import android.view.View;

import androidx.fragment.app.FragmentTransaction;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.tabs.TabLayout;

import java.util.List;

import butterknife.BindView;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.classroom.adapter.ClassVideoAdapter;
import io.agora.education.classroom.annotation.ClassType;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.bean.user.User;
import io.agora.education.classroom.fragment.UserListFragment;
import io.agora.education.classroom.strategy.context.SmallClassContext;
import io.agora.rtc.Constants;

public class SmallClassActivity extends BaseClassActivity implements SmallClassContext.SmallClassEventListener, TabLayout.OnTabSelectedListener {

    @BindView(R.id.rcv_videos)
    protected RecyclerView rcv_videos;
    @BindView(R.id.layout_im)
    protected View layout_im;
    @BindView(R.id.layout_tab)
    protected TabLayout layout_tab;

    private ClassVideoAdapter adapter;
    private UserListFragment userListFragment;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_small_class;
    }

    @Override
    protected void initData() {
        super.initData();
        adapter = new ClassVideoAdapter(getMyUserId());
    }

    @Override
    protected void initView() {
        super.initView();
        LinearLayoutManager layoutManager = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
        rcv_videos.setLayoutManager(layoutManager);
        rcv_videos.setAdapter(adapter);

        layout_tab.addOnTabSelectedListener(this);

        userListFragment = new UserListFragment();
        getSupportFragmentManager().beginTransaction()
                .add(R.id.layout_chat_room, userListFragment)
                .hide(userListFragment)
                .commit();
    }

    @Override
    protected Student getLocal() {
        return new Student(getMyUserId(), getMyUserName(), Constants.CLIENT_ROLE_BROADCASTER);
    }

    @Override
    protected int getClassType() {
        return ClassType.SMALL;
    }

    @OnClick(R.id.iv_float)
    public void onClick(View view) {
        boolean isSelected = view.isSelected();
        view.setSelected(!isSelected);
        layout_im.setVisibility(isSelected ? View.VISIBLE : View.GONE);
    }

    @Override
    public void onUsersMediaChanged(List<User> users) {
        adapter.setUsers(users);
        userListFragment.setUserList(users);
    }

    @Override
    public void onBoardMuteStatusChanged(boolean muted) {
        whiteboardFragment.disableDeviceInputs(muted);
    }

    @Override
    public void onTabSelected(TabLayout.Tab tab) {
        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        if (tab.getPosition() == 0) {
            transaction.show(chatRoomFragment).hide(userListFragment);
        } else {
            transaction.show(userListFragment).hide(chatRoomFragment);
        }
        transaction.commit();
    }

    @Override
    public void onTabUnselected(TabLayout.Tab tab) {

    }

    @Override
    public void onTabReselected(TabLayout.Tab tab) {

    }

}
