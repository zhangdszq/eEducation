package io.agora.education.classroom.strategy.context;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Collections;
import java.util.List;

import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.education.R;
import io.agora.education.classroom.bean.msg.Cmd;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.bean.user.Teacher;
import io.agora.education.classroom.bean.user.User;
import io.agora.education.classroom.strategy.ChannelStrategy;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtcManager;

public class LargeClassContext extends ClassContext {

    private boolean applying;

    LargeClassContext(Context context, ChannelStrategy strategy) {
        super(context, strategy);
    }

    @Override
    public void checkChannelEnterable(@NonNull Callback<Boolean> callback) {
        callback.onSuccess(true);
    }

    @Override
    void preConfig() {
        RtcManager.instance().setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_AUDIENCE);
        RtcManager.instance().enableDualStreamMode(false);
    }

    @Override
    public void onTeacherChanged(Teacher teacher) {
        super.onTeacherChanged(teacher);
        if (classEventListener instanceof LargeClassEventListener) {
            runListener(() -> {
                LargeClassEventListener listener = (LargeClassEventListener) classEventListener;
                listener.onLinkUidChanged(teacher.link_uid);
                listener.onTeacherMediaChanged(teacher);
            });
            if (teacher.link_uid == 0) {
                runListener(() -> ((LargeClassEventListener) classEventListener).onLinkMediaChanged(null));
            } else {
                onLinkMediaChanged(channelStrategy.getAllStudents());
            }
        }
    }

    @Override
    public void onLocalChanged(Student local) {
        super.onLocalChanged(local);
        if (local.isGenerate) return;
        if (applying) {
            applying = false;
            // send apply order to the teacher when local attributes updated
            apply(false);
        }
        onLinkMediaChanged(Collections.singletonList(local));
    }

    @Override
    public void onStudentsChanged(List<Student> students) {
        super.onStudentsChanged(students);
        onLinkMediaChanged(students);
    }

    private void onLinkMediaChanged(List users) {
        Teacher teacher = channelStrategy.getTeacher();
        if (teacher == null) return;
        for (Object object : users) {
            if (object instanceof User) {
                User user = (User) object;
                if (user.uid == teacher.link_uid) {
                    if (classEventListener instanceof LargeClassEventListener) {
                        runListener(() -> ((LargeClassEventListener) classEventListener).onLinkMediaChanged(user));
                    }
                    break;
                }
            }
        }
    }

    @Override
    public void onPeerMsgReceived(PeerMsg msg) {
        super.onPeerMsgReceived(msg);
        Cmd cmd = msg.getCmd();
        if (cmd == null) return;
        switch (cmd) {
            case ACCEPT:
                accept();
                break;
            case REJECT:
                reject();
                break;
            case CANCEL:
                cancel(true);
                break;
        }
    }

    public void apply(boolean isPrepare) {
        if (isPrepare) {
            channelStrategy.clearLocalAttribute(new Callback<Void>() {
                @Override
                public void onSuccess(Void aVoid) {
                    channelStrategy.updateLocalAttribute(channelStrategy.getLocal(), new Callback<Void>() {
                        @Override
                        public void onSuccess(Void aVoid) {
                            applying = true;
                        }

                        @Override
                        public void onFailure(Throwable throwable) {
                            applying = false;
                        }
                    });
                }

                @Override
                public void onFailure(Throwable throwable) {

                }
            });
        } else {
            Teacher teacher = channelStrategy.getTeacher();
            if (teacher != null) {
                teacher.sendMessageTo(Cmd.APPLY);
            }
        }
    }

    @Override
    public void onMemberCountUpdated(int count) {
        super.onMemberCountUpdated(count);
        if (classEventListener instanceof LargeClassEventListener) {
            runListener(() -> ((LargeClassEventListener) classEventListener).onUserCountChanged(count));
        }
    }

    public void cancel(boolean isRemote) {
        channelStrategy.clearLocalAttribute(new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_AUDIENCE);
                if (isRemote) {
                    if (classEventListener instanceof LargeClassEventListener) {
                        runListener(() -> ((LargeClassEventListener) classEventListener).onHandUpCanceled());
                    }
                } else {
                    Teacher teacher = channelStrategy.getTeacher();
                    if (teacher != null) {
                        teacher.sendMessageTo(Cmd.CANCEL);
                    }
                }
            }

            @Override
            public void onFailure(Throwable throwable) {

            }
        });
    }

    private void accept() {
        Student local = channelStrategy.getLocal();
        local.audio = 1;
        local.video = 1;
        channelStrategy.updateLocalAttribute(local, new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                RtcManager.instance().setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
            }

            @Override
            public void onFailure(Throwable throwable) {

            }
        });
        ToastManager.showShort(R.string.accept_interactive);
    }

    private void reject() {
        channelStrategy.clearLocalAttribute(new Callback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                applying = false;
            }

            @Override
            public void onFailure(Throwable throwable) {

            }
        });
        ToastManager.showShort(R.string.reject_interactive);
    }

    public interface LargeClassEventListener extends ClassEventListener {
        void onUserCountChanged(int count);

        void onTeacherMediaChanged(User user);

        void onLinkMediaChanged(User user);

        void onLinkUidChanged(int uid);

        void onHandUpCanceled();
    }

}
