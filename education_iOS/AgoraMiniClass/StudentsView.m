//
//  StudentsView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "StudentsView.h"

@implementation StudentsView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    for (int i = 0 ; i < 1; i++) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0,0,100,100);
        view.backgroundColor = [UIColor greenColor];
        [self addSubview:view];
    }
}
@end
