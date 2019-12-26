//
//  WhiteManagerDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Whiteboard/Whiteboard.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhiteManagerDelegate <NSObject>

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

/**
 房间中RoomState属性，发生变化时，会触发该回调。
 @param modifyState 发生变化的 RoomState 内容
 */
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState;
@end

NS_ASSUME_NONNULL_END
