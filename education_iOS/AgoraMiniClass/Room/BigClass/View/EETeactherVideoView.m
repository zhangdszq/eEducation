//
//  EERemoteVideoView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EETeactherVideoView.h"

@implementation EETeactherVideoView

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
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:self.teactherVideoView];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.teactherVideoView.frame = self.bounds;
}

- (void)layoutSubviews {
    
}
@end
