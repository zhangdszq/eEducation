//
//  EEStudentVideoView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEStudentVideoView.h"

@interface EEStudentVideoView ()
@property (weak, nonatomic) IBOutlet UIButton *videoMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *audioMuteButton;

@end

@implementation EEStudentVideoView

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
        [[NSBundle mainBundle] loadNibNamed:@"EEStudentVideoView" owner:self options:nil];
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
        [self.videoMuteButton setImage:[UIImage imageNamed:@"eevideoOff"] forState:(UIControlStateNormal)];
    }else {
        [self.videoMuteButton setImage:[UIImage imageNamed:@"eevideoOn-s"] forState:(UIControlStateNormal)];
    }
}

- (void)updateAudioImageWithMuteState:(BOOL)state {
    if (state) {
        [self.audioMuteButton setImage:[UIImage imageNamed:@"icon-speaker-off"] forState:(UIControlStateNormal)];
    }else {
        [self.audioMuteButton setImage:[UIImage imageNamed:@"roomMicon"] forState:(UIControlStateNormal)];
    }
}

@end
