//
//  EduButton.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EduButton.h"

@implementation EduButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    // 扩大点击区域
    bounds = CGRectInset(bounds, -20, -20);
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}

@end
