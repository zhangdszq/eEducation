//
//  ReplayNoVideoViewController.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/17.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReplayViewController : UIViewController

@property (strong, nonatomic) NSString *roomid;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSString *videoPath;

@end

NS_ASSUME_NONNULL_END

