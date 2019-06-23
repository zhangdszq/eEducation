//
//  RoomViewController.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomViewController : UIViewController
@property (nonatomic, weak)   AgoraRtcEngineKit *agoraKit;
@property (nonatomic, copy)   NSString          *userName;
@property (nonatomic, copy)   NSString          *className;
@end

NS_ASSUME_NONNULL_END
