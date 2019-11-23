//
//  EEStudentVideoView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCStudentVideoView.h"

@interface BCStudentVideoView ()
@property (strong, nonatomic) IBOutlet UIView *studentVideoView;
@property (weak, nonatomic) IBOutlet UIButton *videoMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *audioMuteButton;

@end

@implementation BCStudentVideoView

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
        [self addSubview:self.studentVideoView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.studentVideoView.frame = self.bounds;

}

- (IBAction)muteAudio:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMuteAudioButton)]) {
        [self.delegate clickMuteAudioButton];
    }
}

- (IBAction)muteVideo:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickMuteVideoButton)]) {
        [self.delegate clickMuteVideoButton];
    }
}

- (void)setButtonEnabled:(BOOL)enabled {
    [self.videoMuteButton setEnabled:enabled];
    [self.videoMuteButton setEnabled:enabled];
}

- (void)updateVideoImageWithMuteState:(BOOL)state {
    if (state) {
        [self.videoMuteButton setImage:[UIImage imageNamed:@"icon-video-on-min"] forState:(UIControlStateNormal)];
    }else {
        [self.videoMuteButton setImage:[UIImage imageNamed:@"icon-videooff-dark"] forState:(UIControlStateNormal)];
    }
}

- (void)updateAudioImageWithMuteState:(BOOL)state {
    if (state) {
        [self.audioMuteButton setImage:[UIImage imageNamed:@"icon-speakeroff-dark"] forState:(UIControlStateNormal)];
    }else {
        [self.audioMuteButton setImage:[UIImage imageNamed:@"icon-speaker3"] forState:(UIControlStateNormal)];
    }
}

- (void)updateImageName:(NSString *)name {
    [self.defaultImageView setImage:[UIImage imageNamed:name]];
}
@end
