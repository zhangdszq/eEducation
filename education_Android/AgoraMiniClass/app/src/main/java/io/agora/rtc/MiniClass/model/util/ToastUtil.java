package io.agora.rtc.MiniClass.model.util;

import android.support.annotation.StringRes;
import android.widget.Toast;

import io.agora.rtc.MiniClass.AGApplication;

public class ToastUtil {
    public static void showShort(String msg) {
        Toast.makeText(AGApplication.the(), msg, Toast.LENGTH_SHORT).show();
    }
    public static void showShort(@StringRes int msg) {
        Toast.makeText(AGApplication.the(), msg, Toast.LENGTH_SHORT).show();
    }
}
