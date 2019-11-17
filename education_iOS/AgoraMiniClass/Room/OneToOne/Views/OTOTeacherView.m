
//
//  OTOTeacherView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "OTOTeacherView.h"


@interface OTOTeacherView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *speakerImageView;
@end

@implementation OTOTeacherView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:self.teacherView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.teacherView.frame = self.bounds;
}

- (void)updateSpeakerEnabled:(BOOL)enable volume:(CGFloat)volume {

}
@end
