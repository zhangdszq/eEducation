package io.agora.rtc.MiniClass.model.bean;

public class MsgBean {
    public static final int TYPE_STUDENT = 0;
    public static final int TYPE_TEACHER = 1;

    private int userType;
    public String name;
    public String content;

    public MsgBean(int userType, String name, String content) {
        this.userType = userType;
        this.name = name;
        this.content = content;
    }

    public void setUserType(int userType) {
        if (userType > 1)
            userType = TYPE_STUDENT;
        this.userType = userType;
    }

    public int getUserType() {
        return userType;
    }
}
