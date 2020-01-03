package io.agora.rtc.education.room.whiteboard;

import com.herewhite.sdk.Room;
import com.herewhite.sdk.domain.Scene;
import com.herewhite.sdk.domain.SceneState;

public class SceneHelper {

    private Scene[] scenes = new Scene[]{};
    private Room room;
    private String scenePath = "";
    private int sceneIndex = -1;

    public void setRoom(Room room) {
        this.room = room;
    }

    public void setSceneState(SceneState sceneState) {
//        if (this.sceneIndex != sceneState.getIndex()) {
        this.sceneIndex = sceneState.getIndex();
        this.scenePath = sceneState.getScenePath();
        this.scenes = sceneState.getScenes();
        if (onSceneChangeListener != null) {
            onSceneChangeListener.onSceneIndexChanged(this.sceneIndex + 1, this.scenes.length);
        }
//        }
    }

    private OnSceneChangeListener onSceneChangeListener;

    public void setOnSceneChangeListener(OnSceneChangeListener onSceneChangeListener) {
        this.onSceneChangeListener = onSceneChangeListener;
        if (sceneIndex >= 0) {
            onSceneChangeListener.onSceneIndexChanged(sceneIndex, scenes.length);
        }
    }

    public interface OnSceneChangeListener {
        void onSceneIndexChanged(int index, int totalCount);
    }

    private void onChangeToScene(int index) {
        if (this.room != null && this.sceneIndex != index) {
            this.room.setScenePath(this.getScenePathWithIndex(index));
        }
    }

    public void goToPreviousPage() {
        if (this.room != null) {
            this.room.pptPreviousStep();
        }
    }

    public void goToNextPage() {
        if (this.room != null) {
            this.room.pptNextStep();
        }
    }

    public void goToEndPage() {
        onChangeToScene(this.scenes.length - 1);
    }

    public void goToFirstPage() {
        onChangeToScene(0);
    }

    private void removeScene(int index) {
        if (this.room != null) {
            this.room.removeScenes(this.getScenePathWithIndex(index));
        }
    }

    private String getScenePathWithIndex(int index) {
        return this.getSceneDirectory() + "/" + this.scenes[index].getName();
    }

    private String getSceneDirectory() {
        int lastSemicolonIndex = this.scenePath.lastIndexOf('/');
        return this.scenePath.substring(0, lastSemicolonIndex);
    }

    public void showPPT(int index) {
        if (this.room != null) {
            PPTData pptData = PPTData.pptDatas[index];
            String directory = "/defaultPPT" + pptData.getId();
            String scenePath = directory + "/" + pptData.getScenes()[0].getName();

            this.room.putScenes(directory, pptData.getScenes(), 0);
            this.room.setScenePath(scenePath);
        }
    }

}
