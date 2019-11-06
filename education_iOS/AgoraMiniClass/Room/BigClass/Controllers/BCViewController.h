//
//  BigClassViewController.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EENavigationView.h"
#import "EETeactherVideoView.h"
NS_ASSUME_NONNULL_BEGIN

@interface BCViewController : UIViewController
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) AgoraRtmKit *rtmKit;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;
@end

NS_ASSUME_NONNULL_END
