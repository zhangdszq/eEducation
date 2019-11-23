//
//  OTOStudentView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "OTOStudentView.h"

@interface OTOStudentView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *studentView;
@end


@implementation OTOStudentView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.studentView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.studentView.frame = self.bounds;
}

- (IBAction)muteMic:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
        [self.delegate muteAudioStream:sender.selected];
    }
    NSString *imageName = sender.selected ? @"icon-speaker-off" : @"icon-speaker3";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (IBAction)muteVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
         [self.delegate muteVideoStream:sender.selected];
     }
    NSString *imageName = sender.selected ? @"roomCameraOff" : @"roomCameraOn";
     [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)updateUserName:(NSString *)name {
    [self.nameLabel setText:name];
}
@end
