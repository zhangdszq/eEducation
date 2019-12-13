import React, { useEffect, useMemo, useRef } from 'react';
import './replay.scss';
import Slider from '@material-ui/core/Slider';
import { Subject } from 'rxjs';
import { NetlessPlayer } from '../components/whiteboard/replay/replayer';
import { WhiteWebSdk, Player, PlayerPhase, } from 'white-web-sdk';
import { useParams } from 'react-router';
import {apiClient} from '../utils/netless-whiteboard-client';
import { palette } from '@material-ui/system';
import { useRootContext } from '../store';
import { ActionType } from '../reducers/types';
import { roomTypes } from '../hooks/use-room-control';
import moment from 'moment';
import useToast from '../hooks/use-toast';

export interface IPlayerState {
  beginTimestamp: number
  duration: number
  roomToken: string
  mediaURL: string
  isPlaying: boolean
  progress: number
  player: any

  currentTime: number
  phase: PlayerPhase
  isFirstScreenReady: boolean
  isPlayerSeeking: boolean
  seenMessagesLength: number
  isChatOpen: boolean
  isVisible: boolean
  replayFail: boolean
}

export const defaultState: IPlayerState = {
  beginTimestamp: 0,
  duration: 0,
  roomToken: '',
  mediaURL: '',
  isPlaying: false,
  progress: 0,
  player: null,

  currentTime: 0,
  phase: PlayerPhase.Pause,
  isFirstScreenReady: false,
  isPlayerSeeking: false,
  seenMessagesLength: 0,
  isChatOpen: false,
  isVisible: false,
  replayFail: false,
}

class ReplayStore {
  public subject: Subject<IPlayerState> | null;
  public state: IPlayerState | null;

  constructor() {
    this.subject = null;
    this.state = null;
  }

  initialize() {
    this.subject = new Subject<IPlayerState>();
    this.state = defaultState;
    this.subject.next(this.state);
  }

  subscribe(setState: any) {
    this.initialize();
    this.subject && this.subject.subscribe(setState);
  }

  unsubscribe() {
    this.subject && this.subject.unsubscribe();
    this.state = null;
    this.subject = null;
  }

  commit(state: IPlayerState) {
    this.subject && this.subject.next(state);
  }

  setPlayer(player: Player) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      player
    }
    this.commit(this.state);
  }

  setCurrentTime(scheduleTime: number) {
    if (!this.state) return;
    this.state = {
      ...this.state,
      currentTime: scheduleTime
    }
    this.commit(this.state);
  }

  updatePlayerStatus(isPlaying: boolean) {
    if (!this.state) return;

    this.state = {
      ...this.state,
      isPlaying,
    }
    if (!this.state.isPlaying && this.state.player) {
      this.state.player.seekToScheduleTime(0);
    }
    console.log("updatePlayer this.state ", this.state);
    this.commit(this.state);
  }

  updateProgress(progress: number) {
    if (!this.state) return
    this.state = {
      ...this.state,
      progress
    }
    this.commit(this.state);
  }

  setReplayFail(val: boolean) {
    if (!this.state) return
    this.state = {
      ...this.state,
      replayFail: val
    }
    this.commit(this.state);
  }

  updatePhase(phase: PlayerPhase) {
    if (!this.state) return
    let isPlaying = this.state.isPlaying;

    console.log("player phase ", phase);
    if (phase === PlayerPhase.Playing) {
      isPlaying = true;
    }

    if (phase === PlayerPhase.Ended || phase === PlayerPhase.Pause) {
      // console.log("ended", ended);
      isPlaying = false;
    }

    this.state = {
      ...this.state,
      phase,
      isPlaying,
    }
    this.commit(this.state);
  }

  loadFirstFrame() {
    if (!this.state) return
    this.state = {
      ...this.state,
      isFirstScreenReady: true,
    }
    this.commit(this.state);
  }

  
  async joinRoom(_uuid: string) {
    return await apiClient.sendJoinRoom(_uuid);
  }
}

const store = new ReplayStore();

const ReplayContext = React.createContext({} as IPlayerState);

const useReplayContext = () => React.useContext(ReplayContext);

const ReplayContainer: React.FC<{}> = () => {
  const [state, setState] = React.useState<IPlayerState>(defaultState);

  React.useEffect(() => {
    store.subscribe((state: any) => {
      setState(state);
    });
    return () => {
      store.unsubscribe();
    }
  }, []);

  const value = state;

  return (
    <ReplayContext.Provider value={value}>
      <Replay />
    </ReplayContext.Provider>
  )
}

export default ReplayContainer;

