package io.agora.rtc.education.data;

import java.util.ArrayList;

import io.agora.rtc.education.data.bean.Student;
import io.agora.rtc.education.data.bean.Teacher;

public interface ChannelDataReadOnly {

    Teacher getTeacher();

    ArrayList<Student> getStudents();

    Student getMyAttr();

    Student getStudent(int uid);
}
