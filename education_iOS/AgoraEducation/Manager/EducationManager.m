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
#import "RTCManager.h"


@interface EducationManager()<WhiteManagerDelegate, RTCManagerDelegate>

@property (nonatomic, strong) SignalManager *signalManager;

@property (nonatomic, strong) WhiteManager *whiteManager;
@property (nonatomic, weak) id<WhitePlayDelegate> whitePlayerDelegate;

@property (nonatomic, strong) RTCManager *rtcManager;
@property (nonatomic, weak) id<RTCDelegate> rtcDelegate;
@property (nonatomic, strong) NSMutableArray<RTCVideoSessionModel*> *rtcVideoSessionModels;


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

#pragma mark RTCManager
- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate {
    
    self.rtcDelegate = rtcDelegate;
    self.rtcVideoSessionModels = [NSMutableArray array];
    
    self.rtcManager = [[RTCManager alloc] init];
    self.rtcManager.rtcManagerDelegate = self;
    [self.rtcManager initEngineKit:appid];
    [self.rtcManager setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcManager enableVideo];
    [self.rtcManager startPreview];
    [self.rtcManager enableWebSdkInteroperability:YES];
    [self.rtcManager enableDualStreamMode:YES];
    [self setRTCClientRole: role];
}

- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock {
    
    return [self.rtcManager joinChannelByToken:token channelId:channelId info:info uid:uid joinSuccess:joinSuccessBlock];
}

- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *) model {
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = model.uid;
    videoCanvas.view = model.videoView;
    
    if(model.renderMode == RTCVideoRenderModeFit) {
        videoCanvas.renderMode = AgoraVideoRenderModeFit;
    } else if(model.renderMode == RTCVideoRenderModeHidden){
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    }

    if(model.canvasType == RTCVideoCanvasTypeLocal) {
        [self.rtcManager setupLocalVideo: videoCanvas];
    } else if(model.canvasType == RTCVideoCanvasTypeRemote) {
        [self.rtcManager setupRemoteVideo: videoCanvas];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", model.uid];
    NSArray<RTCVideoSessionModel *> *filteredArray = [self.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        
        RTCVideoSessionModel *videoSessionModel = filteredArray.firstObject;
        videoSessionModel.videoCanvas.view = nil;
        videoSessionModel.videoCanvas = videoCanvas;
    } else {
        RTCVideoSessionModel *videoSessionModel = [RTCVideoSessionModel new];
        videoSessionModel.uid = model.uid;
        videoSessionModel.videoCanvas = videoCanvas;
        [self.rtcVideoSessionModels addObject:videoSessionModel];
    }
}

- (void)removeRTCVideoCanvas:(NSUInteger) uid {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid != %d", uid];
    NSArray<RTCVideoSessionModel *> *filteredArray = [self.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
    self.rtcVideoSessionModels = [NSMutableArray arrayWithArray:filteredArray];
}

- (void)setRTCClientRole:(RTCClientRole)role {
    if(role == RTCClientRoleAudience){
        [self.rtcManager setClientRole:(AgoraClientRoleAudience)];
    } else if(role == RTCClientRoleBroadcaster){
        [self.rtcManager setClientRole:(AgoraClientRoleBroadcaster)];
    }
}
- (int)setRTCRemoteStreamWithUid:(NSUInteger)uid type:(RTCVideoStreamType)streamType {
    if(streamType == RTCVideoStreamTypeLow){
        return [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeLow];
    } else if(streamType == RTCVideoStreamTypeHigh){
        return [self.rtcManager setRemoteVideoStream:uid type:AgoraVideoStreamTypeHigh];
    }
    return -1;
}
- (int)enableRTCLocalVideo:(BOOL) enabled {
    return [self.rtcManager muteLocalVideoStream:enabled];
}
- (int)enableRTCLocalAudio:(BOOL) enabled {
    return [self.rtcManager muteLocalAudioStream:enabled];
}

#pragma mark RTCManagerDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidJoinedOfUid:)]) {
        [self.rtcDelegate rtcDidJoinedOfUid:uid];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidOfflineOfUid:)]) {
        [self.rtcDelegate rtcDidOfflineOfUid:uid];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type {
    
    RTCNetworkGrade grade = RTCNetworkGradeUnknown;
    
    switch (type) {
        case AgoraNetworkTypeUnknown:
        case AgoraNetworkTypeMobile4G:
        case AgoraNetworkTypeWIFI:
            grade = RTCNetworkGradeHigh;
            break;
        case AgoraNetworkTypeMobile3G:
        case AgoraNetworkTypeMobile2G:
            grade = RTCNetworkGradeMiddle;
            break;
        case AgoraNetworkTypeLAN:
        case AgoraNetworkTypeDisconnected:
            grade = RTCNetworkGradeLow;
            break;
        default:
            break;
    }
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcNetworkTypeGrade:)]) {
        [self.rtcDelegate rtcNetworkTypeGrade:grade];
    }
}

#pragma mark WhiteManager
- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate {
    
    self.whitePlayerDelegate = whitePlayerDelegate;
    
    self.whiteManager = [[WhiteManager alloc] init];
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

    NSAssert(model.startTime && model.startTime.length == 13, @"startTime should be millisecond unit");
    NSAssert(model.endTime && model.endTime.length == 13, @"endTime should be millisecond unit");
    
    WEAK(self)
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:model.uuid token:^(NSString * _Nonnull token) {

        WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:model.uuid roomToken:token];
        
        // make up
        NSInteger iStartTime = [model.startTime substringToIndex:10].integerValue;
        NSInteger iDuration = labs(model.endTime.integerValue - model.startTime.integerValue) * 0.001;

        playerConfig.beginTimestamp = @(iStartTime);
        playerConfig.duration = @(iDuration);
        
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
    
    for (RTCVideoSessionModel *model in self.rtcVideoSessionModels){
        model.videoCanvas.view = nil;
    }
    [self.rtcVideoSessionModels removeAllObjects];
    
    [self.whiteManager releaseResources];
    [self.rtcManager releaseResources];
}

@end
