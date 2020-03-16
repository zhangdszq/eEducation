package io.agora.education.classroom.strategy.context;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.education.EduApplication;
import io.agora.education.R;
import io.agora.education.classroom.bean.msg.Cmd;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.bean.user.Teacher;
import io.agora.education.classroom.bean.user.User;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtcManager;

public class SmallClassContext extends ClassContext {

    SmallClassContext(Context context, ChannelStrategy strategy) {
        super(context, strategy);
    }

    @Override
    public void checkChannelEnterable(@NonNull Callback<Boolean> callback) {
        channelStrategy.queryChannelInfo(new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                channelStrategy.queryOnlineStudentNum(new Callback<Integer>() {
                    @Override
                    public void onSuccess(Integer integer) {
                        callback.onSuccess(integer < EduApplication.instance.config.smallClassStudentLimit);
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        callback.onFailure(throwable);
                    }
                });
            }

            @Override
            public void onFailure(Throwable throwable) {
                callback.onFailure(throwable);
            }
        });
    }

    @Override
    void preConfig() {
        RtcManager.instance().setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
        // enable dual stream mode in small class
        RtcManager.instance().enableDualStreamMode(true);
        RtcManager.instance().setRemoteDefaultVideoStreamType(Constants.VIDEO_STREAM_LOW);
    }

    @Override
    public void onPeerMsgReceived(PeerMsg msg) {
        super.onPeerMsgReceived(msg);
        Cmd cmd = msg.getCmd();
        if (cmd == null) return;
        switch (cmd) {
            case MUTE_BOARD:
                muteBoard(true);
                break;
            case UNMUTE_BOARD:
                muteBoard(false);
                break;
        }
    }

    private void muteBoard(boolean muted) {
        Student local = channelStrategy.getLocal();
        local.grant_board = muted ? 0 : 1;
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void res) {
                ToastManager.showShort(muted ? R.string.revoke_board : R.string.authorize_board);
            }

            @Override
            public void onFailure(Throwable throwable) {

            }
        });
    }

    @Override
    public void onChannelInfoInit() {
        super.onChannelInfoInit();
        if (channelStrategy.getLocal().isGenerate) {
            channelStrategy.updateLocalAttribute(channelStrategy.getLocal(), null);
        }
    }

    @Override
    public void onTeacherChanged(Teacher teacher) {
        super.onTeacherChanged(teacher);
        // teacher need set high stream type
        RtcManager.instance().setRemoteVideoStreamType(teacher.uid, Constants.VIDEO_STREAM_HIGH);
        onUsersMediaChanged();
    }

    @Override
    public void onLocalChanged(Student local) {
        super.onLocalChanged(local);
        onUsersMediaChanged();
        if (classEventListener instanceof SmallClassEventListener) {
            runListener(() -> ((SmallClassEventListener) classEventListener).onGrantWhiteboard(local.grant_board == 0));
        }
    }

    @Override
    public void onStudentsChanged(List<Student> students) {
        super.onStudentsChanged(students);
        onUsersMediaChanged();
    }

    private void onUsersMediaChanged() {
        if (classEventListener instanceof SmallClassEventListener) {
            List<User> users = new ArrayList<>();
            for (Object object : channelStrategy.getAllUsers()) {
                if (object instanceof User) {
                    users.add((User) object);
                }
            }
            runListener(() -> ((SmallClassEventListener) classEventListener).onUsersMediaChanged(users));
        }
    }

    public interface SmallClassEventListener extends ClassEventListener {
        void onUsersMediaChanged(List<User> users);

        void onGrantWhiteboard(boolean granted);
    }

}
