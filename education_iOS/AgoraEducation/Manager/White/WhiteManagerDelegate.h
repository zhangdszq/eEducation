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
 */
- (void)phaseChanged:(WhitePlayerPhase)phase;

/**
 Pause on error
 */
- (void)stoppedWithError:(NSError * _Nullable)error;

/**
 Progress time change
 */
- (void)scheduleTimeChanged:(NSTimeInterval)time;

/**
 Entering the buffer state, any time WhitePlayer or NativePlayer enters the buffer, it will callback.
 */
- (void)combinePlayerStartBuffering;

/**
 When the buffer state is finished, the WhitePlayer and NativePlayer have completed buffering, and then they will call back.
 */
- (void)combinePlayerEndBuffering;

/**
 NativePlayer end of play
 */
- (void)nativePlayerDidFinish;

/**
 VideoPlayer unable to play, need to re-create CombinePlayer for playback
 */
- (void)combineVideoPlayerError:(NSError * _Nullable)error;

/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *_Nullable)modifyState;
@end

NS_ASSUME_NONNULL_END
