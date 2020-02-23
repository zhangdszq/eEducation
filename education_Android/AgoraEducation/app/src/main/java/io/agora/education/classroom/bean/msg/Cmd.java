package io.agora.education.classroom.bean.msg;

public enum Cmd {

    MUTE_AUDIO(101),
    UNMUTE_AUDIO(102),
    MUTE_VIDEO(103),
    UNMUTE_VIDEO(104),
    APPLY(105),
    ACCEPT(106),
    REJECT(107),
    CANCEL(108),
    MUTE_CHAT(109),
    UNMUTE_CAHT(110),
    MUTE_BOARD(200),
    UNMUTE_BOARD(201);

    private int code;

    Cmd(int code) {
        this.code = code;
    }

    public static Cmd get(int code) {
        for (Cmd cmd : Cmd.values()) {
            if (cmd.code == code)
                return cmd;
        }
        return null;
    }

    public int getCode() {
        return code;
    }

}
