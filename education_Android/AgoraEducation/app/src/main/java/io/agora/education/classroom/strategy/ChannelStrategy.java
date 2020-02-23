package io.agora.education.classroom.strategy;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;

import io.agora.base.Callback;
import io.agora.base.LogManager;
import io.agora.education.classroom.bean.channel.ChannelInfo;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.bean.user.Teacher;
import io.agora.education.classroom.bean.user.User;
import io.agora.sdk.listener.RtcEventListener;
import io.agora.sdk.manager.RtcManager;

public abstract class ChannelStrategy<T> {

    private final LogManager log = new LogManager(this.getClass().getName());

    private String channelId;
    private ChannelInfo channelInfo;
    private List<Integer> rtcUsers;
    ChannelEventListener channelEventListener;

    ChannelStrategy(String channelId, Student local) {
        this.channelId = channelId;
        channelInfo = new ChannelInfo(local);
        rtcUsers = new ArrayList<>();
        RtcManager.instance().registerListener(rtcEventListener);
    }

    public String getChannelId() {
        return channelId;
    }

    public Student getLocal() {
        try {
            return channelInfo.local.clone();
        } catch (Exception e) {
            return new Student(true);
        }
    }

    void setLocal(Student local) {
        String json = local.toJsonString();
        if (getLocal().isGenerate == local.isGenerate && TextUtils.equals(json, getLocal().toJsonString())) {
            return;
        }
        log.d("setLocal %s", json);
        channelInfo.local = local;
        if (channelEventListener != null) {
            channelEventListener.onLocalChanged(getLocal());
        }
    }

    public Teacher getTeacher() {
        return channelInfo.teacher;
    }

    protected void setTeacher(Teacher teacher) {
        String json = teacher.toJsonString();
        if (TextUtils.equals(json, new Gson().toJson(getTeacher()))) {
            return;
        }
        log.d("setTeacher %s", json);
        channelInfo.teacher = teacher;
        checkRtcOnline(channelInfo.teacher);
        if (channelEventListener != null) {
            channelEventListener.onTeacherChanged(getTeacher());
        }
    }

    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        if (getTeacher() != null) {
            users.add(getTeacher());
        }
        users.addAll(getAllStudents());
        return users;
    }

    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        if (!getLocal().isGenerate)
            students.add(0, getLocal());
        students.addAll(getStudents());
        return students;
    }

    public List<Student> getStudents() {
        return channelInfo.students;
    }

    void setStudents(List<Student> students) {
        Gson gson = new Gson();
        String json = gson.toJson(students);
        if (TextUtils.equals(json, gson.toJson(getStudents()))) {
            return;
        }
        log.d("setStudents %s", json);
        channelInfo.students.clear();
        channelInfo.students.addAll(students);
        checkStudentsRtcOnline();
    }

    private void checkRtcOnline(User user) {
        user.isRtcOnline = rtcUsers.contains(user.uid);
    }

    private void checkStudentsRtcOnline() {
        for (Student student : getStudents()) {
            checkRtcOnline(student);
        }
        if (channelEventListener != null) {
            channelEventListener.onStudentsChanged(getStudents());
        }
    }

    public void setChannelEventListener(ChannelEventListener listener) {
        channelEventListener = listener;
    }

    public void release() {
        channelEventListener = null;
        RtcManager.instance().unregisterListener(rtcEventListener);
    }

    public abstract void joinChannel(String rtcToken);

    public abstract void leaveChannel();

    public abstract void queryOnlineStudentNum(@NonNull Callback<Integer> callback);

    public abstract void queryChannelInfo(@Nullable Callback<Void> callback);

    public abstract void parseChannelInfo(T data);

    public abstract void updateLocalAttribute(Student local, @Nullable Callback<Void> callback);

    public abstract void clearLocalAttribute(@Nullable Callback<Void> callback);

    private RtcEventListener rtcEventListener = new RtcEventListener() {
        @Override
        public void onUserJoined(int uid, int elapsed) {
            if (uid != ChannelInfo.SHARE_UID) {
                rtcUsers.add(uid);
                checkStudentsRtcOnline();
            }
        }

        @Override
        public void onUserOffline(int uid, int reason) {
            if (uid != ChannelInfo.SHARE_UID) {
                rtcUsers.remove(Integer.valueOf(uid));
                checkStudentsRtcOnline();
            }
        }
    };

}
