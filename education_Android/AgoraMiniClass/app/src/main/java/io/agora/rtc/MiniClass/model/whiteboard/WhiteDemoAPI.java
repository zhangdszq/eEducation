package io.agora.rtc.MiniClass.model.whiteboard;

import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;

import io.agora.rtc.MiniClass.model.constant.Constant;
import io.agora.rtc.MiniClass.model.net.NetManager;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.Request;
import okhttp3.RequestBody;

/**
 * Created by buhe on 2018/8/16.
 */

public class WhiteDemoAPI {
    public static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");
    private static final String HOST = Constant.BASE_URL + "edu_whiteboard/v1/room";

    private Gson gson = new Gson();

    public void createRoom(String name, int limit, Callback callback) {
        Map<String, Object> roomSpec = new HashMap<>();
        roomSpec.put("name", name);
        roomSpec.put("limit", limit);
        RequestBody body = RequestBody.create(JSON, gson.toJson(roomSpec));
        Request request = new Request.Builder()
                .url(HOST)
                .post(body)
                .build();
        Call call = NetManager.getOkHttpClient().newCall(request);
        call.enqueue(callback);
    }

    public void getRoomToken(String uuid, Callback callback) {
        Map<String, Object> roomSpec = new HashMap<>();
        roomSpec.put("uuid", uuid);
        RequestBody body = RequestBody.create(JSON, gson.toJson(roomSpec));
        Request request = new Request.Builder()
                .url(HOST + "/join")
                .post(body)
                .build();
        Call call = NetManager.getOkHttpClient().newCall(request);
        call.enqueue(callback);
    }

}
