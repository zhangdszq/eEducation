//
//  WhitePlayDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhitePlayDelegate <NSObject>

@optional

/** 进度时间变化 */
- (void)whitePlayerTimeChanged:(NSTimeInterval)time;

/**
 进入缓冲状态，WhitePlayer，NativePlayer 任一进入缓冲，都会回调。
 */
- (void)whitePlayerStartBuffering;

/**
 结束缓冲状态，WhitePlayer，NativePlayer 全部完成缓冲，才会回调。
 */
- (void)whitePlayerEndBuffering;

/**
 播放结束
 */
- (void)whitePlayerDidFinish;

/**
 播放失败

 @param error 错误原因
 */
- (void)whitePlayerError:(NSError * _Nullable)error;

/**
 房间中RoomState属性，发生变化时，会触发该回调。
 @param modifyState 发生变化的 RoomState 内容
 */
- (void)whiteRoomStateChanged;

@end

NS_ASSUME_NONNULL_END
