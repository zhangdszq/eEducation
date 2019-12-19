//
//  EducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EducationManager.h"
#import "AERTMMessageBody.h"
#import "AgoraHttpRequest.h"

#import "SignalManager.h"
#import "WhiteManager.h"

@interface EducationManager()<WhiteManagerDelegate>

@property (nonatomic, strong) SignalManager *signalManager;
@property (nonatomic, strong) WhiteManager *whiteManager;

@property (nonatomic, weak) id<WhitePlayDelegate> whitePlayerDelegate;

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

- (instancetype)init {
    if(self = [super init]) {
        self.whiteManager = [[WhiteManager alloc] init];
        
    }
    return self;
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

#pragma mark WhiteManager
- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate {
    self.whitePlayerDelegate = whitePlayerDelegate;
    self.whiteManager.whiteManagerDelegate = self;
    [self.whiteManager initWhiteSDKWithBoardView:boardView config:[WhiteSdkConfiguration defaultConfig]];
}

- (void)joinWhiteRoomWithUuid:(NSString*)uuid completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    WEAK(self)
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {

        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        [weakself.whiteManager joinWhiteRoomWithWhiteRoomConfig:roomConfig completeSuccessBlock:^(WhiteRoom * _Nullable room) {
            
            if(successBlock != nil){
                successBlock(room);
            }
            
        } completeFailBlock:^(NSError * _Nullable error) {
            
            if(failBlock != nil){
                failBlock(error);
            }
        }];
        
    } failure:^(NSString * _Nonnull msg) {
        if(failBlock != nil){
            failBlock(nil);
        }
        NSLog(@"EducationManager Get Room Token Err:%@", msg);
    }];
}

- (void)createWhiteReplayerWithModel:(ReplayerModel *)model completeSuccessBlock:(void (^) (WhitePlayer * _Nullable whitePlayer, AVPlayer * _Nullable avPlayer))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {

    WEAK(self)
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:model.uuid token:^(NSString * _Nonnull token) {

        WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:model.uuid roomToken:token];
        NSString *startTime = model.startTime;
        NSString *endTime = model.endTime;
        if(model.startTime.length == 13) {
            startTime = [model.startTime substringToIndex:10];
        }
        if(model.endTime.length == 13){
            endTime = [model.endTime substringToIndex:10];
        }
        NSInteger iStartTime = startTime.integerValue;
        NSInteger iEndTime = endTime.integerValue;

        playerConfig.beginTimestamp = @(iStartTime);
        playerConfig.duration = @(labs(iEndTime - iStartTime));
        
        [weakself.whiteManager createReplayerWithConfig:playerConfig completeSuccessBlock:^(WhitePlayer * _Nullable player) {
            
            AVPlayer *avPlayer;
            if(model.videoPath != nil && model.videoPath.length > 0){
                avPlayer = [weakself.whiteManager createCombinePlayerWithVideoPath: model.videoPath];
            }
            if(successBlock != nil){
                successBlock(player, avPlayer);
            }
            
        } completeFailBlock:^(NSError * _Nullable error) {
            
            if(failBlock != nil){
                failBlock(error);
            }
        }];
        
    } failure:^(NSString * _Nonnull msg) {
        if(failBlock != nil){
            failBlock(nil);
        }
        NSLog(@"EducationManager CreateReplayer Err:%@", msg);
    }];
}

- (void)disableWhiteDeviceInputs:(BOOL)disable {
    [self.whiteManager disableDeviceInputs:disable];
}

- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor {
    self.whiteManager.whiteMemberState.strokeColor = strokeColor;
    [self.whiteManager setMemberState:self.whiteManager.whiteMemberState];
}

- (void)setWhiteApplianceName:(NSString *)applianceName {
    self.whiteManager.whiteMemberState.currentApplianceName = applianceName;
    [self.whiteManager setMemberState:self.whiteManager.whiteMemberState];
}

- (void)setWhiteMemberInput:(nonnull WhiteMemberState *)memberState {
    [self.whiteManager setMemberState:memberState];
}
- (void)refreshWhiteViewSize {
    [self.whiteManager refreshViewSize];
}
- (void)moveWhiteToContainer:(NSInteger)sceneIndex {
    WhiteSceneState *sceneState = self.whiteManager.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    WhiteScene *scene = scenes[sceneIndex];
    if (scene.ppt) {
        CGSize size = CGSizeMake(scene.ppt.width, scene.ppt.height);
        [self.whiteManager moveCameraToContainer:size];
    }
}

- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    [self.whiteManager setSceneIndex:index completionHandler:completionHandler];
}
- (void)seekWhiteToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler {
    
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager seekToCombineTime:time completionHandler:completionHandler];
    } else {
        NSTimeInterval seekTime = CMTimeGetSeconds(time);
        [self.whiteManager.player seekToScheduleTime:seekTime];
        if(completionHandler != nil){
            completionHandler(YES);
        }
    }
}
- (void)playWhite {
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager combinePlay];
    } else {
        [self.whiteManager play];
    }
}
- (void)pauseWhite {
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager combinePause];
    } else {
        [self.whiteManager pause];
    }
}
- (void)stopWhite {
    [self.whiteManager stop];
}

- (NSTimeInterval)whiteTotleTimeDuration {
    return [self.whiteManager timeDuration];
}

- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock {
    
    WhiteSceneState *sceneState = self.whiteManager.room.sceneState;
    NSArray<WhiteScene *> *scenes = sceneState.scenes;
    NSInteger sceneIndex = sceneState.index;
    if(completionBlock != nil){
        completionBlock(scenes.count, sceneIndex);
    }
}

#pragma mark WhiteManagerDelegate
- (void)phaseChanged:(WhitePlayerPhase)phase {
    
    // use nativePlayerDidFinish when videoPath no empty
    if(self.whiteManager.combinePlayer != nil){
        return;
    }
    
    if(phase == WhitePlayerPhaseWaitingFirstFrame || phase == WhitePlayerPhaseBuffering){
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerStartBuffering)]) {
            [self.whitePlayerDelegate whitePlayerStartBuffering];
        }
    } else if (phase == WhitePlayerPhasePlaying || phase == WhitePlayerPhasePause) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerEndBuffering)]) {
            [self.whitePlayerDelegate whitePlayerEndBuffering];
        }
    } else if(phase == WhitePlayerPhaseEnded) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerDidFinish)]) {
            [self.whitePlayerDelegate whitePlayerDidFinish];
        }
    }
}
/** 出错暂停 */
- (void)stoppedWithError:(NSError *)error {
    
    // use nativePlayerDidFinish when videoPath no empty
    if(self.whiteManager.combinePlayer != nil){
        return;
    }
    
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerError:)]) {
        [self.whitePlayerDelegate whitePlayerError: error];
    }
}
/** 进度时间变化 */
- (void)scheduleTimeChanged:(NSTimeInterval)time {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerTimeChanged:)]) {
        [self.whitePlayerDelegate whitePlayerTimeChanged: time];
    }
}

- (void)combinePlayerStartBuffering {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerStartBuffering)]) {
        [self.whitePlayerDelegate whitePlayerStartBuffering];
    }
}

/**
 结束缓冲状态，WhitePlayer，NativePlayer 全部完成缓冲，才会回调。
 */
- (void)combinePlayerEndBuffering {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerDidFinish)]) {
        [self.whitePlayerDelegate whitePlayerEndBuffering];
    }
}

/**
 NativePlayer 播放结束
 */
- (void)nativePlayerDidFinish {
    
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerEndBuffering)]) {
        [self.whitePlayerDelegate whitePlayerDidFinish];
    }
}

/**
播放失败

@param error 错误原因
 */
- (void)combineVideoPlayerError:(NSError *)error {
    if([self.whitePlayerDelegate respondsToSelector:@selector(whitePlayerError:)]) {
        [self.whitePlayerDelegate whitePlayerError: error];
    }
}

/**
 房间中RoomState属性，发生变化时，会触发该回调。
 @param modifyState 发生变化的 RoomState 内容
 */
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState {
    if (modifyState.sceneState) {
        if([self.whitePlayerDelegate respondsToSelector:@selector(whiteRoomStateChanged)]) {
            [self.whitePlayerDelegate whiteRoomStateChanged];
        }
    }
}

- (void)releaseResources {
    [self.whiteManager releaseResources];
}

@end
