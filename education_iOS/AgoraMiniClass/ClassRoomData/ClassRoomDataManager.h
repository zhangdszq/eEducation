//
//  ClassRoomDataManager.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/6/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomUserModel.h"
#import "RoomMessageModel.h"




@protocol ClassRoomDataManagerDelegate <NSObject>
@optional
- (void)joinClassRoomSuccess;
- (void)joinClassRoomError:(ClassRoomErrorcode)errorCode;
- (void)teactherJoinSuccess;
- (void)teactherLeaveClassRoom;
- (void)updateStudentList;
- (void)updateChatMessageList;
- (void)muteLoaclVideoStream:(BOOL)stream;
- (void)muteLoaclAudioStream:(BOOL)stream;
@end

NS_ASSUME_NONNULL_BEGIN

@interface ClassRoomDataManager : NSObject
+ (instancetype)shareManager;
@property (nonatomic, weak) id <ClassRoomDataManagerDelegate> classRoomManagerDelegate;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) ClassRoomRole roomRole;
@property (nonatomic, copy) NSString *serverRtmId;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) NSMutableArray <RoomUserModel *> *studentArray;
@property (nonatomic, strong) NSMutableArray <RoomMessageModel *> *messageArray;
@property (nonatomic, strong) NSMutableArray <RoomUserModel *> *teactherArray;//写成数组的原因是后台没有限制进入频道的教师身份
@property (nonatomic, strong) NSMutableDictionary <NSString *,RoomUserModel *> *memberInfo;
@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, copy)  NSString *uuid;
@property (nonatomic, copy)  NSString *roomToken;
- (void)sendMessage:(NSString *)message completion:(AgoraRtmSendPeerMessageBlock _Nullable)completionBlock;
- (void)removeClassRoomInfo;
- (void)joinClassRoom;
@end

NS_ASSUME_NONNULL_END
