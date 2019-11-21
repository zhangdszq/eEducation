//
//  EducationEnumerates.h
//  AgoraMiniClass
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
