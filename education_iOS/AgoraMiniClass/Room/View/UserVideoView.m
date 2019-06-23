//
//  BaseVideoView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/16.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "UserVideoView.h"

@interface UserVideoView ()
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation UserVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.nameLabel];
        [self.nameLabel setText:@"22222"];
    }
    return self;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor blackColor];
        _nameLabel.alpha = 0.3;
    }
    return _nameLabel;
}
@end
