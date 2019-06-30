//
//  ClassRoomDataManager.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/6/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClassRoomDataManager : NSObject
+ (instancetype)shareManager;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) ClassRoomRole roomRole;
@property (nonatomic, copy) NSString *serverRtmId;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) NSMutableArray <RoomUserModel *> *memberArray;
@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, copy)  NSString *uuid;
@property (nonatomic, copy)  NSString *roomToken;
@property (nonatomic, copy)  NSString *teactherId;

@end

NS_ASSUME_NONNULL_END
