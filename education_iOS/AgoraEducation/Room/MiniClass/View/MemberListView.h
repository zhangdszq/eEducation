//
//  MemberListView.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RoomUserModel;
typedef void(^MuteCamera)(BOOL isMute,RoomUserModel * _Nullable userModel);
typedef void(^MuteMic)(BOOL isMute,RoomUserModel * _Nullable userModel);
NS_ASSUME_NONNULL_BEGIN

@interface MemberListView : UITableView
@property (nonatomic, strong) NSMutableArray *studentArray;
@property (nonatomic, assign) BOOL isTeacther;
@property (nonatomic, copy) MuteCamera muteCamera;
@property (nonatomic, copy) MuteMic muteMic;
@end

NS_ASSUME_NONNULL_END
