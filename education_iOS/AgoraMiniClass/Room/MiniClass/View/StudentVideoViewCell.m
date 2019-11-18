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
@property (nonatomic, weak) UIImageView *volumeImageView;
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

- (void)setUserModel:(EEBCTeactherAttrs *)userModel {
    _userModel = userModel;
    self.nameLable.text = userModel.account;
    self.backImageView.hidden = userModel.video ? NO : YES;

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

    UIImageView *volumeImageView = [[UIImageView alloc] init];
    volumeImageView.frame = CGRectMake(75,50, 20, 20);
    [self.contentView addSubview:volumeImageView];
    volumeImageView.backgroundColor = [UIColor redColor];
    [volumeImageView setImage:[UIImage imageNamed:@"eeSpeaker3"]];
    self.volumeImageView = volumeImageView;
}

- (UILabel *)addNameLabel {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(0, 70-20, 95, 20);
    nameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:10.f];
    nameLabel.layer.cornerRadius = 2;
    return nameLabel;
}
@end
