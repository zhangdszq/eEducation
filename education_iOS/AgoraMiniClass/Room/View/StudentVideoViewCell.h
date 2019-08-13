//
//  StudentVideoViewCell.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface StudentVideoViewCell : UICollectionViewCell
@property (nonatomic, weak) UIView *videoCanvasView;
@property (nonatomic, copy) RoomUserModel *userModel;
@end

NS_ASSUME_NONNULL_END
