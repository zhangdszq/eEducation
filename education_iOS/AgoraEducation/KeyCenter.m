//
//  KeyCenter.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "KeyCenter.h"

@implementation KeyCenter

+ (NSString *)agoraAppid {
    return <#Your Agora App Id#>;
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)agoraRTCToken {
    return <#Your Agora RTC Token#>;
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)agoraRTMToken {
    return <#Your Agora RTM Token#>;
}

+ (NSString *)whiteBoardToken {
    return <#Your White Token#>;
}

@end
