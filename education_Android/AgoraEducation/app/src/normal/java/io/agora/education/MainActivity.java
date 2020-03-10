package io.agora.education;

import android.Manifest;
import android.app.DownloadManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.cardview.widget.CardView;

import butterknife.BindView;
import butterknife.OnClick;
import butterknife.OnTouch;
import io.agora.base.Callback;
import io.agora.base.ToastManager;
import io.agora.base.network.RetrofitManager;
import io.agora.education.base.BaseActivity;
import io.agora.education.base.BaseCallback;
import io.agora.education.broadcast.DownloadReceiver;
import io.agora.education.classroom.BaseClassActivity;
import io.agora.education.classroom.LargeClassActivity;
import io.agora.education.classroom.OneToOneClassActivity;
import io.agora.education.classroom.SmallClassActivity;
import io.agora.education.classroom.annotation.ClassType;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.strategy.context.ClassContext;
import io.agora.education.classroom.strategy.context.ClassContextFactory;
import io.agora.education.service.CommonService;
import io.agora.education.util.AppUtil;
import io.agora.education.util.CryptoUtil;
import io.agora.education.widget.ConfirmDialog;
import io.agora.education.widget.PolicyDialog;
import io.agora.rtc.Constants;
import io.agora.sdk.manager.RtmManager;

public class MainActivity extends BaseActivity {

    private final int REQUEST_CODE_DOWNLOAD = 100;
    private final int REQUEST_CODE_RTC = 101;

    @BindView(R.id.et_room_name)
    protected EditText et_room_name;
    @BindView(R.id.et_your_name)
    protected EditText et_your_name;
    @BindView(R.id.et_room_type)
    protected EditText et_room_type;
    @BindView(R.id.card_room_type)
    protected CardView card_room_type;