export const Replay: React.FC<{}> = () => {
  const state = useReplayContext();
  const {dispatch} = useRootContext();


  const handlePlayerClick = () => {
    if (!store.state || !store.state.player) return;
    if (store.state.isPlaying) {
      const player = store.state.player as Player;
      player.pause();
    } else {
      const player = store.state.player as Player;
      player.play();
    }
    // if (store.state.isPlaying) {
    //   store.state.player.paused();
    // } else {
    //   store.state.player.play();
    // }
  }

  const handleChange = (event: any, newValue: any) => {
    store.setCurrentTime(newValue);
    store.updateProgress(newValue);
  }


  const onWindowResize = () => {
    if (state.player) {
      state.player.refreshViewSize();
    }
  }

  const handleSpaceKey = (evt: any) => {
    if (evt.code === 'Space') {
      if (state.player) {
        handleOperationClick(state.player);
      }
    }
  }

  const handleOperationClick = (player: Player) => {
    switch (player.phase) {
      case PlayerPhase.WaitingFirstFrame:
      case PlayerPhase.Pause: {
        player.play();
        break;
      }
      case PlayerPhase.Playing: {
        player.pause();
        break;
      }
      case PlayerPhase.Ended: {
        player.seekToScheduleTime(0);
        break;
      }
    }
  }

  const {uuid, startTime, endTime} = useParams();


  const duration = useMemo(() => {
    if (!startTime || !endTime) return 0;
    return Math.abs(+startTime - +endTime);
  }, [startTime, endTime]);

  const {showToast} = useToast();

  const lock = useRef<boolean>(false);

  useEffect(() => {
    return () => {
      lock.current = true;
    }
  }, []);

  useEffect(() => {
    window.addEventListener('resize', onWindowResize);
    window.addEventListener('keydown', handleSpaceKey);
    if (uuid && startTime && endTime) {
      dispatch({ type: ActionType.LOADING, payload: true});
      store.joinRoom(uuid).then(({roomToken}) => {
        apiClient.client.replayRoom({
          beginTimestamp: +startTime,
          duration: duration,
          room: uuid,
          // mediaURL: state.mediaUrl,
          roomToken: roomToken,
        }, {
          onCatchErrorWhenRender: error => {
            error && console.warn(error);
            showToast({
              message: `Replay Failed please refresh browser`,
              type: 'notice'
            });
          },
          onCatchErrorWhenAppendFrame: error => {
            error && console.warn(error);
            showToast({
              message: `Replay Failed please refresh browser`,
              type: 'notice'
            });
          },
          onPhaseChanged: phase => {
            store.updatePhase(phase);
          },
          onLoadFirstFrame: () => {
            store.loadFirstFrame();
          },
          onSliceChanged: () => {
          },
          onPlayerStateChanged: (error) => {
          },
          onStoppedWithError: (error) => {
            dispatch({ type: ActionType.LOADING, payload: false});
            error && console.warn(error);
            showToast({
              message: `Replay Failed please refresh browser`,
              type: 'notice'
            });
            store.setReplayFail(true);
          },
          onScheduleTimeChanged: (scheduleTime) => {
            if (lock.current) return;
            store.setCurrentTime(scheduleTime);
          }
        }).then((player: Player) => {
          dispatch({ type: ActionType.LOADING, payload: false});
          store.setPlayer(player);
          player.bindHtmlElement(document.getElementById("whiteboard") as HTMLDivElement);
        }).catch(console.warn);
      });
    }
    return () => {
      console.log("unmounted");
      window.removeEventListener('resize', onWindowResize);
      window.removeEventListener('keydown', onWindowResize);
    }
  }, []);

  const totalTime = useMemo(() => {
    return moment(duration).format("mm:ss");
  }, [duration]);

  const time = useMemo(() => {
    return moment(state.currentTime).format("mm:ss");
  }, [state.currentTime]);

  return (
    <div className="replay">
      <div className={`player-container ${state.isPlaying ? '' : ''}`} >
        <div className="player">
          <div className="agora-logo"></div>
          <div id="whiteboard" className="whiteboard"></div>
          <div className="video-menu">
            <div className="control-btn">
              <div className={`btn ${state.isPlaying ? 'paused' : 'play'}`} onClick={handlePlayerClick}></div>
            </div>
            <div className="progress">
              <Slider
                className='custom-video-progress'
                value={state.currentTime}
                onMouseDown={() => {
                  if (store.state && store.state.player) {
                    const player = store.state.player as Player;
                    player.pause();
                    lock.current = true;
                  }
                }}
                onMouseUp={() => {
                  if (store.state && store.state.player) {
                    const player = store.state.player as Player;
                    player.seekToScheduleTime(state.currentTime);
                    player.play();
                    lock.current = false;
                  }
                }}
                onChange={handleChange}
                min={0}
                max={duration}
                aria-labelledby="continuous-slider"
              />
              <div className="time">
                <div className="current_duration">{time}</div>
                  /
                <div className="video_duration">{totalTime}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="video-container">
        <div className="video-player"></div>
        <div className="chat-holder"></div>
      </div>
    </div>
  )
}