//
//  EEBCBaseView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEBCBaseView : UIView
@property (nonatomic) RotatingState rotatingState;
@property (nonatomic) CGRect beforeBounds;
@property (nonatomic) CGPoint beforeCenter;
@property (nonatomic, weak) UIView *parentView;
@end

NS_ASSUME_NONNULL_END
