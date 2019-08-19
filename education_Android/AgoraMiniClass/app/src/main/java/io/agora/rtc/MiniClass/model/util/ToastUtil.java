package io.agora.rtc.MiniClass.model.util;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.StringRes;
import android.support.v4.content.ContextCompat;
import android.widget.TextView;
import android.widget.Toast;

import org.w3c.dom.Text;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.R;

public class ToastUtil {
    public static void showShort(String msg) {
        Toast.makeText(AGApplication.the(), msg, Toast.LENGTH_SHORT).show();
    }
    public static void showShort(@StringRes int msg) {
        Toast.makeText(AGApplication.the(), msg, Toast.LENGTH_SHORT).show();
    }

    public static void showErrorShort(Context context, @StringRes int msg) {
        if (context == null)
            return;
        Toast toast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
        TextView textView = new TextView(context);
        textView.setTextColor(ContextCompat.getColor(context, R.color.colorAccent));
        textView.setTextSize(18);
        textView.setText(msg);
        toast.setView(textView);
        toast.show();
    }
    public static void showErrorShort(Context context, String msg) {
        if (context == null)
            return;
        Toast toast = Toast.makeText(context, msg, Toast.LENGTH_SHORT);
        TextView textView = new TextView(context);
        textView.setTextColor(ContextCompat.getColor(context, R.color.colorAccent));
        textView.setTextSize(18);
        textView.setText(msg);
        toast.setView(textView);
        toast.show();
    }

    public static void showErrorShortFromSubThread(final Activity activity, @StringRes final int msg) {
        if (activity == null || activity.isFinishing())
            return;

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (activity.isFinishing())
                    return;

                Toast toast = Toast.makeText(activity, msg, Toast.LENGTH_SHORT);
                TextView textView = new TextView(activity);
                textView.setTextColor(ContextCompat.getColor(activity, R.color.colorAccent));
                textView.setTextSize(18);
                textView.setText(msg);
                toast.setView(textView);
                toast.show();
            }
        });
    }
}
