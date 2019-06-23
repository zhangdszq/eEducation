//
//  CameraMicTestViewController.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/11.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RoomRole) {
    RoomRoleTeacther   = 0,
    RoomRoleStudent  = 1,
    RoomRoleAudience   = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface CameraMicTestViewController : UIViewController
@property (nonatomic, assign) RoomRole roomRole;
@end

NS_ASSUME_NONNULL_END
