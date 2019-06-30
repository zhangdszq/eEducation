//
//  RoomUserModel.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/6/24.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomUserModel : NSObject
@property (nonatomic, assign) ClassRoomRole role;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *channel;
@property (nonatomic, assign)   NSString *uid;
@property (nonatomic, assign) BOOL isMuteVideo;
@property (nonatomic, assign) BOOL isMuteAudio;
@end

NS_ASSUME_NONNULL_END
