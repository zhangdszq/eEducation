//
//  EENavigationView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/24.
//  Copyright © 2019 Agora. All rights reserved.
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
        self.navigationView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.navigationView];
        
        NSLayoutConstraint *viewTopConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *viewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *viewRightConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *viewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.navigationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self addConstraints:@[viewTopConstraint, viewLeftConstraint, viewRightConstraint, viewBottomConstraint]];
        
    }
    return self;
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
