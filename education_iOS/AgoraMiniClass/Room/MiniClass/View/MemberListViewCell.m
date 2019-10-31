//
//  MemberListViewCell.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MemberListViewCell.h"

@interface MemberListViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tagImageView;

@end

@implementation MemberListViewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self.micButton setBackgroundImage:[UIImage imageNamed:@"roomMicon"] forState:(UIControlStateNormal)];
    }
    return self;
}

- (IBAction)muteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender == self.cameraButton) {
        self.roomUserModel.isMuteVideo = sender.selected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectCellCameraIsMute:userModel:)]) {
            [self.delegate selectCellCameraIsMute:sender.selected userModel:self.roomUserModel];
        }
    }else {
        self.roomUserModel.isMuteVideo = sender.selected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectCellMicIsMute:userModel:)]) {
            [self.delegate selectCellMicIsMute:sender.selected userModel:self.roomUserModel];
        }
    }
    [self updateBackgroundImageButton:sender];
}

- (void)updateBackgroundImageButton:(UIButton *)sender {
    if (sender == self.cameraButton) {
        if (sender.selected) {
            [sender setBackgroundImage:[UIImage imageNamed:@"roomCameraOff"] forState:(UIControlStateNormal)];
        }else {
            [sender setBackgroundImage:[UIImage imageNamed:@"roomCameraOn"] forState:(UIControlStateNormal)];
        }
    }else {
        if (sender.selected) {
            [sender setBackgroundImage:[UIImage imageNamed:@"roomMicOff"] forState:(UIControlStateNormal)];
        }else {
            [sender setBackgroundImage:[UIImage imageNamed:@"roomMicon"] forState:(UIControlStateNormal)];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setRoomUserModel:(RoomUserModel *)roomUserModel {
    _roomUserModel = roomUserModel;
    self.nameLabel.text = roomUserModel.name;
    self.cameraButton.selected = self.roomUserModel.isMuteVideo ? YES : NO;
    self.micButton.selected = self.roomUserModel.isMuteAudio ? YES : NO;
    [self updateBackgroundImageButton:self.cameraButton];
    [self updateBackgroundImageButton:self.micButton];
}

- (void)setIsTeacther:(BOOL)isTeacther {
    _isTeacther = isTeacther;
    if (isTeacther) {
        self.cameraButton.hidden = NO;
        self.micButton.hidden = NO;
    }else {
        self.cameraButton.hidden = YES;
        self.micButton.hidden = YES;
    }
}
@end
