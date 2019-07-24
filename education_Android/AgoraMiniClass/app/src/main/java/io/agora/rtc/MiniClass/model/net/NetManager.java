package io.agora.rtc.MiniClass.model.net;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;

public class NetManager {

    private static NetManager netManager = new NetManager();

    private OkHttpClient client;

    private NetManager() {
        client = new OkHttpClient();
    }

    public static NetManager getInstance() {
        return netManager;
    }

    public static OkHttpClient getOkHttpClient(){
        return netManager.client;
    }

}
