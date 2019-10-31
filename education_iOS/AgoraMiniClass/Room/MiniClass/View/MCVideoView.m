//
//  MSVideoView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/8.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCVideoView.h"


@interface MCVideoView ()
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *wifiImageView;

@end

@implementation  MCVideoView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUpView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)layoutSubviews {
    self.videoView.frame = self.bounds;
    self.defaultImageView.frame = self.bounds;
    self.nameLabel.frame = CGRectMake(0, self.bounds.size.height - 20, 85, 20);
    self.wifiImageView.frame = CGRectMake(self.bounds.size.width - 15, 0, 15, 15);
}

- (void)setUpView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2.f;
    
    UIView *videoView = [[UIView alloc] init];
    [self addSubview:videoView];
    self.videoView = videoView;

    UIImageView *defaultImageView = [[UIImageView alloc] init];
    [self addSubview:defaultImageView];
    defaultImageView.image = [UIImage imageNamed:@"videoBackgroundImage"];
    self.defaultImageView = defaultImageView;

    UILabel *nameLabel = [[UILabel alloc] init];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:14.f]];
    nameLabel.backgroundColor = [UIColor blackColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.alpha = 0.5;
    nameLabel.layer.cornerRadius = 2;
    nameLabel.layer.masksToBounds = YES;

    UIImageView *wifiImageView = [[UIImageView alloc] init];
    [self addSubview:wifiImageView];
    self.wifiImageView = wifiImageView;
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    self.nameLabel.text = userName;
}

- (void)updateNetworkSignalImage:(NSString *)imageName {
    [self.wifiImageView setImage:[UIImage imageNamed:imageName]];
}
@end
