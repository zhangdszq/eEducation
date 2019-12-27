//
//  EducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/9.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "EducationManager.h"
#import "GenerateSignalBody.h"
#import "HttpManager.h"
#import "JsonParseUtil.h"

#import "SignalManager.h"
#import "WhiteManager.h"
#import "RTCManager.h"

@interface EducationManager()<SignalManagerDelegate, WhiteManagerDelegate, RTCManagerDelegate>

@property (nonatomic, strong) SignalManager *signalManager;
@property (nonatomic, weak) id<SignalDelegate> signalDelegate;

@property (nonatomic, strong) WhiteManager *whiteManager;
@property (nonatomic, weak) id<WhitePlayDelegate> whitePlayerDelegate;

@property (nonatomic, strong) RTCManager *rtcManager;
@property (nonatomic, weak) id<RTCDelegate> rtcDelegate;
@property (nonatomic, strong) NSMutableArray<RTCVideoSessionModel*> *rtcVideoSessionModels;

@end

@implementation EducationManager

#pragma mark SignalManager

- (void)initSignalWithModel:(SignalModel*)model dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {
    
    self.signalDelegate = signalDelegate;

    self.signalManager = [[SignalManager alloc] init];
    self.signalManager.rtmDelegate = self;
    self.signalManager.messageModel = model;
    [self.signalManager initWithMessageModel:model completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)setSignalDelegate:(id<SignalDelegate>)delegate {
    _signalDelegate = delegate;
}

- (void)initStudentWithUserName:(NSString *)userName {
    self.currentStuModel = [StudentModel new];
    self.currentStuModel.uid = self.signalManager.messageModel.uid;
    self.currentStuModel.account = userName;
    self.currentStuModel.video = 1;
    self.currentStuModel.audio = 1;
    self.currentStuModel.chat = 1;
}

- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {

    self.signalManager.channelName = channelName;
    [self.signalManager joinChannelWithName:channelName completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)queryGlobalStateWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block {
    
    WEAK(self);
    [self.signalManager getChannelAllAttributes:channelName completeBlock:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes) {
        
        if(block != nil){
            RolesInfoModel *rolesInfoModel = [weakself fixRolesInfoModelWithAttributes:attributes];
            block(rolesInfoModel);
            return;
        }
    }];
}

- (void)updateGlobalStateWithValue:(NSString *)value completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock {
    
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.signalManager.messageModel.uid;
    setAttr.value = value;
    
    NSString *channelName = self.signalManager.channelName;
    [self.signalManager updateChannelAttributesWithChannelName:channelName channelAttribute:setAttr completeSuccessBlock:successBlock completeFailBlock:failBlock];
}

- (void)queryOnlineStudentCountWithChannelName:(NSString *)channelName maxCount:(NSInteger)maxCount completeSuccessBlock:(void (^) (NSInteger count))successBlock completeFailBlock:(void (^) (void))failBlock {
    
    [self queryGlobalStateWithChannelName:channelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
        
        if(rolesInfoModel == nil || rolesInfoModel.studentModels == nil) {
            if(failBlock != nil){
                failBlock();
            }
        }
        
        NSInteger studentCount = rolesInfoModel.studentModels.count;
        if(studentCount >= maxCount){
            
            NSMutableArray<NSString *> *uIds = [NSMutableArray array];
            for(RolesStudentInfoModel *model in rolesInfoModel.studentModels){
                [uIds addObject:model.attrKey];
            }
            [self.signalManager queryPeersOnlineStatus:uIds completion:^(NSArray<AgoraRtmPeerOnlineStatus *> *peerOnlineStatus, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
                
                if(errorCode == AgoraRtmQueryPeersOnlineErrorOk) {
                    
                    NSInteger count = 0;
                    for (AgoraRtmPeerOnlineStatus *status in peerOnlineStatus){
                        if(status.isOnline) {
                            count++;
                        }
                    }
                    if(successBlock != nil){
                        successBlock(count);
                    }
                } else {
                    if(failBlock != nil){
                        failBlock();
                    }
                }
            }];
        } else {
            if(successBlock != nil){
                successBlock(studentCount);
            }
        }
    }];
}

- (void)sendMessageWithContent:(NSString *)text userName:(NSString *)name {
    
    NSString *messageBody = [GenerateSignalBody messageWithName:name content:text];
    [self.signalManager sendMessage:messageBody completeSuccessBlock:^{
        
        if([self.signalDelegate respondsToSelector:@selector(signalDidUpdateMessage:)]) {
            SignalRoomModel *messageModel = [[SignalRoomModel alloc] init];
            messageModel.content = text;
            messageModel.account = name;
            messageModel.isSelfSend = YES;
            [self.signalDelegate signalDidUpdateMessage:messageModel];
        }
        
    } completeFailBlock:^{
        
    }];
}

- (void)setSignalWithType:(SignalP2PType)type completeSuccessBlock:(void (^ _Nullable) (void))successBlock {
    
    NSString *msgText = @"";
    switch (type) {
        case SignalP2PTypeCancel:
            msgText = [GenerateSignalBody studentCancelLink];;
            break;
        case SignalP2PTypeApply:
            msgText = [GenerateSignalBody studentApplyLink];
            break;
        default:
            break;
    }
    
    if (msgText.length == 0 || self.currentTeaModel == nil) {
        return;
    }
    NSString *peerId = self.currentTeaModel.uid;
    
    [self.signalManager sendMessage:msgText toPeer:peerId completeSuccessBlock:^{
        if(successBlock != nil) {
            successBlock();
        }
    } completeFailBlock:^{
        
    }];
}

