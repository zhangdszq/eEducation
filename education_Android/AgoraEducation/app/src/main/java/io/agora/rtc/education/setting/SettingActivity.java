package io.agora.rtc.education.setting;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;
import android.widget.Switch;

import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.widget.eyecare.EyeCare;

public class SettingActivity extends BaseActivity {

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_setting);
    }

    public void onClickBack(View view) {
        finish();
    }

    public void onClickSwitch(View view) {
        Switch s = findViewById(R.id.switch_eye_care);
        s.setChecked(!s.isChecked());
        EyeCare.setNeedShow(s.isChecked());
        if (s.isChecked()) {
            showEyeCareView();
        } else {
            dismissEyeCareView();
        }
    }
}