    private DownloadReceiver receiver;
    private CommonService service;
    private int myUserId;
    private String url;
    private boolean isJoining;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }

    @Override
    protected void initData() {
        receiver = new DownloadReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.setPriority(IntentFilter.SYSTEM_LOW_PRIORITY);
        registerReceiver(receiver, filter);

        service = RetrofitManager.instance().getService(BuildConfig.API_BASE_URL, CommonService.class);
        checkVersion();

        myUserId = (int) (System.currentTimeMillis() * 1000 % 1000000);
        RtmManager.instance().login(getString(R.string.agora_rtm_token), myUserId, null);
    }

    @Override
    protected void initView() {
        new PolicyDialog().show(getSupportFragmentManager(), null);
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(receiver);
        RtmManager.instance().reset();
        super.onDestroy();
    }

    private void checkVersion() {
        service.appVersion("edu-demo").enqueue(new BaseCallback<>(data -> {
            if (data != null && data.forcedUpgrade != 0) {
                showAppUpgradeDialog(data.upgradeUrl, data.forcedUpgrade == 2);
            }
        }));
    }

    private void showAppUpgradeDialog(String url, boolean isForce) {
        this.url = url;
        String content = getString(R.string.app_upgrade);
        ConfirmDialog.DialogClickListener listener = confirm -> {
            if (confirm) {
                if (AppUtil.checkAndRequestAppPermission(MainActivity.this, new String[]{
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, REQUEST_CODE_DOWNLOAD)) {
                    receiver.downloadApk(MainActivity.this, url);
                }
            }
        };
        ConfirmDialog dialog;
        if (isForce) {
            dialog = ConfirmDialog.singleWithButton(content, getString(R.string.upgrade), listener);
            dialog.setCancelable(false);
        } else {
            dialog = ConfirmDialog.normalWithButton(content, getString(R.string.later), getString(R.string.upgrade), listener);
        }
        dialog.show(getSupportFragmentManager(), null);
    }

    private void joinRoom() {
        if (isJoining) return;

        String roomName = et_room_name.getText().toString();
        if (TextUtils.isEmpty(roomName)) {
            ToastManager.showShort(R.string.room_name_should_not_be_empty);
            return;
        }

        String yourName = et_your_name.getText().toString();
        if (TextUtils.isEmpty(yourName)) {
            ToastManager.showShort(R.string.your_name_should_not_be_empty);
            return;
        }

        String roomType = et_room_type.getText().toString();
        if (TextUtils.isEmpty(roomType)) {
            ToastManager.showShort(R.string.room_type_should_not_be_empty);
            return;
        }

        if (!RtmManager.instance().isConnected()) {
            ToastManager.showShort(R.string.rtm_not_login);
            RtmManager.instance().login(getString(R.string.agora_rtm_token), myUserId, null);
            return;
        }

        Intent intent = createIntent(roomName, yourName, roomType);
        checkChannelEnterable(intent);
    }

    private Intent createIntent(String roomName, String yourName, String roomType) {
        Intent intent = new Intent();
        int classType;
        if (roomType.equals(getString(R.string.one2one_class))) {
            intent.setClass(this, OneToOneClassActivity.class);
            classType = ClassType.ONE2ONE;
        } else if (roomType.equals(getString(R.string.small_class))) {
            intent.setClass(this, SmallClassActivity.class);
            classType = ClassType.SMALL;
        } else {
            intent.setClass(this, LargeClassActivity.class);
            classType = ClassType.LARGE;
        }
        intent.putExtra(BaseClassActivity.ROOM_NAME, roomName)
                .putExtra(BaseClassActivity.CHANNEL_ID, classType + CryptoUtil.md5(roomName))
                .putExtra(BaseClassActivity.USER_NAME, yourName)
                .putExtra(BaseClassActivity.USER_ID, myUserId)
                .putExtra(BaseClassActivity.CLASS_TYPE, classType)
                .putExtra(BaseClassActivity.RTC_TOKEN, getString(R.string.agora_rtc_token))
                .putExtra(BaseClassActivity.WHITEBOARD_SDK_TOKEN, getString(R.string.whiteboard_sdk_token));
        return intent;
    }

    private void checkChannelEnterable(Intent intent) {
        int classType = intent.getIntExtra(BaseClassActivity.CLASS_TYPE, 0);
        String channelId = intent.getStringExtra(BaseClassActivity.CHANNEL_ID);
        String userName = intent.getStringExtra(BaseClassActivity.USER_NAME);
        int userId = intent.getIntExtra(BaseClassActivity.USER_ID, 0);
        ClassContext classContext = new ClassContextFactory(this)
                .getClassContext(classType, channelId, new Student(userId, userName, Constants.CLIENT_ROLE_AUDIENCE));
        classContext.checkChannelEnterable(new Callback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                classContext.release();
                if (aBoolean) {
                    startActivity(intent);
                } else {
                    ToastManager.showShort(R.string.the_room_is_full);
                }
                isJoining = false;
            }

            @Override
            public void onFailure(Throwable throwable) {
                classContext.release();
                ToastManager.showShort(R.string.get_channel_attr_failed);
                isJoining = false;
            }
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                ToastManager.showShort(R.string.no_enough_permissions);
                return;
            }
        }
        switch (requestCode) {
            case REQUEST_CODE_DOWNLOAD:
                receiver.downloadApk(this, url);
                break;
            case REQUEST_CODE_RTC:
                joinRoom();
                break;
        }
    }

    @OnClick({R.id.iv_setting, R.id.et_room_type, R.id.btn_join, R.id.tv_one2one, R.id.tv_small_class, R.id.tv_large_class})
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.iv_setting:
                startActivity(new Intent(this, SettingActivity.class));
                break;
            case R.id.btn_join:
                if (AppUtil.checkAndRequestAppPermission(this, new String[]{
                        Manifest.permission.RECORD_AUDIO,
                        Manifest.permission.CAMERA,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                }, REQUEST_CODE_RTC)) {
                    joinRoom();
                }
                break;
            case R.id.tv_one2one:
                et_room_type.setText(R.string.one2one_class);
                card_room_type.setVisibility(View.GONE);
                break;
            case R.id.tv_small_class:
                et_room_type.setText(R.string.small_class);
                card_room_type.setVisibility(View.GONE);
                break;
            case R.id.tv_large_class:
                et_room_type.setText(R.string.large_class);
                card_room_type.setVisibility(View.GONE);
                break;
        }
    }

    @OnTouch(R.id.et_room_type)
    public void onTouch(View view, MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_UP) {
            if (card_room_type.getVisibility() == View.GONE) {
                card_room_type.setVisibility(View.VISIBLE);
            } else {
                card_room_type.setVisibility(View.GONE);
            }
        }
    }

}
