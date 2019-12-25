//
//  EENavigationView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/24.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCNavigationView.h"


@interface BCNavigationView ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@end

@implementation BCNavigationView
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

- (void)updateClassName:(NSString *)name {
    [self.titleLabel setText:name];
}

- (void)updateSignalImageName:(NSString *)name {
    [self.wifiSignalImage setImage:[UIImage imageNamed:name]];
}
- (IBAction)colseRoom:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeRoom)]) {
        [self.delegate closeRoom];
    }
}

@end
