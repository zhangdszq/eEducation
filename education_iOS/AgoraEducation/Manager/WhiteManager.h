//
//  WhiteManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/18.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>

@protocol WhiteManagerProtocol <NSObject>

@optional
/** 播放状态切换回调 */
- (void)phaseChanged:(WhitePlayerPhase)phase;

/** 出错暂停 */
- (void)stoppedWithError:(NSError * _Nullable)error;

/** 进度时间变化 */
- (void)scheduleTimeChanged:(NSTimeInterval)time;

/**
 进入缓冲状态，WhitePlayer，NativePlayer 任一进入缓冲，都会回调。
 */
- (void)combinePlayerStartBuffering;

/**
 结束缓冲状态，WhitePlayer，NativePlayer 全部完成缓冲，才会回调。
 */
- (void)combinePlayerEndBuffering;

/**
 NativePlayer 播放结束
 */
- (void)nativePlayerDidFinish;

/**
 videoPlayer 无法进行播放，需要重新创建 CombinePlayer 进行播放

 @param error 错误原因
 */
- (void)combineVideoPlayerError:(NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_BEGIN

@interface WhiteManager : NSObject

@property (nonatomic, strong) WhiteSDK * _Nullable whiteSDK;
@property (nonatomic, strong) WhiteRoom * _Nullable room;
@property (nonatomic, strong) WhitePlayer * _Nullable player;
@property (nonatomic, strong) WhiteCombinePlayer * _Nullable combinePlayer;

@property (nonatomic, weak) id<WhiteManagerProtocol> whiteManagerDelegate;

- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView;
- (void)joinWhiteRoomWithWhiteRoomConfig:(WhiteRoomConfig*)roomConfig completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;

- (void)createReplayerWithConfig:(WhitePlayerConfig *)playerConfig completeSuccessBlock:(void (^) (WhitePlayer * _Nullable player))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;


- (void)disableDeviceInputs:(BOOL)disable;
- (void)setMemberState:(nonnull WhiteMemberState *)memberState;
- (void)refreshViewSize;
- (void)moveCameraToContainer:(CGSize)size;
- (void)setSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;

- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
