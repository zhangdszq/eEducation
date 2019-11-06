//
//  BCFullScreenViewController.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEBCBaseView.h"
#import "EETeactherVideoView.h"
#import <WhiteSDK.h>
#import "EEBCStudentAttrs.h"
#import "RoomMessageModel.h"
#import "EEBCTeactherAttr.h"
#import "EEStudentVideoView.h"
NS_ASSUME_NONNULL_BEGIN

@interface BCFullScreenViewController : UIViewController
@property (nonatomic, weak) WhiteBoardView *baseWhiteboardView;
@property (nonatomic, strong) WhiteRoom *whiteRoom;
@property (nonatomic) AgoraRtcEngineKit *rtcEngineKit;
@property (nonatomic) AgoraRtmKit *rtmKit;
@property (nonatomic) AgoraRtmChannel *rtmChannel;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) EEBCStudentAttrs *selfAttrs;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (weak, nonatomic) IBOutlet EEStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet EETeactherVideoView *teacherVideoView;
@property (nonatomic, weak) AgoraRtcVideoCanvas *teacherCanvas;
@property (nonatomic, weak) AgoraRtcVideoCanvas *studentCanvas;
@end

NS_ASSUME_NONNULL_END
