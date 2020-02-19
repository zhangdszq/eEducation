//
//  OneToOneEducationManager.h
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

@interface OneToOneEducationManager : NSObject

/* ==================================>Session Model<================================ */
@property (nonatomic, strong) TeacherModel * _Nullable teacherModel;
@property (nonatomic, strong) StudentModel * _Nullable studentModel;
@property (nonatomic, strong) NSMutableSet<NSString*> *rtcUids;
@property (nonatomic, strong) NSMutableArray<RTCVideoSessionModel*> *rtcVideoSessionModels;
- (void)initSessionModel;

/* ==================================>SignalManager<================================ */
- (void)initSignalWithModel:(SignalModel*)model dataSourceDelegate:(id<SignalDelegate> _Nullable)signalDelegate completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)setSignalDelegate:(id<SignalDelegate>)delegate;
- (void)joinSignalWithChannelName:(NSString *)channelName completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)updateGlobalStateWithValue:(NSString *)value completeSuccessBlock:(void (^ _Nullable) (void))successBlock completeFailBlock:(void (^ _Nullable) (void))failBlock;
- (void)queryOnlineStudentCountWithChannelName:(NSString *)channelName maxCount:(NSInteger)maxCount completeSuccessBlock:(void (^) (NSInteger count))successBlock completeFailBlock:(void (^) (void))failBlock;
- (void)sendMessageWithContent:(NSString *)text userName:(NSString *)name;
 
/* ==================================>RTCManager<================================ */
- (void)initRTCEngineKitWithAppid:(NSString *)appid clientRole:(RTCClientRole)role dataSourceDelegate:(id<RTCDelegate> _Nullable)rtcDelegate;
- (int)joinRTCChannelByToken:(NSString * _Nullable)token channelId:(NSString * _Nonnull)channelId info:(NSString * _Nullable)info uid:(NSUInteger)uid joinSuccess:(void(^ _Nullable)(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;
- (void)setupRTCVideoCanvas:(RTCVideoCanvasModel *) model;
- (int)enableRTCLocalVideo:(BOOL) enabled;
- (int)enableRTCLocalAudio:(BOOL) enabled;

/* ==================================>WhiteManager<================================ */
- (void)initWhiteSDK:(WhiteBoardView *)boardView dataSourceDelegate:(id<WhitePlayDelegate> _Nullable)whitePlayerDelegate;
- (void)joinWhiteRoomWithUuid:(NSString*)uuid completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
- (void)createWhiteReplayerWithModel:(ReplayerModel *)model completeSuccessBlock:(void (^) (WhitePlayer * _Nullable whitePlayer, AVPlayer * _Nullable avPlayer))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
- (void)disableWhiteDeviceInputs:(BOOL)disable;
- (void)setWhiteStrokeColor:(NSArray<NSNumber *>*)strokeColor;
- (void)setWhiteApplianceName:(NSString *)applianceName;
- (void)refreshWhiteViewSize;
- (void)moveWhiteToContainer:(NSInteger)sceneIndex;
- (void)setWhiteSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
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
