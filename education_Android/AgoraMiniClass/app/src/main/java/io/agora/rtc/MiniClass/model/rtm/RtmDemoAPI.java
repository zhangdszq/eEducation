package io.agora.rtc.MiniClass.model.rtm;

import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.net.NetManager;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Request;

public class RtmDemoAPI {
    private static final String RTM_ID_URL = Constant.BASE_URL + "edu_control/sentry";
    private static final String QUERY_USER_URL = Constant.BASE_URL + "edu_control/user/";
    private static final String QUERY_CHANNEL_URL = Constant.BASE_URL + "edu_control/channel/";

    public void getRTMId(Callback callback) {
        Request request = new Request.Builder()
                .url(RTM_ID_URL)
                .get()
                .build();
        Call call = NetManager.getOkHttpClient().newCall(request);
        call.enqueue(callback);
    }
}
