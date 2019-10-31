//
//  EELandscapeTransition.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/28.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEEnterFullScreenTransition.h"


@implementation EEEnterFullScreenTransition
- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [toController setNeedsStatusBarAppearanceUpdate];
//    CGPoint initalCenter =  [transitionContext.containerView convertPoint:self.baseView.beforeCenter fromView:self.baseView];
    [transitionContext.containerView addSubview:toView];
//    [toView addSubview:self.navigationView];
//    toView.bounds = self.baseView.beforeBounds;
//    toView.center = initalCenter;


    if ([toController isKindOfClass:[BCLeftViewController class]]) {
        toView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else {
        toView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:(UIViewAnimationOptionLayoutSubviews) animations:^{
        toView.transform = CGAffineTransformIdentity;
        toView.bounds = transitionContext.containerView.bounds;
        toView.center = transitionContext.containerView.center;

    } completion:^(BOOL finished) {
        toView.transform = CGAffineTransformIdentity;
        toView.bounds = transitionContext.containerView.bounds;
        toView.center = transitionContext.containerView.center;
       
        [transitionContext completeTransition:YES];
    }];

}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

@end
