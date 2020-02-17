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
    return @"aab8b8f5a8cd4469a63042fcfafe7063";
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)agoraRTCToken {
    return @"";
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)agoraRTMToken {
    return @"";
}

+ (NSString *)whiteBoardToken {
    return @"WHITEcGFydG5lcl9pZD0xTnd5aDBsMW9ZazhaRWNuZG1kaWgwcmJjVWVsQnE1UkpPMVMmc2lnPWI5ZGRmNTU1YTgwM2Q0NjFjMDY5YTQ3NDA2ZDMxN2Q5NTVmYTJjYjY6YWRtaW5JZD01MjEmcm9sZT1taW5pJmV4cGlyZV90aW1lPTE2MDM3OTIwOTMmYWs9MU53eWgwbDFvWWs4WkVjbmRtZGloMHJiY1VlbEJxNVJKTzFTJmNyZWF0ZV90aW1lPTE1NzIyMzUxNDEmbm9uY2U9MTU3MjIzNTE0MDY3MTAw";
}

@end
