package io.agora.rtc.education.data;

import com.google.gson.Gson;

import java.util.ArrayList;

import io.agora.rtc.education.data.bean.Student;
import io.agora.rtc.education.data.bean.Teacher;

public class ChannelDataRepository implements ChannelDataReadOnly {

    private volatile Student myAttr;
    private volatile Teacher teacher;
    private volatile ArrayList<Student> students;
    private Gson gson = new Gson();

    public Student getMyAttr() {
        return myAttr;
    }

    public String getMyAttrJson() {
        return gson.toJson(myAttr);
    }

    public void setMyAttr(Student myAttr) {
        if (this.myAttr != null && students != null) {
            students.remove(this.myAttr);
        }
        this.myAttr = myAttr;
    }

    @Override
    public Teacher getTeacher() {
        return teacher;
    }

    public void setTeacher(Teacher teacher) {
        this.teacher = teacher;
    }

    public ArrayList<Student> getStudents() {
        return students;
    }

    public void setStudents(ArrayList<Student> students) {
        this.students = students;
    }

    public void resetData() {
        teacher = null;
        students = null;
    }

    public Student getStudent(int uid) {
        if (students == null || students.isEmpty()) {
            return null;
        }
        for (Student s :
                students) {
            if (s.getUid() == uid) {
                return s;
            }
        }
        return null;
    }

}
