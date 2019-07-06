package io.agora.rtc.MiniClass.model.whiteboard;

import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;

import io.agora.rtc.MiniClass.model.net.NetManager;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;

/**
 * Created by buhe on 2018/8/16.
 */

public class DemoAPI {

    public static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");
//    private static final String sdkToken = "WHITEcGFydG5lcl9pZD1zTHlGOTlHNFlTbkx1Y3Fna2E0a3Z5cnlmQTJxZjdoaFNXNDYmc2lnPWM4ZmQwYWEzM2FkNjU2NmVlNzM3OTYyZWQ5ZjE0OTRiOWE1MzE1MGI6YWRtaW5JZD0xNSZyb2xlPW1pbmkmZXhwaXJlX3RpbWU9MTU2NDUwMDQ4OCZhaz1zTHlGOTlHNFlTbkx1Y3Fna2E0a3Z5cnlmQTJxZjdoaFNXNDYmY3JlYXRlX3RpbWU9MTUzMjk0MzUzNiZub25jZT0xNTMyOTQzNTM2MDY5MDA";
//    private static final String host = "https://cloudcapiv4.herewhite.com";
    private static final String host = "https://webdemo.agora.io/edu_whiteboard/v1/room";

    Gson gson = new Gson();

    public void createRoom(String name, int limit, Callback callback) {
        Map<String, Object> roomSpec = new HashMap<>();
        roomSpec.put("name", name);
        roomSpec.put("limit", limit);
        RequestBody body = RequestBody.create(JSON, gson.toJson(roomSpec));
        Request request = new Request.Builder()
//                .url(host + "/room?token=" + sdkToken)
                .url(host)
                .post(body)
                .build();
        Call call = NetManager.getOkHttpClient().newCall(request);
        call.enqueue(callback);
    }

    public void getRoomToken(String uuid, Callback callback) {
        Map<String, Object> roomSpec = new HashMap<>();
        RequestBody body = RequestBody.create(JSON, gson.toJson(roomSpec));
        Request request = new Request.Builder()
//                .url(host + "/room/join?uuid=" + uuid + "&token=" + sdkToken)
                .url(host + "/room/join")
                .post(body)
                .build();
        Call call = NetManager.getOkHttpClient().newCall(request);
        call.enqueue(callback);
    }

    public static String TEST_UUID = "test";
    public static String TEST_ROOM_TOKEN = "test";
}
