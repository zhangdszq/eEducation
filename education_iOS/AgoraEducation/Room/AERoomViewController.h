//
//  AEViewController.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WhiteSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AERoomViewController : UIViewController
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;

@property (nonatomic, strong) WhiteBoardView *boardView;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong) WhiteRoom *room;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
@property (nonatomic, strong) WhiteMemberState *memberState;
@property (nonatomic, strong) UIColor *pencilColor;

@property (nonatomic, strong) AgoraRtmKit *rtmKit;
@property (nonatomic, strong) AgoraRtmChannel *rtmChannel;
@property (nonatomic, strong, nullable) AgoraRtcVideoCanvas *shareScreenCanvas;
@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;

- (void)joinRTMChannel;
- (void)joinWhiteBoardRoomUUID:(NSString *)uuid;
- (void)getWhiteboardSceneInfo;
- (void)addWhiteBoardViewToView:(UIView *)view;
- (void)addTeacherObserver;
- (void)removeTeacherObserver;
- (void)addShareScreenVideoWithUid:(NSInteger)uid;
- (void)removeShareScreen;
- (void)setWhiteBoardBrushColor;
@end

NS_ASSUME_NONNULL_END
