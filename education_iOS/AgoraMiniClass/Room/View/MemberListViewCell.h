//
//  MemberListViewCell.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomUserModel.h"


@protocol MemberListViewCellDelegate <NSObject>

- (void)selectCellCameraIsMute:(BOOL)mute userModel:(RoomUserModel *_Nullable)userModel;
- (void)selectCellMicIsMute:(BOOL)mute userModel:(RoomUserModel *_Nullable)userModel;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MemberListViewCell : UITableViewCell
@property (nonatomic, copy) RoomUserModel *roomUserModel;
@property (nonatomic, weak) id<MemberListViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL isTeacther;
@end

NS_ASSUME_NONNULL_END
