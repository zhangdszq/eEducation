package io.agora.rtc.MiniClass.ui.fragment;

import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import io.agora.rtc.Constants;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.MiniClass.R;
import io.agora.rtc.MiniClass.model.config.UserConfig;
import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.event.BaseEvent;
import io.agora.rtc.internal.LastmileProbeConfig;


public class LastMileFragment extends BaseFragment {

    public static LastMileFragment newInstance() {
        LastMileFragment fragment = new LastMileFragment();
        return fragment;
    }

    private ProgressBar mPbLossRate, mPbDelay, mPbQuality;
    private TextView mTvLossRateValue, mTvLossRateUnit, mTvDelayValue, mTvDelayUnit, mTvQuality;
    private ImageView mIvQuality;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View root = inflater.inflate(R.layout.fragment_last_mile, container, false);
        TextView tvBtnOK = root.findViewById(R.id.tv_btn_ok);
        tvBtnOK.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mListener != null)
                    mListener.onFragmentEvent(new Event(Event.EVENT_CLICK_OK));
            }
        });

        mPbLossRate = root.findViewById(R.id.pb_loss_rate);
        mPbDelay = root.findViewById(R.id.pb_last_mile_delay);
        mPbQuality = root.findViewById(R.id.pb_network_status_assessment);

        mTvLossRateValue = root.findViewById(R.id.tv_loss_rate_value);
        mTvLossRateUnit = root.findViewById(R.id.tv_loss_rate_unit);
        mTvDelayValue = root.findViewById(R.id.tv_last_mile_delay_value);
        mTvDelayUnit = root.findViewById(R.id.tv_last_mile_delay_unit);
        mTvQuality = root.findViewById(R.id.tv_network_status_assessment_result);
        mIvQuality = root.findViewById(R.id.iv_network_status_assessment_result);

        initLasMileTest();

        return root;
    }

    private IRtcEngineEventHandler rtcEngineEventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onLastmileQuality(final int quality) {
            if (mListener == null || quality == Constants.QUALITY_UNKNOWN || mTvQuality == null)
                return;

            ((Activity)mListener).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPbQuality.setVisibility(View.GONE);
                    if (quality == Constants.QUALITY_EXCELLENT || quality == Constants.QUALITY_GOOD) {
                        mTvQuality.setText(getString(R.string.Good));
                        mIvQuality.setImageResource(R.mipmap.pic_good);
                    } else {
                        mTvQuality.setText(getString(R.string.Bad));
                        mIvQuality.setImageResource(R.mipmap.pic_bad);
                    }
                }
            });
        }

        @Override
        public void onLastmileProbeResult(final LastmileProbeResult result) {
            if (mListener == null || result == null)
                return;

            ((Activity)mListener).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPbDelay.setVisibility(View.GONE);
                    mPbLossRate.setVisibility(View.GONE);
                    mTvDelayUnit.setVisibility(View.VISIBLE);
                    mTvLossRateUnit.setVisibility(View.VISIBLE);
                    mTvDelayValue.setText(String.valueOf(result.rtt));

                    LastmileProbeResult.LastmileProbeOneWayResult lastmileProbeOneWayResult = null;
                    if (UserConfig.getRole() == Constant.Role.TEACHER) {
                        lastmileProbeOneWayResult = result.uplinkReport;
                    } else {
                        lastmileProbeOneWayResult = result.downlinkReport;
                    }

                    if (lastmileProbeOneWayResult == null)
                        return;

                    mTvLossRateValue.setText(String.valueOf(lastmileProbeOneWayResult.packetLossRate));

                }
            });
        }
    };

    private void initLasMileTest() {
        if (rtcWorkerThread() == null || rtcEngine() == null)
            return;

        rtcWorkerThread().setRtcEventHandler(rtcEngineEventHandler);

        LastmileProbeConfig config = new LastmileProbeConfig();
        if (UserConfig.getRole() == Constant.Role.TEACHER) {
            config.probeUplink = true;
            config.expectedUplinkBitrate = 500;
        } else {
            config.probeDownlink = true;
            config.expectedDownlinkBitrate = 500;
        }
        rtcEngine().startLastmileProbeTest(config);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();

        if (rtcWorkerThread() != null && rtcEngine() != null) {
            rtcEngine().stopLastmileProbeTest();
            rtcWorkerThread().setRtcEventHandler(null);
        }
    }

    public static class Event extends BaseEvent {

        public static final int EVENT_CLICK_OK = 1001;

        public Event(int eventType) {
            super(eventType);
        }
    }
}
