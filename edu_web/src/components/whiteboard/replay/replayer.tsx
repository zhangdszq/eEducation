import React, { useState, useEffect, useCallback, useRef } from 'react';
import { WhiteWebSdk, PlayerPhase, Player } from 'white-web-sdk';
// import SeekSlider from '@netless/react-seek-slider';
import "video.js/dist/video-js.css";
import Draggable from 'react-draggable';
import moment from 'moment';

const formatTime = (seconds: number) => {
  return moment(seconds).format("HH : mm : ss")
}

export type PlayerPageProps = {
  uuid: string
  roomToken: string
  duration?: number
  beginTimestamp?: number
  mediaUrl?: string
}

export type PlayerPageStates = {
  player?: Player
  phase: PlayerPhase
  currentTime: number
  isFirstScreenReady: boolean
  isPlayerSeeking: boolean
  seenMessagesLength: number
  isChatOpen: boolean
  isVisible: boolean
  replayFail: boolean
}

const defaultState: PlayerPageStates = {
  currentTime: 0,
  phase: PlayerPhase.Pause,
  isFirstScreenReady: false,
  isPlayerSeeking: false,
  seenMessagesLength: 0,
  isChatOpen: false,
  isVisible: false,
  replayFail: false,
}

export const NetlessPlayer: React.FC<PlayerPageProps> = ({
  uuid,
  roomToken,
  duration,
  beginTimestamp,
  mediaUrl
}) => {

  const [state, setState] = useState<PlayerPageStates>(defaultState);

  const PlayerLoading = useCallback(() => {
    if (!state.player) return null;
    return (
      <div className="white-board-loading">
        <img src="https://white-sdk.oss-cn-beijing.aliyuncs.com/fast-sdk/icons/loading.svg" alt="loading"/>
      </div>
    )
  }, [state.player]);

  const MediaView = useCallback(() => {
    if (!mediaUrl) return null;
    return (
      <Draggable bounds="parent">
        <div className="player-video-out">
          <video
            poster={"https://white-sdk.oss-cn-beijing.aliyuncs.com/icons/video_cover.svg"}
            className="video-js video-layout"
            id="white-sdk-video-js"
          />
        </div>
      </Draggable>
    )
  }, [mediaUrl])

  const ScheduleView = useCallback(() => {
    if (!state.player || !state.isVisible) return null;
    return (
      <div
        onMouseEnter={() => setState({ ...state, isVisible: true })}
        className="player-schedule">
        <div className="player-mid-box">
          {/* <SeekSlider
            fullTime={state.player.timeDuration}
            // currentTime={getCurrentTime(state.currentTime)}
            onChange={(time: number, offsetTime: number) => {
              if (state.player) {
                setState({ ...state, currentTime: time });
                state.player.seekToScheduleTime(time);
              }
            }}
            hideHoverTime={true}
            limitTimeTooltipBySides={true} /> */}
        </div>
        <div className="player-controller-box">
          <div className="player-controller-left">
            <div className="player-left-box">
              <div
                onClick={() => {
                  if (state.player) {
                    // handleOperationClick(state.player);
                  }
                }}
                className="player-controller">
              </div>
            </div>
            <div className="player-mid-box-time">
              {state.player.scheduleTime}
              {state.player.timeDuration}
            </div>
          </div>
        </div>
      </div>
    )
  }, [state.player, state.isVisible]);

  return (
    <div className="player-out-box">
      <div className="player-board">
        <MediaView />
        <ScheduleView />
        <div
          className="player-board-inner"
          onMouseOver={() => setState({ ...state, isVisible: true })}
          onMouseLeave={() => setState({ ...state, isVisible: false })}
        >
          <div
            onClick={() => {
              if (state.player) {
                console.log("state.player ", state.player);
              }
            }}
            className="player-mask">
            {state.phase === PlayerPhase.Pause &&
              <div className="player-big-icon">
              </div>}
          </div>
        </div>
      </div>
    </div>
  )
}