//
//  StudentVideoListView.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/16.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomUserModel.h"

typedef void(^ StudentVideoList)(UIView * _Nullable imageView, NSIndexPath * _Nullable indexPath);

NS_ASSUME_NONNULL_BEGIN

@interface StudentVideoListView : UIView
@property (nonatomic, strong) NSMutableArray *studentArray;
@property (nonatomic, copy) StudentVideoList studentVideoList;
@end

NS_ASSUME_NONNULL_END
