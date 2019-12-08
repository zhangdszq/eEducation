//
//  SignalManager.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageManager.h"

typedef void(^SignalManagerBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface SignalManager : NSObject

//- (void)sendSignalWithText:(NSString *)messageText  completeSuccessBlock:(SignalManagerBlock _Nullable)successBlock completeFailBlock:(SignalManagerBlock _Nullable)failBlock;
//
//- (void)queryRolesInfoWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block;


@end

NS_ASSUME_NONNULL_END
