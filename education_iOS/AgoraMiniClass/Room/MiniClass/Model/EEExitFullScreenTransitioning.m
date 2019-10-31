//
//  EEExitFullScreenTransitioning.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEExitFullScreenTransitioning.h"
#import "BCViewController.h"

@implementation EEExitFullScreenTransitioning
- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIView  *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    if (![toViewController isKindOfClass:[BCViewController class]]) {
//        return;
//    }
    toView.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    [transitionContext.containerView insertSubview:toView belowSubview:fromView];
    fromView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
        fromView.transform = CGAffineTransformIdentity;
        fromView.bounds = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    } completion:^(BOOL finished) {
        fromView.transform = CGAffineTransformIdentity;
        fromView.bounds = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
        [fromView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];

}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}
@end
