//
//  EducationEnumerates.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/6/27.
//  Copyright © 2019 yangmoumou. All rights reserved.
//


typedef NS_ENUM(NSUInteger, ClassRoomRole) {
    ClassRoomRoleAudience  = 0,
    ClassRoomRoleStudent  = 1,
    ClassRoomRoleTeacther   = 2,
};

typedef NS_ENUM(NSUInteger, ClassRoomErrorcode) {
    ClassRoomErrorCodeInvalidArgument  = 0,
    ClassRoomErrorCodeInvalidServerRtmId  = 1,
    ClassRoomErrorCodeInvalidWhiteboard  = 2,
    ClassRoomErrorCodeNetDown  = 3,
};

typedef NS_ENUM(NSUInteger, NetworkSignal) {
    NetworkSignalGood = 0,
    NetworkSignalBad = 1,
};

typedef NS_ENUM(NSInteger, RotatingState)  {
    RotatingStateSmall,
    RotatingStateLandscape,
    RotatingStateAnimating,

};

typedef NS_ENUM(NSInteger, StudentLinkState) {
    StudentLinkStateIdle,
    StudentLinkStateApply,
    StudentLinkStateAccept,
    StudentLinkStateReject
};


typedef NS_ENUM(NSInteger, RTMp2pType) {
    RTMp2pTypeMuteAudio = 101,
    RTMp2pTypeUnMuteAudio = 102,
    RTMp2pTypeMuteVideo = 103,
    RTMp2pTypeUnMuteVideo = 104,
    RTMp2pTypeApply = 105,
    RTMp2pTypeAccept = 106,
    RTMp2pTypeReject = 107,
    RTMp2pTypeCancel = 108,
    RTMp2pTypeMuteChat = 109,
    RTMp2pTypeUnMuteChat = 110
};
