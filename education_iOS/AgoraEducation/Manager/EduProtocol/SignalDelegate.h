//
//  SignalDelegate.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RolesInfoModel.h"
#import "SignalRoomModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SignalDelegate <NSObject>

@optional

- (void)signalDidUpdateMessage:(SignalRoomModel * _Nonnull)messageModel;

- (void)signalDidUpdateGlobalStateWithSourceModel:(RolesInfoModel * _Nullable)sourceInfoModel currentModel:(RolesInfoModel * _Nullable)currentInfoModel;

- (void)signalDidReceived:(SignalP2PModel * _Nonnull)signalModel;

@end

NS_ASSUME_NONNULL_END
