//
//  MCVideoView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/8.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MCVideoView : UIView
@property (nonatomic, weak) UIView *videoView;
@property (nonatomic, weak) UIImageView *defaultImageView;
@property (nonatomic, copy) NSString *userName;
- (void)updateNetworkSignalImage:(NSString *)imageName;
@end

NS_ASSUME_NONNULL_END
