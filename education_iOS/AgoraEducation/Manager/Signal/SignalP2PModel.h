//
//  SignalP2PModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StudentLinkState) {
    StudentLinkStateIdle,
    StudentLinkStateApply,
    StudentLinkStateAccept,
    StudentLinkStateReject
};

typedef NS_ENUM(NSInteger, SignalP2PType) {
    SignalP2PTypeMuteAudio = 101,
    SignalP2PTypeUnMuteAudio = 102,
    SignalP2PTypeMuteVideo = 103,
    SignalP2PTypeUnMuteVideo = 104,
    SignalP2PTypeApply = 105,
    SignalP2PTypeAccept = 106,
    SignalP2PTypeReject = 107,
    SignalP2PTypeCancel = 108,
    SignalP2PTypeMuteChat = 109,
    SignalP2PTypeUnMuteChat = 110,
    SignalP2PTypeMuteBoard = 200,
    SignalP2PTypeUnMuteBoard = 201
};

NS_ASSUME_NONNULL_BEGIN

@interface SignalP2PModel : NSObject
@property (nonatomic, assign) SignalP2PType cmd;
@property (nonatomic, copy) NSString *text;
@end

NS_ASSUME_NONNULL_END
