package io.agora.rtc.education.data;

import android.text.TextUtils;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.agora.rtc.education.constant.Constant;
import io.agora.rtc.education.data.bean.Student;
import io.agora.rtc.education.data.bean.Teacher;
import io.agora.rtc.lib.util.LogUtil;
import io.agora.rtm.RtmChannelAttribute;

public class ChannelDataRepository implements ChannelDataReadOnly {
    private volatile Student myAttr;
    private volatile Teacher teacher;
    private volatile ArrayList<Student> students;
    private Gson gson = new Gson();
    private LogUtil log = new LogUtil("ChannelDataRepository");

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

    public void parseChannelAttributes(List<RtmChannelAttribute> attributes) {
        log.i("parseChannelAttributes:");
        if (attributes == null || attributes.isEmpty()) {
            resetData();
            return;
        }

        String teacherJson = null;
        Map<String, String> studentAttributesMap = new LinkedHashMap<>();
        for (RtmChannelAttribute attribute : attributes) {
            String key = attribute.getKey();
            String value = attribute.getValue();
            if (!TextUtils.isEmpty(key) && !TextUtils.isEmpty(value)) {
                if (key.equals(Constant.RTM_CHANNEL_KEY_TEACHER)) {
                    teacherJson = value;
                } else {
                    studentAttributesMap.put(attribute.getKey(), attribute.getValue());
                }
            }
        }

        if (studentAttributesMap.isEmpty() || studentAttributesMap.get(String.valueOf(myAttr.uid)) == null) {
            // 第一次得到数据不包含自己，等待有自己的数据后再渲染出来
            resetData();
            return;
        }

        if (TextUtils.isEmpty(teacherJson)) {
            // 老师不在房间
            teacher = null;
        } else {
            // 老师在房间
            try {
                teacher = gson.fromJson(teacherJson, Teacher.class);
            } catch (Exception e) {
                teacher = null;
            }
        }

        students = new ArrayList<>();

        if (!studentAttributesMap.isEmpty()) {
            for (String key : studentAttributesMap.keySet()) {
                Student s;
                try {
                    s = gson.fromJson(studentAttributesMap.get(key), Student.class);
                    s.uid = Integer.parseInt(key);
                } catch (Exception e) {
                    s = null;
                }
                if (s != null) {
                    students.add(s);
                }
            }
        }
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
