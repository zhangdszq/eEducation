package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import io.agora.rtc.MiniClass.R;

public class MyDialogFragment extends DialogFragment {

    private String content;
    private DialogClickListener listener;

    public static MyDialogFragment newInstance(MyDialogFragment listener, String content) {
        MyDialogFragment fragment = new MyDialogFragment();
        fragment.content = content;
        return fragment;
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {

        Dialog dialog = new Dialog(getActivity());
        dialog.setCancelable(true);
        dialog.setCanceledOnTouchOutside(true);
        dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                listener.clickNo();
            }
        });
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
            }
        });
        root.findViewById(R.id.tv_dialog_yes).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.clickYes();
            }
        });
        return root;
    }

    public interface DialogClickListener {
        void clickYes();

        void clickNo();
    }
}
