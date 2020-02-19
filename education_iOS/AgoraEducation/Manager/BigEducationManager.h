//
//  BigEducationManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhiteManager.h"

#import "SignalManager.h"
#import "RTCVideoCanvasModel.h"
#import "ReplayerModel.h"
#import "SignalP2PModel.h"

#import "RTCDelegate.h"
#import "SignalDelegate.h"
#import "WhitePlayDelegate.h"

#import "RTCVideoSessionModel.h"
#import "RTCVideoCanvasModel.h"
#import "RolesInfoModel.h"

typedef void(^QueryRolesInfoBlock)(RolesInfoModel * _Nullable);
#define NOTICE_KEY_ON_MESSAGE_DISCONNECT @"NOTICE_KEY_ON_MESSAGE_DISCONNECT"

NS_ASSUME_NONNULL_BEGIN

@interface BigEducationManager : NSObject

/* ==================================>Session Model<================================ */
@property (nonatomic, strong) TeacherModel * _Nullable teacherModel;
@property (nonatomic, strong) StudentModel * _Nullable studentModel;
@property (nonatomic, strong) StudentModel * _Nullable renderStudentModel;
@property (nonatomic, strong) NSMutableSet<NSString*> *rtcUids;
@property (nonatomic, strong) NSMutableArray<RTCVideoSessionModel*> *rtcVideoSessionModels;
- (void)initSessionModel;

/* ==================================>SignalManager<================================ */
- (void)initSignalWithModel:(SignalModel*)model dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)setSignalDelegate:(id<SignalDelegate>)delegate;
- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;

- (void)queryGlobalStateWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block;
- (void)updateGlobalStateWithValue:(NSString *)value completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;

- (void)sendMessageWithContent:(NSString *)text userName:(NSString *)name;
- (void)setSignalWithType:(SignalP2PType)type completeSuccessBlock:(void (^ _Nullable) (void))successBlock;

- (void)releaseSignalResources;

 
/* ==================================>RTCManager<================================ */
- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate;
- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;
- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *) model;
- (void)removeRTCVideoCanvas:(NSUInteger) uid;
- (void)setRTCClientRole:(RTCClientRole)role;
- (int)setRTCRemoteStreamWithUid:(NSUInteger)uid type:(RTCVideoStreamType)streamType;
- (int)enableRTCLocalVideo:(BOOL) enabled;
- (int)enableRTCLocalAudio:(BOOL) enabled;
- (void)releaseRTCResources;


/* ==================================>WhiteManager<================================ */
- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate;
- (void)joinWhiteRoomWithUuid:(NSString*)uuid completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
- (void)createWhiteReplayerWithModel:(ReplayerModel *)model completeSuccessBlock:(void (^) (WhitePlayer * _Nullable whitePlayer, AVPlayer * _Nullable avPlayer))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
- (void)disableWhiteDeviceInputs:(BOOL)disable;
- (void)refreshWhiteViewSize;
- (void)moveWhiteToContainer:(NSInteger)sceneIndex;
- (void)seekWhiteToTime:(CMTime)time completionHandler:(void (^ _Nonnull)(BOOL finished))completionHandler;
- (void)playWhite;
- (void)pauseWhite;
- (void)stopWhite;
- (void)disableCameraTransform:(BOOL)disableCameraTransform;
- (NSTimeInterval)whiteTotleTimeDuration;
- (void)currentWhiteScene:(void (^)(NSInteger sceneCount, NSInteger sceneIndex))completionBlock;
- (void)releaseWhiteResources;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END

