package io.agora.education.service;

import java.util.Map;

import io.agora.education.BuildConfig;
import io.agora.education.service.bean.ResponseBody;
import io.agora.education.service.bean.response.AppConfigRes;
import io.agora.education.service.bean.response.AppVersionRes;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Query;

public interface CommonService {

    // osType 1 iOS 2 Android
    // terminalType 1 phone 2 pad
    @GET("/edu/v1/app/version?appCode=" + BuildConfig.CODE + "&osType=2&terminalType=1&appVersion=" + BuildConfig.VERSION_NAME)
    Call<ResponseBody<AppVersionRes>> appVersion(@Query("appCode") String appCode);

    // platform 0 web 1 iOS 2 Android
    // device 0 pc 1 phone 2 pad
    @GET("/edu/v1/config?platform=2&device=1&version=" + BuildConfig.VERSION_NAME)
    Call<ResponseBody<AppConfigRes>> config();

    @GET("/edu/v1/multi/language")
    Call<ResponseBody<Map<String, Map<Integer, String>>>> language();

}
