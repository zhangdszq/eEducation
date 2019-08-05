package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;

public class MyDialogFragment extends DialogFragment {

    private String content;
    private DialogClickListener listener;

    public static MyDialogFragment newInstance(DialogClickListener listener, String content) {
        MyDialogFragment fragment = new MyDialogFragment();
        fragment.content = content;
        fragment.listener = listener;
        return fragment;
    }

    @Override
    public void onCancel(DialogInterface dialog) {
        listener.clickNo();
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {

        Dialog dialog = new Dialog(getActivity(), getTheme());
        setCancelable(true);
        return dialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_dialog, container, false);
        root.findViewById(R.id.tv_dialog_no).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.clickNo();
                dismiss();
            }
        });
        root.findViewById(R.id.tv_dialog_yes).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.clickYes();
            }
        });
        TextView tvContent = root.findViewById(R.id.tv_content);
        tvContent.setText(content);
        return root;
    }

    public interface DialogClickListener {
        void clickYes();

        void clickNo();
    }
}
