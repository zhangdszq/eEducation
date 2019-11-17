//
//  OTOStudentView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "OTOStudentView.h"

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
    if (self.muteMic) {
        self.muteMic(!sender.selected);
    }
    sender.selected = !sender.selected;
}

- (IBAction)muteVideo:(UIButton *)sender {
    if (self.muteVideo) {
        self.muteVideo(!sender.selected);
    }
    sender.selected = !sender.selected;
}


@end
