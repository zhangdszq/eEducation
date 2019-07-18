package io.agora.rtc.MiniClass.ui.activity;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import io.agora.rtc.MiniClass.AGApplication;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.util.AppUtil;

public class WelcomeActivity extends AppCompatActivity {

    private static final int PEMISSION_REQUEST_CODE = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_welcome);

        String[] needPermissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.RECORD_AUDIO, Manifest.permission.CAMERA};
        if (AppUtil.checkAndRequestAppPermission(this, needPermissions, PEMISSION_REQUEST_CODE)) {
            ((AGApplication) getApplication()).initWorkerThread();

            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    startMainActivity();
                }

            }, 500);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode != PEMISSION_REQUEST_CODE)
            return;

        for (int grantResult : grantResults) {
            if (grantResult != PackageManager.PERMISSION_GRANTED)
                finish();
        }

        ((AGApplication) getApplication()).initWorkerThread();
        startMainActivity();
    }


    private void startMainActivity() {

        startActivity(new Intent(WelcomeActivity.this, MainActivity.class));
        finish();
    }
}
