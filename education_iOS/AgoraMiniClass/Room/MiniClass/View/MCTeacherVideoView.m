//
//  MCTeacherVideoView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCTeacherVideoView.h"




@implementation MCTeacherVideoView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.teacherVideoView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.teacherVideoView.frame = self.bounds;
}

@end
