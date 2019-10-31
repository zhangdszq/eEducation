//
//  StudentVideoViewCell.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/8/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "StudentVideoViewCell.h"

@interface StudentVideoViewCell ()
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UILabel *nameLable;
@property (nonatomic, weak) UIImageView *networkSignalView;
@end

@implementation StudentVideoViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUserModel:(RoomUserModel *)userModel {
    _userModel = userModel;
    self.nameLable.text = userModel.name;
    self.backImageView.hidden = userModel.isMuteVideo ? NO : YES;
    NSString *wifiImageName = userModel.netWorkSignal == NetworkSignalGood ? @"wifi_good" : @"wifi_bad";
    [self.networkSignalView setImage:[UIImage imageNamed:wifiImageName]];
}

- (void)setUpView {
    self.backgroundColor = [UIColor grayColor];
    UIView *videoCanvasView = [[UIView alloc] init];
    videoCanvasView.frame = self.contentView.bounds;
    [self.contentView addSubview:videoCanvasView];
    self.videoCanvasView = videoCanvasView;

    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.frame = self.contentView.bounds;
    [self.contentView addSubview:backImageView];
    backImageView.image = [UIImage imageNamed:@"videoBackgroundImage"];
    backImageView.backgroundColor = RCColorWithValue(0x666666, 1.0);
    self.backImageView = backImageView;

    UILabel *nameLable = [self addNameLabel];
    [self.contentView addSubview:nameLable];
    [self bringSubviewToFront:nameLable];
    self.nameLable = nameLable;

    UIImageView *networkSignalView = [[UIImageView alloc] init];
    networkSignalView.frame = CGRectMake(60, 0, 15, 15);
    [self.contentView addSubview:networkSignalView];
    networkSignalView.backgroundColor = [UIColor redColor];
    self.networkSignalView = networkSignalView;
}

- (UILabel *)addNameLabel {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(0, 75-17, 75, 17);
    nameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:10.f];
    nameLabel.layer.cornerRadius = 2;
    return nameLabel;
}
@end
