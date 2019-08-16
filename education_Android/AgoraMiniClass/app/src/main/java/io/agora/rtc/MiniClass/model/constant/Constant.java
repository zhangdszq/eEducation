package io.agora.rtc.MiniClass.model.constant;

public class Constant {

    public static final String BASE_URL = your_base_url;

    public static final int MAX_INPUT_NAME_LENGTH = 64;

    public enum Role {
        AUDIENCE(0),
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


}
