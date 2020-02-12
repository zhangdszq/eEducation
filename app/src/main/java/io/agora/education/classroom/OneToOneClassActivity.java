package io.agora.education.classroom;

import android.view.View;

import butterknife.BindView;
import butterknife.OnClick;
import io.agora.education.R;
import io.agora.education.classroom.annotation.ClassType;
import io.agora.education.classroom.bean.user.Student;
import io.agora.education.classroom.bean.user.User;
import io.agora.education.classroom.strategy.context.OneToOneClassContext;
import io.agora.education.classroom.widget.RtcVideoView;
import io.agora.rtc.Constants;

public class OneToOneClassActivity extends BaseClassActivity implements OneToOneClassContext.OneToOneClassEventListener {

    @BindView(R.id.layout_video_teacher)
    protected RtcVideoView video_teacher;
    @BindView(R.id.layout_video_student)
    protected RtcVideoView video_student;
    @BindView(R.id.layout_im)
    protected View layout_im;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_one2one_class;
    }

    @Override
    protected void initView() {
        super.initView();
        video_teacher.init(R.layout.layout_video_one2one_class, false);
        video_student.init(R.layout.layout_video_one2one_class, true);
        video_student.setOnClickAudioListener(v -> classContext.muteLocalAudio(!video_student.isAudioMuted()));
        video_student.setOnClickVideoListener(v -> classContext.muteLocalVideo(!video_student.isVideoMuted()));
    }

    @Override
    protected Student getLocal() {
        return new Student(getMyUserId(), getMyUserName(), Constants.CLIENT_ROLE_BROADCASTER);
    }

    @Override
    protected int getClassType() {
        return ClassType.ONE2ONE;
    }

    @OnClick(R.id.iv_float)
    public void onClick(View view) {
        boolean isSelected = view.isSelected();
        view.setSelected(!isSelected);
        layout_im.setVisibility(isSelected ? View.VISIBLE : View.GONE);
    }

    @Override
    public void onTeacherMediaChanged(User user) {
        video_teacher.setName(user.account);
        video_teacher.showRemote(user.uid);
        video_teacher.muteVideo(user.video == 0);
        video_teacher.muteAudio(user.audio == 0);
    }

    @Override
    public void onLocalMediaChanged(User user) {
        video_student.setName(user.account);
        video_student.showLocal();
        video_student.muteVideo(user.video == 0);
        video_student.muteAudio(user.audio == 0);
    }

}
