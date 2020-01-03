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
/**
 Playback status switching callback
 播放状态切换回调
 */
- (void)phaseChanged:(WhitePlayerPhase)phase;

/**
 Pause on error
 出错暂停
 */
- (void)stoppedWithError:(NSError * _Nullable)error;

/**
 Progress time change
 进度时间变化
 */
- (void)scheduleTimeChanged:(NSTimeInterval)time;

/**
 Entering the buffer state, any time WhitePlayer or NativePlayer enters the buffer, it will callback.
 进入缓冲状态，WhitePlayer，NativePlayer 任一进入缓冲，都会回调。
 */
- (void)combinePlayerStartBuffering;

/**
 When the buffer state is finished, the WhitePlayer and NativePlayer have completed buffering, and then they will call back.
 结束缓冲状态，WhitePlayer，NativePlayer 全部完成缓冲，才会回调。
 */
- (void)combinePlayerEndBuffering;

/**
 NativePlayer end of play
 NativePlayer 播放结束
 */
- (void)nativePlayerDidFinish;

/**
 VideoPlayer unable to play, need to re-create CombinePlayer for playback
 VideoPlayer 无法进行播放，需要重新创建 CombinePlayer 进行播放

 @param error 错误原因
 */
- (void)combineVideoPlayerError:(NSError * _Nullable)error;

/**
 The RoomState property in the room will trigger this callback when it changes.
 房间中RoomState属性，发生变化时，会触发该回调。
 @param modifyState 发生变化的 RoomState 内容
 */
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState;
@end

NS_ASSUME_NONNULL_END
