import globalStorage from './custom-storage';
import MD5 from 'js-md5';
import { Map, List } from 'immutable';
import { defaultGlobalState, defaultRoomState, defaultUserState, RootState, defaultUIState } from './initialize-state';
import { User, ClassState, RootAction, ActionType, ChatMessage, TeacherInfo, AgoraStream, UserRole } from './types';
import { resolveStreamID, resolveUserJson } from '../utils/helper';

export const defaultState: RootState = {
  room: {
    ...defaultRoomState,
    ...globalStorage.read('room'),
    users: Map<string, User>(),
    classState: ClassState.CLOSED,
  },
  user: {
    ...defaultUserState,
    ...globalStorage.read('user'),
  },
  global: {
    ...defaultGlobalState,
  },
  ui: defaultUIState
};

export function RootReducer(state: RootState, action: RootAction): RootState {
  switch (action.type) {
    case ActionType.CLEAR_STATE: {
      return {
        user: defaultUserState,
        room: defaultRoomState,
        global: defaultGlobalState,
        ui: defaultUIState,
      }
    }
    case ActionType.ADD_USER:
      return {
        ...state,
        room: {
          ...state.room,
          users: state.room.users.set(action.user.id, action.user)
        }
      }
    case ActionType.UPDATE_USER:
      return {
        ...state,
        room: {
          ...state.room,
          users: state.room.users.update(action.user.id, value => {
            return Object.assign({}, value, action.user);
          })
        }
      }
    case ActionType.LOADING:
      return {
        ...state,
        global: {
          ...state.global,
          loading: action.payload
        }
      }
    case ActionType.REMOVE_USER: {
      return {
        ...state,
        room: {
          ...state.room,
          users: state.room.users.delete(action.user.id)
        }
      }
    }
    case ActionType.CLEAR_USERS:
      return {
        ...state,
        room: {
          ...state.room,
          users: Map<string, User>()
        }
      }
    case ActionType.ADD_ME:
      const { roomName, userName, role, roomType, id } = action.payload;

      // DEBUG
      // console.log(`addme: ${roomType}${roomName} ${roomType}${MD5(roomName)}`);

      return {
        ...state,
        user: {
          ...state.user,
          account: userName,
          id,
          role,
          streamID: resolveStreamID(id),
        },
        room: {
          ...state.room,
          rid: `${roomType}${MD5(roomName)}`,
          room: roomName,
          type: roomType,
          sharedId: 0,
          whiteboardId: '',
        }
      }
    case ActionType.ADD_MESSAGE: {
      const message = action.message;
      // const user = state.room.users.get(message.id);
      // if (message.id && !message.account && user) {
      //   message.account = user.account;
      // }
      return {
        ...state,
        global: {
          ...state.global,
          messages: state.global.messages.push(message),
        }
      }
    }
    case ActionType.CLEAR_MESSAGES:
      return {
        ...state,
        global: {
          ...state.global,
          messages: List<ChatMessage>(),
        }
      }
    case ActionType.UPDATE_CAN_PASS:
      return {
        ...state,
        global: {
          ...state.global,
          canPass: action.pass
        }
      }
    case ActionType.ADD_RTM_CLIENT:
      return {
        ...state,
        global: {
          ...state.global,
          rtmClient: action.client
        }
      }
    case ActionType.REMOVE_RTM_CLIENT:
      return {
        ...state,
        global: {
          ...state.global,
          rtmClient: undefined
        }
      }
    case ActionType.UPDATE_CHANNEL_ATTRS:
      const { teacher, accounts, room } = action.attrs;
      const _teacher = teacher as TeacherInfo

      const users = accounts.reduce((acc: Map<string, User>, it: any) => {
        return acc.set(it.uid, {
          role: it.role,
          account: it.account,
          id: it.uid,
          video: it.video,
          audio: it.audio,
          chat: it.chat,
        });
      }, Map<string, User>());
      // when current user is teacher
      if (_teacher.uid === state.user.id) {
        return {
          ...state,
          room: {
            ...state.room,
            classState: room.class_state === ClassState.CLOSED ? ClassState.CLOSED : ClassState.STARTED,
            whiteboardId: room.whiteboard_uid,
            sharedId: room.shared_uid,
            users,
            muteChat: room.mute_chat,
            linkId: room.link_uid
          },
          user: {
            ...state.user,
            ...resolveUserJson(_teacher),
          }
        }
      } else {
        const remoteCurrentUser = users.get(`${state.user.id}`);
        if (remoteCurrentUser) {
          return {
            ...state,
            room: {
              ...state.room,
              classState: room.class_state === ClassState.CLOSED ? ClassState.CLOSED : ClassState.STARTED,
              whiteboardId: room.whiteboard_uid,
              sharedId: room.shared_uid,
              muteChat: room.mute_chat,
              users,
              linkId: room.link_uid
            },
            user: {
              ...state.user,
              chat: remoteCurrentUser.chat,
              video: remoteCurrentUser.video,
              audio: remoteCurrentUser.audio,
            }
          }
        }
      }
      return {
        ...state,
        room: {
          ...state.room,
          classState: room.class_state === ClassState.CLOSED ? ClassState.CLOSED : ClassState.STARTED,
          whiteboardId: room.whiteboard_uid,
          sharedId: room.shared_uid,
          muteChat: room.mute_chat,
          users,
          linkId: room.link_uid,
        },
      }
    case ActionType.CLEAR_STREAMS:
      return {
        ...state,
        global: {
          ...state.global,
          localStream: undefined,
          sharedStream: undefined,
          remoteStreams: Map<string, AgoraStream>(),
        }
      };
    case ActionType.ADD_REMOTE_STREAM: {
      const remoteStreams = state.global.remoteStreams;
      const exists = remoteStreams.some(
        (it: any) => it.streamID === action.stream.streamID);
      if (exists) {
        return {
          ...state
        }
      }
      return {
        ...state,
        global: {
          ...state.global,
          remoteStreams: remoteStreams.set(`${action.stream.streamID}`, action.stream)
        }
      }
    }
    case ActionType.REMOVE_ALL_REMOTE_STREAMS:
      return {
        ...state,
        global: {
          ...state.global,
          remoteStreams: Map<string, any>()
        }
      }
    case ActionType.REMOVE_REMOTE_STREAM:
      return {
        ...state,
        global: {
          ...state.global,
          remoteStreams: state.global.remoteStreams.delete(`${action.streamID}`)
        }
      }
    case ActionType.ADD_LOCAL_STREAM: {
      return {
        ...state,
        global: {
          ...state.global,
          localStream: action.stream
        }
      }
    }
    case ActionType.REMOVE_LOCAL_STREAM:
      return {
        ...state,
        global: {
          ...state.global,
          localStream: undefined
        }
      }
    case ActionType.ADD_SHARED_STREAM: {
      return {
        ...state,
        global: {
          ...state.global,
          sharedStream: action.stream
        }
      }
    }
    case ActionType.REMOVE_SHARED_STREAM:
      return {
        ...state,
        global: {
          ...state.global,
          sharedStream: undefined
        }
      }
    case ActionType.UPDATE_WHITEBOARD_CONNECT_STATE:
      return {
        ...state,
        global: {
          ...state.global,
          whiteboard: {
            ...state.global.whiteboard,
            state: action.state
          }
        }
      }
    case ActionType.UPDATE_WHITEBOARD_UID: {
      return {
        ...state,
        user: {
          ...state.user,
          whiteboardId: action.uid
        }
      }
    }
    case ActionType.ADD_WHITEBOARD:
      return {
        ...state,
        global: {
          ...state.global,
          whiteboard: {
            ...state.global.whiteboard,
            client: action.client
          }
        }
      }
    case ActionType.REMOVE_WHITEBOARD:
      return {
        ...state,
        global: {
          ...state.global,
          whiteboard: {
            client: undefined,
            state: '',
            current: 1,
            total: 1
          }
        }
      }
    case ActionType.UPDATE_WHITEBOARD_PAGINATION: {
      return {
        ...state,
        global: {
          ...state.global,
          whiteboard: {
            ...state.global.whiteboard,
            current: action.current,
            total: action.total
          }
        }
      }
    }
    case ActionType.SAVE_MEDIA: {
      return {
        ...state,
        global: {
          ...state.global,
          mediaInfo: action.media
        }
      }
    }
    case ActionType.UPDATE_LOCAL_MEDIA_STATE: {
      const user = state.room.users.get(action.peerId);
      if (user && user.role === UserRole.teacher) {
        const { key, val } = action.mediaState
        return {
          ...state,
          user: {
            ...state.user,
            [`${key}`]: val,
          }
        }
      }
      return state;
    }
    case ActionType.ACCEPT_APPLY: {
      const peerId = action.peerId
      // not allow user self become host
      if (state.user.id === peerId) {
        return {
          ...state,
        }
      }

      return {
        ...state,
        global: {
          ...state.global,
          linkId: peerId
        }
      }
    }
    case ActionType.UPDATE_SCREEN_SHARING: {
      return {
        ...state,
        global: {
          ...state.global,
          screenSharing: action.sharing
        }
      }
    }
    case ActionType.ADD_DIALOG: {
      return {
        ...state,
        ui: {
          ...state.ui,
          dialog: action.dialog
        }
      }
    }
    case ActionType.REMOVE_DIALOG: {
      return {
        ...state,
        ui: {
          ...state.ui,
          dialog: {
            visible: false,
            type: '',
            desc: ''
          }
        }
      }
    }
    case ActionType.UPDATE_APPLY: {
      return {
        ...state,
        ui: {
          ...state.ui,
          apply: action.apply
        }
      }
    }
    case ActionType.NOTICE: {
      return {
        ...state,
        ui: {
          ...state.ui,
          notice: {
            reason: action.reason,
            text: action.text,
          }
        }
      }
    }
    case ActionType.ADD_TOAST: {
      return {
        ...state,
        ui: {
          ...state.ui,
          toast: action.toast
        }
      }
    }
    case ActionType.UPDATE_RTT: {
      return {
        ...state,
        global: {
          ...state.global,
          indicators: {
            ...state.global.indicators,
            rtt: action.rtt,
          }
        }
      }
    }
    case ActionType.UPDATE_QUALITY: {
      return {
        ...state,
        global: {
          ...state.global,
          indicators: {
            ...state.global.indicators,
            quality: action.quality
          }
        }
      }
    }
  }
  return state;
}