//
//  SignalManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "RolesInfoModel.h"
#import "AERoomMessageModel.h"

typedef NSString *RoleType NS_STRING_ENUM;
FOUNDATION_EXPORT RoleType const _Nonnull RoleTypeTeacther;

typedef void(^QueryRolesInfoBlock)(RolesInfoModel * _Nullable);

@protocol RTMDelegate <NSObject>
@optional
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason;
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId;
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member;
- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes;
@end


NS_ASSUME_NONNULL_BEGIN

@interface SignalManager : NSObject

@property (nonatomic, weak) id<RTMDelegate> _Nullable rtmDelegate;
@property (nonatomic, strong) MessageModel * _Nullable messageModel;
@property (nonatomic, strong) NSString * _Nullable channelName;

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;

- (void)getChannelAllAttributes:(NSString *)channelName completeBlock:(void (^) (NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes))block;
- (void)updateChannelAttributesWithChannelName:(NSString *)channelName channelAttribute:(AgoraRtmChannelAttribute *)attribute completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (void))failBlock;

- (void)queryPeersOnlineStatus:(NSArray<NSString*> *_Nonnull)peerIds completion:(AgoraRtmQueryPeersOnlineBlock _Nullable)completionBlock;

- (void)sendMessage:(NSString *)value completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (void))failBlock;
- (void)sendMessage:(NSString *)value toPeer:(NSString *)peerId completeSuccessBlock:(void (^) (void))successBlock completeFailBlock:(void (^) (void))failBlock;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
