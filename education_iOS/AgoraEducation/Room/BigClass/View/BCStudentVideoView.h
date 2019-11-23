//
//  EEStudentVideoView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StudentViewDelegate <NSObject>
@optional
- (void)clickMuteVideoButton;
- (void)clickMuteAudioButton;
@end

NS_ASSUME_NONNULL_BEGIN

@interface BCStudentVideoView : UIView
@property (weak, nonatomic) id<StudentViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;


@property (weak, nonatomic) IBOutlet UIView *studentRenderView;
- (void)setButtonEnabled:(BOOL)enabled;
- (void)updateVideoImageWithMuteState:(BOOL)state;
- (void)updateAudioImageWithMuteState:(BOOL)state;
- (void)updateImageName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
