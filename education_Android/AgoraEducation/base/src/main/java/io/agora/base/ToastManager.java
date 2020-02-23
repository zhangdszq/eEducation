package io.agora.base;

import android.app.Application;
import android.os.Handler;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.ColorRes;
import androidx.annotation.StringRes;

public class ToastManager {

    private static Application context;
    private static Handler handler;

    public static void init(Application application) {
        ToastManager.context = application;
        handler = new Handler();
    }

    public static void showShort(@StringRes int stringResId) {
        showShort(context.getString(stringResId));
    }

    public static void showShort(String text) {
        handler.post(() -> Toast.makeText(context, text, Toast.LENGTH_SHORT).show());
    }

    public static void showErrorShort(@StringRes int stringResId, @ColorRes int colorResId) {
        showErrorShort(context.getResources().getString(stringResId), colorResId);
    }

    public static void showErrorShort(String text, @ColorRes int colorResId) {
        handler.post(() -> {
            Toast toast = Toast.makeText(context, text, Toast.LENGTH_SHORT);
            TextView textView = new TextView(context);
            textView.setTextColor(context.getResources().getColor(colorResId));
            textView.setTextSize(18);
            textView.setText(text);
            toast.setView(textView);
            toast.show();
        });
    }

}
