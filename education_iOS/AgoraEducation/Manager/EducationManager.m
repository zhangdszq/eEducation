//
//  EducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EducationManager.h"
#import "AERTMMessageBody.h"
#import "SignalManager.h"

#define kWhiteBoardUrl  @"https://cloudcapiv4.herewhite.com"
#define kPOSTCreateWhiteBoardUrl [kWhiteBoardUrl stringByAppendingString:@"/room"]
#define kPOSTJoinWhiteBoardUrl [kWhiteBoardUrl stringByAppendingString:@"/room/join"]

@interface EducationManager()

@property (nonatomic, strong) SignalManager *signalManager;


@end

static EducationManager *manager = nil;

@implementation EducationManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock {
    
    self.signalManager = [SignalManager alloc];
    
//    self.messageModel = model;
//    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:model.appId delegate:self];
//    [self.agoraRtmKit loginByToken:model.token user:model.uid completion:^(AgoraRtmLoginErrorCode errorCode) {
//        if (errorCode == AgoraRtmLoginErrorOk) {
//            NSLog(@"rtm login success");
//            if(successBlock != nil){
//                successBlock();
//            }
//
//        } else {
//            if(failBlock != nil){
//                failBlock();
//            }
//        }
//    }];
}

- (void)sendMessageWithValue:(NSString *)value {
//    SignalManager.shareManager.currentStuModel =
//
//
//    NSString *value = [AERTMMessageBody sendP2PMessageWithName:self.userName content:content];
//    [SignalManager.shareManager sendMessageWithValue:value];
}

#pragma mark --whitemanager
- (void)sdf {
    WEAK(self)
    
//    AgoraHttpRequest POSTWhiteBoardRoomWithUuid
//        [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
//            WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
//            [whiteSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
//                weakself.room = room;
//
//    //            [weakself.room setViewMode:WhiteViewModeFollower];
//
//                [room refreshViewSize];
//
//                [weakself.room disableDeviceInputs:disableDevice];
//
//                NSArray<WhiteScene *> *scenes = room.state.sceneState.scenes;
//                NSInteger sceneIndex = room.state.sceneState.index;
//                weakself.sceneCount = scenes.count;
//                weakself.sceneIndex = sceneIndex;
//                [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
//
//                WhiteScene *scene = scenes[sceneIndex];
//                if (scene.ppt) {
//                    [weakself.room moveCameraToContainer:[[WhiteRectangleConfig alloc] initWithInitialPosition:scene.ppt.width height:scene.ppt.height]];
//                }
//            }];
//        } failure:^(NSString * _Nonnull msg) {
//            NSLog(@"获取失败 %@",msg);
//        }];
}

@end
