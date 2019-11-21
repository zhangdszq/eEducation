//
//  StudentVideoViewCell.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEBCStudentAttrs.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentVideoCell : UICollectionViewCell
@property (nonatomic, weak) UIView *videoCanvasView;
@property (nonatomic, copy) EEBCStudentAttrs *userModel;

@end

NS_ASSUME_NONNULL_END
