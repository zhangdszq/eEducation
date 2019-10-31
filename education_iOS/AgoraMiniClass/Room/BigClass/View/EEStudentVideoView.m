//
//  EEStudentVideoView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEStudentVideoView.h"

@implementation EEStudentVideoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EEStudentVideoView" owner:self options:nil];
        [self addSubview:self.studentVideoView];

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.studentVideoView.frame = self.bounds;
}

//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    CGRect rect = self.frame;
//    rect.origin.x = 0;
//    rect.origin.y = 0;
//    self.studentVideoView.frame = rect;
//}

@end
