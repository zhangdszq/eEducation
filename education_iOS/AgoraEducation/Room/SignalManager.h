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
typedef void(^ManagerBlock)(void);

#define NOTICE_KEY_ON_MESSAGE_DISCONNECT @"NOTICE_KEY_ON_MESSAGE_DISCONNECT"
#define NOTICE_KEY_ON_SIGNAL_RECEIVED @"NOTICE_KEY_ON_SIGNAL_RECEIVED"

@protocol SignalDelegate <NSObject>

@optional
- (void)onUpdateMessage:(AERoomMessageModel *_Nonnull)roomMessageModel;
- (void)onUpdateTeactherAttribute:(AETeactherModel *_Nullable)teactherModel;
- (void)onUpdateStudentsAttribute:(NSArray<RolesStudentInfoModel *> *_Nullable)studentInfoModels;
- (void)onMemberLeft:(NSString *_Nonnull)userId;
@end

NS_ASSUME_NONNULL_BEGIN

@interface SignalManager : NSObject

@property(nonatomic, weak) id<SignalDelegate> _Nullable messageDelegate;

@property(nonatomic, strong) MessageModel *messageModel;
@property(nonatomic, strong) AETeactherModel * _Nullable currentTeaModel;
@property(nonatomic, strong) AEStudentModel * _Nullable currentStuModel;

+ (instancetype)shareManager;

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock;

- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock;

- (void)queryGlobalStateWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block;

- (void)updateGlobalStateWithValue:(NSString *)value  completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock;

- (void)sendMessageWithValue:(NSString *)value;

- (void)setSignalWithValue:(NSString *)value toPeer:(NSString *)peerId completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock;

- (void)leaveChannel;


@end

NS_ASSUME_NONNULL_END
