package io.agora.rtc.education.room.whiteboard;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.agora.rtc.lib.net.NetManager;
import okhttp3.Call;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class WhiteboardAPI {
    private static final String HOST = "https://cloudcapiv4.herewhite.com";
    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");
    private static String mSdkToken;

    public interface Callback {
        void success(String uuid, String roomToken);
        void fail(String errorMessage);
    }

    public static void init(String sdkToken) {
        mSdkToken = sdkToken;
    }

    public static void createRoom(String name, final Callback callback) {
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        params.put("limit", 0); // 0 表示没有限制
        params.put("mode", "historied");

        String url = HOST + "/room?token=" + mSdkToken;
        RequestBody body = RequestBody.create(JSON, new Gson().toJson(params));

        NetManager.getInstance().postRequest(url, body, new NetManager.CallBack() {
            @Override
            public void onSuccess(String json) {
                JsonObject roomJSON = new Gson().fromJson(json, JsonObject.class);
                String uuid = roomJSON.getAsJsonObject("msg").getAsJsonObject("room").get("uuid").getAsString();
                String roomToken = roomJSON.getAsJsonObject("msg").get("roomToken").getAsString();
                callback.success(uuid, roomToken);
            }

            @Override
            public void onFailure(IOException e) {
                callback.fail(e.getMessage());
            }
        });
    }

    public static void getRoom(final String uuid, final Callback callback) {
        String url = HOST + "/room/join?uuid=" + uuid + "&token=" + mSdkToken;
        RequestBody body = RequestBody.create(JSON, new Gson().toJson(new HashMap<>()));

        NetManager.getInstance().postRequest(url, body, new NetManager.CallBack() {
            @Override
            public void onSuccess(String json) {
                JsonObject roomJSON = new Gson().fromJson(json, JsonObject.class);
                String roomToken = roomJSON.getAsJsonObject("msg").get("roomToken").getAsString();
                callback.success(uuid, roomToken);
            }

            @Override
            public void onFailure(IOException e) {
                callback.fail(e.getMessage());
            }
        });
    }
}
