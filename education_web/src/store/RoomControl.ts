import { Map } from "immutable";
import {createLogger, EasyState} from '../utils'

const roomStoreLog = createLogger('[RoomStore]', 'white', '#0050b3', true)

type UserInfo = {
  name: string;
  role: ClientRole;
  uid: number;
  streamId: number;
};

export default EasyState({
  state: {
    channelAttr: Map<string, string|number>(),
    studentList: Map<string, any>(),
    teacherList: Map<string, any>(),
    audienceList: Map<string, any>(),
    messageList: [] as Array<{uid: string, content: string, username: string, local: boolean}>
  },

  actions: {
    addMember(state, { members }) {
      let tempStudentsList = state.studentList;
      let tempTeacherList = state.teacherList;
      let tempAudienceList = state.audienceList;
      if (members instanceof Array) {
        for (let item of members) {
          if (Number(item.role) === 1) {
            // student
            tempStudentsList = tempStudentsList.set(item.uid, {
              ...item,
              video: true,
              audio: true,
              chat: true
            });
          }
          if (Number(item.role) === 2) {
            // teacher
            tempTeacherList = tempTeacherList.set(item.uid, item);
          }
          if (Number(item.role) === 0) {
            tempAudienceList = tempAudienceList.set(item.uid, item)
          }
        }
      } else {
        if(members) {
          if (Number(members.role) === 1) {
            // student
            tempStudentsList = tempStudentsList.set(members.uid, {
              ...members,
              video: true,
              audio: true,
              chat: true
            });
          }
          if (Number(members.role)=== 2) {
            // teacher
            tempTeacherList = tempTeacherList.set(members.uid, members);
          }
          if (Number(members.role)=== 0) {
            // teacher
            tempAudienceList = tempAudienceList.set(members.uid, members);
          }
        }
      }
      return {
        channelAttr: state.channelAttr,
        messageList: state.messageList,
        teacherList: tempTeacherList,
        studentList: tempStudentsList,
        audienceList: tempAudienceList,
      };
    },

    updateMember(state, { uid, attr}) {
      let tempStudentsList = state.studentList;
      let tempTeacherList = state.teacherList;
      let tempAudienceList = state.audienceList
      if (tempStudentsList.has(uid)) {
        tempStudentsList = tempStudentsList.update(uid, value => Object.assign({}, value, attr))
      } else if (tempTeacherList.has(uid)) {
        tempTeacherList = tempTeacherList.update(uid, value => Object.assign({}, value, attr))
      } else if (tempAudienceList.has(uid)) {
        tempAudienceList = tempAudienceList.update(uid, value => Object.assign({}, value, attr))
      }
      return {
        channelAttr: state.channelAttr,
        messageList: state.messageList,
        teacherList: tempTeacherList,
        studentList: tempStudentsList,
        audienceList: tempAudienceList,
      };
    },

    removeMember(state, { uid }) {
      let tempStudentsList = state.studentList.delete(uid);
      let tempTeacherList = state.teacherList.delete(uid);
      let tempAudienceList = state.audienceList.delete(uid);
      return {
        channelAttr: state.channelAttr,
        messageList: state.messageList,
        teacherList: tempTeacherList,
        studentList: tempStudentsList,
        audienceList: tempAudienceList,
      }
    },

    updateChannelAttr(state, {channelAttr}) {
      return {
        ...state,
        channelAttr: state.channelAttr.merge(channelAttr as typeof state.channelAttr)
      }
    },

    updateUserAttr(state, {uid, userAttr}) {
      let tempStudentsList = state.studentList;
      let tempTeacherList = state.teacherList;
      let tempAudienceList = state.audienceList;
      if (tempStudentsList.has(uid)) {
        tempStudentsList = tempStudentsList.set(uid, userAttr)
      } else if (tempTeacherList.has(uid)) {
        tempTeacherList = tempTeacherList.set(uid, userAttr)
      } else if (tempAudienceList.has(uid)) {
        tempAudienceList = tempAudienceList.set(uid, userAttr)
      }
      return {
        ...state,
        teacherList: tempTeacherList,
        studentList: tempStudentsList,
        audienceList: tempAudienceList,
      }
    },

    addChannelMessage(state, {uid, content, local}) {
      const user = state.studentList.merge(state.teacherList).merge(state.audienceList).get(uid);
      let name = 'unknown'
      if (user) {
        name = user.name
      }
      return {
        ...state,
        messageList: state.messageList.concat([{
          uid: uid, content, username: name, local
        }]),
      }
    },

    clear(state, {}) {
      return {
        channelAttr: Map<string, string|number>(),
        studentList: Map<string, any>(),
        teacherList: Map<string, any>(),
        audienceList: Map<string, any>(),
        messageList: [] as Array<{uid: string, content: string, username: string, local: boolean}>
      }
    }
  }
});
