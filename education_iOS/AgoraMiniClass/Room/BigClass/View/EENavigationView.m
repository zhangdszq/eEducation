//
//  EENavigationView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/24.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EENavigationView.h"


@interface EENavigationView ()


@end

@implementation EENavigationView

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
        [[NSBundle mainBundle] loadNibNamed:@"EENavigationView" owner:self options:nil];
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

    NSLog(@"ssssssss ---- %f",self.frame.size.width);
}
@end
