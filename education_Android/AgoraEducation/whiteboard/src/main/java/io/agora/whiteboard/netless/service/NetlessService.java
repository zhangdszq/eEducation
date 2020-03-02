package io.agora.whiteboard.netless.service;

import io.agora.whiteboard.netless.service.bean.ResponseBody;
import retrofit2.Call;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface NetlessService {

    @POST("room/join")
    Call<ResponseBody> roomJoin(@Query("uuid") String uuid,
                                @Query("token") String token);

}
