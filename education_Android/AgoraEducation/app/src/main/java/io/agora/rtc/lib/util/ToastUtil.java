package io.agora.rtc.lib.util;

import android.app.Activity;
import android.content.Context;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.StringRes;
import androidx.core.content.ContextCompat;

public class ToastUtil {

    private static Context mContext;

    public static void init(Context context) {
        mContext = context;
    }

    public static void showShort(String msg) {
        Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
    }

    public static void showShort(@StringRes int msg) {
        Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
    }

    public static void showErrorShort(Context context, @StringRes int msg, int textColor) {
        if (context == null) {
            return;
        }
        Toast toast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
        TextView textView = new TextView(context);
        textView.setTextColor(ContextCompat.getColor(context, textColor));
        textView.setTextSize(18);
        textView.setText(msg);
        toast.setView(textView);
        toast.show();
    }

    public static void showErrorShort(Context context, String msg, int textColor) {
        if (context == null) {
            return;
        }
        Toast toast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
        TextView textView = new TextView(context);
        textView.setTextColor(ContextCompat.getColor(context, textColor));
        textView.setTextSize(18);
        textView.setText(msg);
        toast.setView(textView);
        toast.show();
    }

    public static void showErrorShortFromSubThread(final Activity activity, @StringRes final int msg, final int textColor) {
        if (activity == null || activity.isFinishing()) {
            return;
        }
        activity.runOnUiThread(() -> {
            if (activity.isFinishing()) {
                return;
            }
            Toast toast = Toast.makeText(activity, msg, Toast.LENGTH_SHORT);
            TextView textView = new TextView(activity);
            textView.setTextColor(ContextCompat.getColor(activity, textColor));
            textView.setTextSize(18);
            textView.setText(msg);
            toast.setView(textView);
            toast.show();
        });
    }

}
