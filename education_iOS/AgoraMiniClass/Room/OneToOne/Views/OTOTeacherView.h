//
//  OTOTeacherView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTOTeacherView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;
@property (strong, nonatomic) IBOutlet UIView *teacherView;
- (void)updateSpeakerEnabled:(BOOL)enable volume:(CGFloat)volume;
@end

NS_ASSUME_NONNULL_END
