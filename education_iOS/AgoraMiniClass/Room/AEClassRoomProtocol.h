//
//  AEClassRoomProtocol.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/21.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AEClassRoomProtocol <NSObject>
- (void)muteVideoStream:(BOOL)stream;
- (void)muteAudioStream:(BOOL)stream;

@end

NS_ASSUME_NONNULL_END
