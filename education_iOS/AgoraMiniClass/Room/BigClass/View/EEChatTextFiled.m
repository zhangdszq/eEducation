//
//  EEChatTextFiled.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEChatTextFiled.h"

@implementation EEChatTextFiled

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
        [self addSubview:self.chatTextFiled];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.chatTextFiled.frame = self.bounds;
    self.contentTextFiled.layer.cornerRadius = 17;
    self.contentTextFiled.layer.masksToBounds = YES;
    self.contentTextFiled.layer.borderWidth = 1.f;
    self.contentTextFiled.layer.borderColor = RCColorWithValue(0xDBE2E5, 1.f).CGColor;
}
@end
