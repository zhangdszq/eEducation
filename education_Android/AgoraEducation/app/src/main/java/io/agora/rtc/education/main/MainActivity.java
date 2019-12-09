package io.agora.rtc.education.main;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;

import org.jetbrains.annotations.Nullable;

import io.agora.rtc.Constants;
import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.constant.Constant;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.constant.SPKey;
import io.agora.rtc.education.room.largeclass.LargeClassActivity;
import io.agora.rtc.education.room.miniclass.MiniClassActivity;
import io.agora.rtc.education.room.onetoone.OneToOneActivity;
import io.agora.rtc.education.setting.SettingActivity;
import io.agora.rtc.lib.rtm.RtmManager;
import io.agora.rtc.lib.util.AppUtil;
import io.agora.rtc.lib.util.CryptoUtil;
import io.agora.rtc.lib.util.SPUtil;
import io.agora.rtc.lib.util.ToastUtil;

public class MainActivity extends BaseActivity {
    CardView layoutRoomType;
    EditText edtRoomType;
    private int userId;

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
        app.initRtmManager();
        app.initWorkerThread();

        userId = SPUtil.get(SPKey.MY_USER_ID, 0);
        if (userId < 1) {
            userId = Math.abs((int) (System.nanoTime()));
            SPUtil.put(SPKey.MY_USER_ID, userId);
        }
        rtmManager().login(String.valueOf(userId));
    }

    private void joinRoom() {
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

        if (rtmManager().getLoginStatus() != RtmManager.LOGIN_STATUS_SUCCESS) {
            ToastUtil.showShort("RTM登录未成功，请检查稍后重试！");
            rtmManager().login(String.valueOf(userId));
        }

        Intent intent;
        int roomTypeInt;
        if (roomType.equals(getString(R.string.one_to_one))) {
            intent = new Intent(this, OneToOneActivity.class);
            roomTypeInt = Constant.RoomType.ONE_TO_ONE;
        } else if (roomType.equals(getString(R.string.mini_class))) {
            intent = new Intent(this, MiniClassActivity.class);
            roomTypeInt = Constant.RoomType.SMALL_CLASS;
        } else {
            intent = new Intent(this, LargeClassActivity.class);
            roomTypeInt = Constant.RoomType.BIG_CLASS;
        }
        String roomNameReal = roomTypeInt + CryptoUtil.md5(roomName);
        if (!TextUtils.isEmpty(roomNameReal)) {
            intent.putExtra(IntentKey.ROOM_NAME, roomName)
                    .putExtra(IntentKey.ROOM_NAME_REAL, roomNameReal)
                    .putExtra(IntentKey.USER_ID, userId)
                    .putExtra(IntentKey.YOUR_NAME, yourName);
            startActivity(intent);
        }
    }

    private static final int PERMISSION_CODE = 100;

    public void onClickJoin(View view) {
        String[] requestPermission = {
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.CAMERA,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
        };
        if (AppUtil.checkAndRequestAppPermission(this, requestPermission, PERMISSION_CODE)) {
            joinRoom();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode != PERMISSION_CODE)
            return;
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                ToastUtil.showShort(R.string.No_enough_permissions);
                return;
            }
        }
        joinRoom();
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
