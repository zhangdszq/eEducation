//
//  EducationManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhiteManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface EducationManager : NSObject

- (void)sendMessageWithValue:(NSString *)value;


//- (void)initWhiteSDKWithBoardView:(WhiteBoardView *)boardView;
//- (void)joinWhiteRoomWithWhiteRoomConfig:(WhiteRoomConfig*)roomConfig completeSuccessBlock:(void (^) (WhiteRoom * _Nullable room))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
//
//- (void)createReplayerWithConfig:(WhitePlayerConfig *)playerConfig completeSuccessBlock:(void (^) (WhitePlayer * _Nullable player))successBlock completeFailBlock:(void (^) (NSError * _Nullable error))failBlock;
//
//
//- (void)disableDeviceInputs:(BOOL)disable;
//- (void)setMemberState:(nonnull WhiteMemberState *)memberState;
//- (void)refreshViewSize;
//- (void)moveCameraToContainer:(CGSize)size;
//- (void)setSceneIndex:(NSUInteger)index completionHandler:(void (^ _Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
//
//- (void)releaseResources;

@end

NS_ASSUME_NONNULL_END
