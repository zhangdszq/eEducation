//
//  MessageManager.h
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
typedef void(^MessageManagerBlock)(void);

#define NOTICE_KEY_ON_MESSAGE_DISCONNECT @"NOTICE_KEY_ON_MESSAGE_DISCONNECT"
#define NOTICE_KEY_ON_SIGNAL_RECEIVED @"NOTICE_KEY_ON_SIGNAL_RECEIVED"

@protocol MessageDataSourceDelegate <NSObject>

@optional
- (void)onUpdateMessage:(AERoomMessageModel *_Nonnull)roomMessageModel;
- (void)onUpdateTeactherAttribute:(AETeactherModel *_Nullable)teactherModel;
- (void)onUpdateStudentsAttribute:(NSArray<RolesStudentInfoModel *> *_Nullable)studentInfoModels;
- (void)onMemberLeft:(NSString *_Nonnull)userId;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MessageManager : NSObject

@property(nonatomic, weak) id<MessageDataSourceDelegate> messageDelegate;

@property(nonatomic, strong) AETeactherModel *currentTeaModel;
@property(nonatomic, strong) AEStudentModel *currentStuModel;

+ (instancetype)shareManager;

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock;

- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock;

- (void)queryRolesInfoWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block;
- (void)updateStudentChannelAttrsWithVideoVisble:(BOOL)video audioVisble:(BOOL)audio completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock;

- (void)sendMessageWithText:(NSString *)messageText;
- (void)sendMessageWithText:(NSString *)messageText toPeer:(NSString *)peerId completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock;

- (void)leaveChannel;


@end

NS_ASSUME_NONNULL_END
