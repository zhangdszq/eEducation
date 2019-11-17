//
//  OneToOneNavigationView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/12.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EENavigationView.h"


@interface EENavigationView ()
@property (strong, nonatomic) IBOutlet UIView *navigationView;
@property (strong, nonatomic) IBOutlet UIView *wifiSigView;
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation EENavigationView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.navigationView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.navigationView.frame = self.bounds;
}


@end
