package io.agora.education.classroom.strategy;

import java.util.List;

import io.agora.education.classroom.bean.msg.ChannelMsg;
import io.agora.education.classroom.bean.msg.PeerMsg;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.bean.user.Teacher;

public interface ChannelEventListener {

    void onChannelInfoInit();

    void onLocalChanged(Student local);

    void onTeacherChanged(Teacher teacher);

    void onStudentsChanged(List<Student> students);

    void onChannelMsgReceived(ChannelMsg msg);

    void onPeerMsgReceived(PeerMsg msg);

    void onMemberCountUpdated(int count);

}
