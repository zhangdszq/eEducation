//
//  EEStudentVideoView.h
//  AgoraMiniClass
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

@interface EEStudentVideoView : UIView
@property (weak, nonatomic) id<StudentViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *studentVideoView;
@property (weak, nonatomic) IBOutlet UIView *studentRenderView;
- (void)setButtonEnabled:(BOOL)enabled;
- (void)updateVideoImageWithMuteState:(BOOL)state;
- (void)updateAudioImageWithMuteState:(BOOL)state;
@end

NS_ASSUME_NONNULL_END
