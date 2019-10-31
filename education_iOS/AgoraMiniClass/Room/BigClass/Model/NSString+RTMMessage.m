//
//  NSString+RTMMessage.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "NSString+RTMMessage.h"



@implementation NSString (RTMMessage)
+ (NSString *)setRTMUser {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970])];
    NSString *uid =  [NSString stringWithFormat:@"2%@",[timeSp substringFromIndex:3]];
    return uid;
}

@end
