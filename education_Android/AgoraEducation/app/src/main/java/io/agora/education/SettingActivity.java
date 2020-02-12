package io.agora.education;

import android.view.View;
import android.widget.CompoundButton;
import android.widget.Switch;

import butterknife.BindView;
import butterknife.OnCheckedChanged;
import butterknife.OnClick;
import io.agora.education.base.BaseActivity;
import io.agora.education.widget.EyeProtection;

public class SettingActivity extends BaseActivity {

    @BindView(R.id.switch_eye_care)
    protected Switch switch_eye_care;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_setting;
    }

    @Override
    protected void initData() {

    }

    @Override
    protected void initView() {
        switch_eye_care.setChecked(EyeProtection.isNeedShow());
    }

    @OnClick(R.id.iv_back)
    public void onClick(View view) {
        finish();
    }

    @OnCheckedChanged(R.id.switch_eye_care)
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        EyeProtection.setNeedShow(isChecked);
        if (isChecked) {
            showEyeProtection();
        } else {
            dismissEyeProtection();
        }
    }

}
