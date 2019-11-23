//
//  EEBCBaseView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEBCBaseView.h"
#import "BCNavigationView.h"

@implementation EEBCBaseView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.rotatingState = RotatingStateSmall;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view  in self.subviews) {
        if ([view isKindOfClass:[BCNavigationView class]]) {
            BCNavigationView *navigation = (BCNavigationView *)view;
            [self verticalToFullScreen:navigation];
        }
    }
}

- (void)verticalToFullScreen:(BCNavigationView *)view {
    NSLog(@"self----- %f",self.frame.size.width);
     CGFloat navigationBarHeight =  (kScreenHeight / kScreenWidth > 1.78) ? 88 : 64;
    if (kScreenWidth > kScreenHeight) {
        view.frame = CGRectMake(0, 0, kScreenWidth, 30);
        view.titleLabelBottomConstraint.constant = 5;
        view.closeButtonBottomConstraint.constant = 5;
        view.wifiSignalImage.hidden = NO;
    }else {
        view.frame = CGRectMake(0, 0, kScreenWidth, navigationBarHeight);
        view.titleLabelBottomConstraint.constant = 20;
        view.closeButtonBottomConstraint.constant = 7;
        view.wifiSignalImage.hidden = YES;
    }
}
- (void)setBeforeBounds:(CGRect)beforeBounds {
    _beforeBounds = beforeBounds;
}
- (void)setBeforeCenter:(CGPoint)beforeCenter {
    _beforeCenter = beforeCenter;
}
@end
