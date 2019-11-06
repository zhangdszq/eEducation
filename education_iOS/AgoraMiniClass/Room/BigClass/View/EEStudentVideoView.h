//
//  EEStudentVideoView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEStudentVideoView : UIView
@property (strong, nonatomic) IBOutlet UIView *studentVideoView;
@property (weak, nonatomic) IBOutlet UIView *studentRenderView;

- (void)updateVideoImage:(BOOL)videoImage;
- (void)updateAudioImage:(BOOL)audioImage;
@end

NS_ASSUME_NONNULL_END
