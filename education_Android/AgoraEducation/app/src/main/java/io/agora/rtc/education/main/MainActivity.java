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

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.agora.rtc.education.AGApplication;
import io.agora.rtc.education.R;
import io.agora.rtc.education.base.BaseActivity;
import io.agora.rtc.education.constant.Constant;
import io.agora.rtc.education.constant.IntentKey;
import io.agora.rtc.education.room.largeclass.LargeClassActivity;
import io.agora.rtc.education.room.miniclass.MiniClassActivity;
import io.agora.rtc.education.room.onetoone.OneToOneActivity;
import io.agora.rtc.education.setting.SettingActivity;
import io.agora.rtc.lib.rtm.RtmManager;
import io.agora.rtc.lib.util.AppUtil;
import io.agora.rtc.lib.util.CryptoUtil;
import io.agora.rtc.lib.util.ToastUtil;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmChannelAttribute;
import io.agora.rtm.RtmClient;

public class MainActivity extends BaseActivity {
    private CardView layoutRoomType;
    private EditText edtRoomType;
    private int userId = (int) (System.currentTimeMillis() * 1000 % 1000000);

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

//        userId = SPUtil.get(SPKey.MY_USER_ID, 0);
//        if (userId < 1) {
//            userId = Math.abs((int) (System.nanoTime()));
//            SPUtil.put(SPKey.MY_USER_ID, userId);
//        }
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

        final String roomType = edtRoomType.getText().toString();
        if (TextUtils.isEmpty(roomType)) {
            ToastUtil.showShort(R.string.Room_type_should_not_be_empty);
            return;
        }

        if (rtmManager().getLoginStatus() != RtmManager.LOGIN_STATUS_SUCCESS) {
            ToastUtil.showShort("RTM登录未成功，请检查稍后重试！");
            rtmManager().login(String.valueOf(userId));
        }

        final Intent intent;
        final int roomTypeInt;
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
        intent.putExtra(IntentKey.ROOM_NAME, roomName)
                .putExtra(IntentKey.ROOM_NAME_REAL, roomNameReal)
                .putExtra(IntentKey.USER_ID, userId)
                .putExtra(IntentKey.YOUR_NAME, yourName);

        if (roomTypeInt == Constant.RoomType.BIG_CLASS) {
            startActivity(intent);
        } else {
            final RtmClient client = rtmManager().getRtmClient();
            client.getChannelAttributes(roomNameReal, new ResultCallback<List<RtmChannelAttribute>>() {
                @Override
                public void onSuccess(final List<RtmChannelAttribute> attributes) {
                    Set<String> uidSet = new HashSet<>();
                    for (RtmChannelAttribute attribute : attributes) {
                        String key = attribute.getKey();
                        if (!TextUtils.equals(key, Constant.RTM_CHANNEL_KEY_TEACHER)) {
                            uidSet.add(key);
                        }
                    }
                    if (uidSet.size() == 0) {
                        startActivity(intent);
                    } else {
                        client.queryPeersOnlineStatus(uidSet, new ResultCallback<Map<String, Boolean>>() {
                            @Override
                            public void onSuccess(Map<String, Boolean> stringBooleanMap) {
                                int studentCount = 0;
                                for (Map.Entry<String, Boolean> entity : stringBooleanMap.entrySet()) {
                                    if (entity.getValue()) {
                                        studentCount++;
                                    }
                                }
                                if ((roomTypeInt == Constant.RoomType.ONE_TO_ONE && studentCount == 0)
                                        || (roomTypeInt == Constant.RoomType.SMALL_CLASS && studentCount < 16)) {
                                    startActivity(intent);
                                } else {
                                    runOnUiThread(() -> ToastUtil.showShort(R.string.the_room_is_full));
                                }
                            }

                            @Override
                            public void onFailure(ErrorInfo errorInfo) {
                                runOnUiThread(() -> ToastUtil.showShort(R.string.get_channel_attr_failed));
                            }
                        });
                    }
                }

                @Override
                public void onFailure(ErrorInfo errorInfo) {
                    runOnUiThread(() -> ToastUtil.showShort(R.string.get_channel_attr_failed));
                }
            });
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
