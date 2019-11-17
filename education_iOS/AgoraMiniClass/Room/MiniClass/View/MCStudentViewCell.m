//
//  MCStudentViewCell.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCStudentViewCell.h"


@interface MCStudentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MCStudentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setStudentModel:(EEBCStudentAttrs *)studentModel {
    _studentModel = studentModel;
    [self.nameLabel setText:studentModel.account];
    NSString *audioImageName = studentModel.audio ? @"eeSpeaker3" : @"speaker-close";
    [self.muteAudioButton setImage:[UIImage imageNamed:audioImageName] forState:(UIControlStateNormal)];
    self.muteAudioButton.selected = studentModel.audio ? YES : NO;

    NSString *videoImageName = studentModel.video ? @"eevideoOn-s" : @"eevideoOff";
       [self.muteVideoButton setImage:[UIImage imageNamed:videoImageName] forState:(UIControlStateNormal)];
    self.muteVideoButton.selected = studentModel.audio ? YES : NO;
}
@end
