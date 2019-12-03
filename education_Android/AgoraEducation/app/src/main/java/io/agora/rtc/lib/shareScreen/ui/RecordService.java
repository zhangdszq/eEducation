package io.agora.rtc.lib.shareScreen.ui;

import android.app.Service;
import android.content.Intent;
import android.media.projection.MediaProjection;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;

import io.agora.rtc.RtcEngine;
import io.agora.rtc.gl.EglBase;
import io.agora.rtc.mediaio.AgoraSurfaceView;
import io.agora.rtc.mediaio.MediaIO;
import io.agora.rtc.lib.shareScreen.source.AgoraTextureRecord;
import io.agora.rtc.lib.shareScreen.source.ViewSharingCapturer;
import io.agora.rtc.video.VideoCanvas;

public class RecordService extends Service {

    private static final String TAG = "RecordService";
    private EglBase.Context mSharedContext;
    private MediaProjection mediaProjection;
    private AgoraTextureRecord textureSource;
    private ViewSharingCapturer viewSource;
    private SurfaceView previewSurfaceView;
    private boolean running = false;
    private int width = 720;
    private int height = 1080;
    private int dpi;
    private View recordView = null;
    private SurfaceReadyListener listener;

    @Override
    public IBinder onBind(Intent intent) {
        return new RecordBinder();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    private boolean isPreview = false;

    public boolean isPreview() {
        return isPreview;
    }

    public void setPreview(boolean preview) {
        isPreview = preview;
    }

    private boolean isEnableViewRecord = false;

    public boolean isEnableViewRecord() {
        return isEnableViewRecord;
    }

    public void setEnableViewRecord(boolean enableViewRecord) {
        isEnableViewRecord = enableViewRecord;
    }

    public void setRecordView(View view) {
        this.recordView = view;
    }

    public void setMediaProject(MediaProjection project) {
        mediaProjection = project;
    }

    public boolean isRunning() {
        return running;
    }

    public void setConfig(int width, int height, int dpi) {
        this.width = width;
        this.height = height;
        this.dpi = dpi;
    }

    public boolean startRecord(RtcEngine rtcEngine) {
        if (isEnableViewRecord) {
            initSurfaceRGBA(rtcEngine);
        } else {
            initSurfaceTexture(rtcEngine);
        }
        running = true;
        return true;
    }

    public boolean stopRecord() {
        if (!running) {
            return false;
        }
        Log.i(TAG, "stopRecord");
        running = false;
        releasTextureSource();
        releaseRGBASource();
        return true;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        stopRecord();
    }

    public void setSurfaceReadyListener(SurfaceReadyListener listener) {
        this.listener = listener;
    }

    public void initSurfaceTexture(RtcEngine rtcEngine) {
        releasTextureSource();
        releaseRGBASource();
        rtcEngine.stopPreview();
        textureSource = new AgoraTextureRecord(this, this.width, this.height, this.dpi, this.mediaProjection);
        mSharedContext = textureSource.getEglContext();

        if (isPreview) {
            AgoraSurfaceView render = new AgoraSurfaceView(this);
            render.setZOrderOnTop(true);
            render.setZOrderMediaOverlay(true);
            render.init(mSharedContext);
            render.setBufferType(MediaIO.BufferType.TEXTURE);
            render.setPixelFormat(MediaIO.PixelFormat.TEXTURE_OES);

            rtcEngine.setLocalVideoRenderer(render);
            previewSurfaceView = render;
            rtcEngine.startPreview();
        } else {
            previewSurfaceView = null;
        }
        listener.surfaceIsReady(previewSurfaceView);
        rtcEngine.setVideoSource(textureSource);
    }

    public void initSurfaceRGBA(RtcEngine rtcEngine) {
        rtcEngine.stopPreview();
        releasTextureSource();
        releaseRGBASource();
        viewSource = new ViewSharingCapturer(this.recordView);

        if (isPreview) {
            AgoraSurfaceView render = new AgoraSurfaceView(this);
            render.setZOrderOnTop(true);
            render.setZOrderMediaOverlay(true);
            render.init(null);
            render.setBufferType(MediaIO.BufferType.BYTE_BUFFER);
            render.setPixelFormat(MediaIO.PixelFormat.RGBA);
            rtcEngine.setLocalRenderMode(VideoCanvas.RENDER_MODE_FIT);
            rtcEngine.setLocalVideoRenderer(render);
            previewSurfaceView = render;
            rtcEngine.startPreview();
        } else {
            previewSurfaceView = null;
        }
        listener.surfaceIsReady(previewSurfaceView);
        rtcEngine.setVideoSource(viewSource);
    }

    public void releasTextureSource() {
        if (textureSource != null) {
            textureSource.sourceRelease();
            textureSource = null;
        }
    }

    public void releaseRGBASource() {
        if (viewSource != null) {
            viewSource = null;
        }

    }

    public class RecordBinder extends Binder {
        public RecordService getRecordService() {
            return RecordService.this;
        }
    }


}