- (void)releaseSignalResources {
    self.currentStuModel = nil;
    self.currentTeaModel = nil;
    [self.signalManager releaseResources];
}

- (RolesInfoModel *)fixRolesInfoModelWithAttributes:(NSArray<AgoraRtmChannelAttribute *> * _Nullable) attributes {
    
    if(attributes == nil){
        RolesInfoModel *rolesInfoModel = [RolesInfoModel new];
        return rolesInfoModel;
    }
    
    TeacherModel *teaModel;
    NSMutableArray<RolesStudentInfoModel*> *stuArray = [NSMutableArray array];

    for (AgoraRtmChannelAttribute *channelAttr in attributes) {
        
        NSDictionary *valueDict = [JsonParseUtil dictionaryWithJsonString:channelAttr.value];
        
        if ([channelAttr.key isEqualToString:RoleTypeTeacther]) {
            
            if(teaModel == nil){
                teaModel = [TeacherModel new];
            }
            [teaModel modelWithDict:valueDict];
        
        } else {
            StudentModel *model = [StudentModel yy_modelWithDictionary:valueDict];
            
            RolesStudentInfoModel *infoModel = [RolesStudentInfoModel new];
            infoModel.studentModel = model;
            infoModel.attrKey = channelAttr.key;
            
            [stuArray addObject:infoModel];
            
            if([model.uid isEqualToString: self.signalManager.messageModel.uid]) {
                self.currentStuModel = model;
            }
        }
    }
    
    self.currentTeaModel = teaModel;
    
    RolesInfoModel *rolesInfoModel = [RolesInfoModel new];
    rolesInfoModel.teacherModel = teaModel;
    rolesInfoModel.studentModels = stuArray;
    
    return rolesInfoModel;
}

#pragma mark SignalManagerDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    // 状态丢失
    if(state == AgoraRtmConnectionStateDisconnected) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_ON_MESSAGE_DISCONNECT object:nil];
    }
}
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    
    if (self.currentTeaModel && [peerId isEqualToString:self.currentTeaModel.uid]) {
        NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
        SignalP2PModel *model = [SignalP2PModel yy_modelWithDictionary:dict];

        if([self.signalDelegate respondsToSelector:@selector(signalDidReceived:)]) {
            [self.signalDelegate signalDidReceived:model];
        }
    }
}
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {

    if([self.signalDelegate respondsToSelector:@selector(signalDidUpdateMessage:)]) {
        NSDictionary *dict = [JsonParseUtil dictionaryWithJsonString:message.text];
        SignalRoomModel *messageModel = [SignalRoomModel yy_modelWithDictionary:dict];
        messageModel.isSelfSend = NO;
        [self.signalDelegate signalDidUpdateMessage:messageModel];
    }
}
- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    
    if([self.signalDelegate respondsToSelector:@selector(signalDidUpdateGlobalState:)]) {
        RolesInfoModel *rolesInfoModel = [self fixRolesInfoModelWithAttributes:attributes];
        [self.signalDelegate signalDidUpdateGlobalState:rolesInfoModel];
    }
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

- (void)clearLocalVideoCanvas {
    [self.rtcManager setupLocalVideo: nil];
}

- (void)removeRTCVideoCanvas:(NSUInteger) uid {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", uid];
    NSArray<RTCVideoSessionModel *> *filteredArray = [self.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
    if(filteredArray > 0) {
        RTCVideoSessionModel *model = filteredArray.firstObject;
        model.videoCanvas.view = nil;
        [self.rtcVideoSessionModels removeObject:model];
    }
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
    return [self.rtcManager muteLocalVideoStream:!enabled];
}
- (int)enableRTCLocalAudio:(BOOL) enabled {
    return [self.rtcManager muteLocalAudioStream:!enabled];
}

- (void)releaseRTCResources {
    for (RTCVideoSessionModel *model in self.rtcVideoSessionModels){
        model.videoCanvas.view = nil;
    }
    [self.rtcVideoSessionModels removeAllObjects];
    [self.rtcManager releaseResources];
}

#pragma mark RTCManagerDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    if([self.rtcDelegate respondsToSelector:@selector(rtcDidJoinedOfUid:)]) {
        [self.rtcDelegate rtcDidJoinedOfUid:uid];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nullable)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    
    [self removeRTCVideoCanvas:uid];
    
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
    
    WEAK(self);
    [HttpManager POSTWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {

        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        roomConfig.userPayload =@{@"identity": @"guest", @"userId": @"dsajdisajxaioskoixsasa"};
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
    
    WEAK(self);
    [HttpManager POSTWhiteBoardRoomWithUuid:model.uuid token:^(NSString * _Nonnull token) {

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
- (void)seekWhiteToTime:(CMTime)time completionHandler:(void (^ _Nonnull)(BOOL finished))completionHandler {
    
    if(self.whiteManager.combinePlayer != nil) {
        [self.whiteManager seekToCombineTime:time completionHandler:completionHandler];
    } else {
        NSTimeInterval seekTime = CMTimeGetSeconds(time);
        [self.whiteManager.player seekToScheduleTime:seekTime];
        completionHandler(YES);
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

- (void)releaseWhiteResources {
    [self.whiteManager releaseResources];
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
    
    // release rtc
    [self releaseRTCResources];
    
    // release white
    [self releaseWhiteResources];
    
    // release signal
    [self releaseSignalResources];
}

@end
