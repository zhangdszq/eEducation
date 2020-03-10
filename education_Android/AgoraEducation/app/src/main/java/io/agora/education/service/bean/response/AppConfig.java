package io.agora.education.service.bean.response;

import com.google.gson.annotations.SerializedName;

import java.util.Map;

public class AppConfig {

    public int version;
    public String appId;
    public String authorization;
    @SerializedName("1on1TeacherLimit")
    public int one2OneTeacherLimit;
    @SerializedName("1on1StudentLimit")
    public int one2OneStudentLimit;
    public int smallClassTeacherLimit;
    public int smallClassStudentLimit;
    public int largeClassTeacherLimit;
    public int largeClassStudentLimit;
    public Map<String, Map<Integer, String>> multiLanguage;

}
