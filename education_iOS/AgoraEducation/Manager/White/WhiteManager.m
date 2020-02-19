//
//  WhiteManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "WhiteManager.h"

@interface WhiteManager()<WhiteCommonCallbackDelegate, WhiteRoomCallbackDelegate, WhitePlayerEventDelegate, WhiteCombineDelegate>

@end

@implementation WhiteManager

- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView config:(WhiteSdkConfiguration *)config {
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView: boardView config:config commonCallbackDelegate:self];
}

- (void)joinWhiteRoomWithWhiteRoomConfig:(WhiteRoomConfig*)roomConfig completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
    
    WEAK(self);
    [self.whiteSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
        
        if(success) {
            weakself.room = room;
            weakself.whiteMemberState = [WhiteMemberState new];
            [weakself.room setMemberState:weakself.whiteMemberState];
            
            if(successBlock != nil){
                successBlock(room);
            }
        } else {
            if(failBlock != nil){
                failBlock(error);
                NSLog(@"WhiteManager joinWhiteRoom Err:%@", error);
            }
        }
    }];
}

- (void)createReplayerWithConfig:(WhitePlayerConfig *)playerConfig completeSuccessBlock:(void (^) (WhitePlayer * _Nullable player))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock {
        
    WEAK(self);
    [self.whiteSDK createReplayerWithConfig:playerConfig callbacks:self completionHandler:^(BOOL success, WhitePlayer * _Nonnull player, NSError * _Nonnull error) {
        if (success) {
            weakself.player = player;
            if(successBlock != nil){
                successBlock(player);
            }
        } else {
            if(failBlock != nil){
                failBlock(error);
                NSLog(@"WhiteManager createReplayer Err:%@", error);
            }
        }
    }];
}

- (AVPlayer*)createCombinePlayerWithVideoPath:(NSString *)videoPath {
    NSAssert(videoPath && videoPath.length > 0, @"videoPath should be not empty");
    NSAssert(self.player, @"self.player should be not empty");
    self.combinePlayer = [[WhiteCombinePlayer alloc] initWithMediaUrl:[NSURL URLWithString:videoPath] whitePlayer:self.player];
    self.combinePlayer.delegate = self;
    return self.combinePlayer.nativePlayer;
}

- (void)play {
    [self.player play];
}
- (void)combinePlay {
    [self.combinePlayer play];
}

- (void)pause {
    [self.player pause];
}
- (void)combinePause {
    [self.combinePlayer pause];
}

- (void)stop {
    [self.player stop];
}

- (void)disableCameraTransform:(BOOL)disableCameraTransform {
    [self.room disableCameraTransform:disableCameraTransform];
}

- (void)seekToTime:(NSTimeInterval)beginTime {
    [self.player seekToScheduleTime: beginTime];
}

- (void)seekToCombineTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler {
    [self.combinePlayer seekToTime:time completionHandler: completionHandler];
}

- (void)disableDeviceInputs:(BOOL)disable {
    [self.room disableDeviceInputs:disable];
}

- (void)setMemberState:(nonnull WhiteMemberState *)memberState {
    [self.room setMemberState: memberState];
}

- (void)refreshViewSize {
    [self.room refreshViewSize];
}

- (NSTimeInterval)timeDuration {
    return self.player.timeInfo.timeDuration;
}

- (void)moveCameraToContainer:(CGSize)size {
    WhiteRectangleConfig *config = [[WhiteRectangleConfig alloc] initWithInitialPosition:size.width height:size.height];
    [self.room moveCameraToContainer:config];
}

- (void)setSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler {
    [self.room setSceneIndex:index completionHandler:completionHandler];
}

- (void)updateWhitePlayerPhase:(WhitePlayerPhase)phase {
    if(self.combinePlayer != nil) {
        [self.combinePlayer updateWhitePlayerPhase:phase];
    }
}

- (void)releaseResources {
    if(self.player != nil) {
        [self.player stop];
    }
    
    if(self.room != nil) {
        [self.room disconnect:nil];
    }

    self.player = nil;
    self.combinePlayer = nil;
    self.room = nil;
    self.whiteSDK = nil;
}

- (void)dealloc {
    [self releaseResources];
}

#pragma mark WhitePlayerEventDelegate
/**
Playback status switching callback
*/
- (void)phaseChanged:(WhitePlayerPhase)phase {
    [self updateWhitePlayerPhase:phase];
    if([self.whiteManagerDelegate respondsToSelector:@selector(phaseChanged:)]) {
        [self.whiteManagerDelegate phaseChanged: phase];
    }
}

/**
Pause on error
*/
- (void)stoppedWithError:(NSError *)error {
    if([self.whiteManagerDelegate respondsToSelector:@selector(stoppedWithError:)]) {
        [self.whiteManagerDelegate stoppedWithError: error];
    }
}
/**
Progress time change
*/
- (void)scheduleTimeChanged:(NSTimeInterval)time {
    if([self.whiteManagerDelegate respondsToSelector:@selector(scheduleTimeChanged:)]) {
        [self.whiteManagerDelegate scheduleTimeChanged: time];
    }
}

#pragma mark WhiteCombineDelegate
/**
Entering the buffer state, any time WhitePlayer or NativePlayer enters the buffer, it will callback.
*/
- (void)combinePlayerStartBuffering {
    if([self.whiteManagerDelegate respondsToSelector:@selector(combinePlayerStartBuffering)]) {
        [self.whiteManagerDelegate combinePlayerStartBuffering];
    }
}

/**
When the buffer state is finished, the WhitePlayer and NativePlayer have completed buffering, and then they will call back.
*/
- (void)combinePlayerEndBuffering {
    if([self.whiteManagerDelegate respondsToSelector:@selector(combinePlayerEndBuffering)]) {
        [self.whiteManagerDelegate combinePlayerEndBuffering];
    }
}

/**
NativePlayer end of play
*/
- (void)nativePlayerDidFinish {
    if([self.whiteManagerDelegate respondsToSelector:@selector(nativePlayerDidFinish)]) {
        [self.whiteManagerDelegate nativePlayerDidFinish];
    }
}

/**
VideoPlayer unable to play, need to re-create CombinePlayer for playback
*/
- (void)combineVideoPlayerError:(NSError *)error {
    if([self.whiteManagerDelegate respondsToSelector:@selector(combineVideoPlayerError:)]) {
        [self.whiteManagerDelegate combineVideoPlayerError: error];
    }
}

#pragma mark WhiteRoomCallbackDelegate
/**
The RoomState property in the room will trigger this callback when it changes.
*/
- (void)fireRoomStateChanged:(WhiteRoomState *)modifyState {
    if([self.whiteManagerDelegate respondsToSelector:@selector(fireRoomStateChanged:)]) {
        [self.whiteManagerDelegate fireRoomStateChanged: modifyState];
    }
}

@end
