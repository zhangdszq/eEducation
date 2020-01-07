//
//  KeyCenter.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyCenter : NSObject

+ (NSString *)agoraAppid;

/* assign Token to nil if you have not enabled app certificate
 * before you deploy your own token server, you can easily generate a temp token for dev use
 * at https://dashboard.agora.io note the token generated are allowed to join corresponding room ONLY.
 */
+ (NSString *)agoraRTCToken;


/* you can get Agora RTMToken refer to https://docs.agora.io/cn/Real-time-Messaging/rtm_token
 */
+ (NSString *)agoraRTMToken;


/* you can get white Token refer to https://console.herewhite.com/
 */
+ (NSString *)whiteBoardToken;

@end

NS_ASSUME_NONNULL_END
