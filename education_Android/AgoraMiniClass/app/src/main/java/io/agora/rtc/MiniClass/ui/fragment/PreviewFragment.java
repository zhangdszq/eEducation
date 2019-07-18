package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.event.BaseEvent;


public class PreviewFragment extends BaseFragment {

    private FrameLayout fl_preview;

    public static PreviewFragment newInstance() {
        return new PreviewFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_preview, container, false);
        TextView tvBtnNext = root.findViewById(R.id.tv_btn_next);
        tvBtnNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mListener != null) {
                    mListener.onFragmentEvent(new Event(Event.EVENT_CLICK_NEXT));
                    rtcWorkerThread().runTask(new Runnable() {
                        @Override
                        public void run() {
//                            rtcWorkerThread().getRtcEngine().stopPreview();
                        }
                    });
                }
            }
        });

        fl_preview = root.findViewById(R.id.fl_camera_preview);

        rtcWorkerThread().runTask(new Runnable() {
            @Override
            public void run() {

//                final SurfaceView surfaceView = RtcEngine.CreateRendererView((Context) mListener);
//                rtcWorkerThread().getRtcEngine().setupLocalVideo(new VideoCanvas(surfaceView, Constants.RENDER_MODE_HIDDEN, 0));
//                rtcWorkerThread().getRtcEngine().startPreview();

                if (mListener != null) {
                    ((Activity)mListener).runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
//                            fl_preview.addView(surfaceView);
                        }
                    });
                }
            }
        });
        return root;
    }


    public static class Event extends BaseEvent {
        public static final int EVENT_CLICK_NEXT = 101;

        public Event(int eventType) {
            super(eventType);
        }
    }

}
