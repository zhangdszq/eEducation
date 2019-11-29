package io.agora.rtc.education.main;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;

import androidx.cardview.widget.CardView;

import org.jetbrains.annotations.Nullable;

import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.room.largeclass.LargeClassActivity;
import io.agora.rtc.education.room.miniclass.MiniClassActivity;
import io.agora.rtc.education.room.onetoone.OneToOneActivity;
import io.agora.rtc.education.setting.SettingActivity;
import io.agora.rtc.lib.util.ToastUtil;

public class MainActivity extends BaseActivity {
    CardView layoutRoomType;
    EditText edtRoomType;

    @Override
    protected void initUI(@Nullable Bundle savedInstanceState) {
        setContentView(R.layout.activity_main);
        layoutRoomType = findViewById(R.id.card_room_type);
        edtRoomType = findViewById(R.id.edt_room_type);
    }

    @Override
    protected void initData() {
        super.initData();
        AGApplication app = AGApplication.the();
        app.initToastUtil();
        app.initRtmManager();
        app.initWorkerThread();
    }

    public void onClickJoin(View view) {
        EditText edtRoomName = findViewById(R.id.edt_room_name);
        String roomName = edtRoomName.getText().toString();
        if (TextUtils.isEmpty(roomName)) {
            ToastUtil.showShort(R.string.Room_name_should_not_be_empty);
            return;
        }
        EditText edtYourName = findViewById(R.id.edt_your_name);
        String yourName = edtYourName.getText().toString();
        if (TextUtils.isEmpty(yourName)) {
            ToastUtil.showShort(R.string.Your_name_should_not_be_empty);
            return;
        }

        String roomType = edtRoomType.getText().toString();
        if (TextUtils.isEmpty(roomType)) {
            ToastUtil.showShort(R.string.Room_type_should_not_be_empty);
            return;
        }

        Intent intent;
        if (roomType.equals(getString(R.string.one_to_one))) {
            intent = new Intent(this, OneToOneActivity.class);
        } else if (roomType.equals(getString(R.string.mini_class))) {
            intent = new Intent(this, MiniClassActivity.class);
        } else {
            intent = new Intent(this, LargeClassActivity.class);
        }
        intent.putExtra(IntentKey.ROOM_NAME, roomName)
                .putExtra(IntentKey.YOUR_NAME, yourName);
        startActivity(intent);
    }

    public void onClickRoomType(View view) {
        if (layoutRoomType.getVisibility() == View.GONE) {
            layoutRoomType.setVisibility(View.VISIBLE);
        } else {
            layoutRoomType.setVisibility(View.GONE);
        }
    }

    public void onClickSetting(View view) {
        startActivity(new Intent(this, SettingActivity.class));
    }

    public void onClickLargeClass(View view) {
        edtRoomType.setText(getString(R.string.large_class));
        layoutRoomType.setVisibility(View.GONE);
    }

    public void onClickMiniClass(View view) {
        edtRoomType.setText(getString(R.string.mini_class));
        layoutRoomType.setVisibility(View.GONE);
    }

    public void onClickOneToOne(View view) {
        edtRoomType.setText(getString(R.string.one_to_one));
        layoutRoomType.setVisibility(View.GONE);
    }
}
