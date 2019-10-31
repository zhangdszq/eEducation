//
//  EEWhiteboardTool.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEWhiteboardTool.h"

@implementation EEWhiteboardTool

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
        [self addSubview:self.whiteboardTool];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.whiteboardTool.frame = self.bounds;
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 6;
    self.layer.masksToBounds = YES;
}

- (IBAction)clickEvent:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectWhiteboardToolIndex:)]) {
        [self.delegate selectWhiteboardToolIndex:sender.tag - 200];
    }
}

@end
