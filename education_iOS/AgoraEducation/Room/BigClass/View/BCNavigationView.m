//
//  EENavigationView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/24.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCNavigationView.h"


@interface BCNavigationView ()


@end

@implementation BCNavigationView

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
        [self addSubview:self.navigationView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.navigationView.frame = self.bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateChannelName:(NSString *)name {
    [self.titleLabel setText:name];
}

- (void)updateSignalImageName:(NSString *)name {
    [self.wifiSignalImage setImage:[UIImage imageNamed:name]];
}
@end
