package io.agora.rtc.education.constant;

public enum Role {
//    AUDIENCE(0),
    STUDENT(1),
    TEACHER(2);
    int value;

    Role(int value) {
        this.value = value;
    }

    public int intValue() {
        return value;
    }

    public String strValue() {
        return String.valueOf(value);
    }
}
