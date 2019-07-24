//
//  RoomManageView.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/17.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^RoomTopButtonType)(UIButton * _Nullable button);
NS_ASSUME_NONNULL_BEGIN

@interface RoomManageView : UIView
@property (nonatomic, assign) ClassRoomRole classRoomRole;
@property (nonatomic, copy) RoomTopButtonType topButtonType;
@end

NS_ASSUME_NONNULL_END
