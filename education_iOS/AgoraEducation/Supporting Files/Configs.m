//
//  Configs.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>




#define kAgoraAppid  @"aab8b8f5a8cd4469a63042fcfafe7063"
#define kWhiteBoardToken @"WHITEcGFydG5lcl9pZD0xTnd5aDBsMW9ZazhaRWNuZG1kaWgwcmJjVWVsQnE1UkpPMVMmc2lnPWI5ZGRmNTU1YTgwM2Q0NjFjMDY5YTQ3NDA2ZDMxN2Q5NTVmYTJjYjY6YWRtaW5JZD01MjEmcm9sZT1taW5pJmV4cGlyZV90aW1lPTE2MDM3OTIwOTMmYWs9MU53eWgwbDFvWWs4WkVjbmRtZGloMHJiY1VlbEJxNVJKTzFTJmNyZWF0ZV90aW1lPTE1NzIyMzUxNDEmbm9uY2U9MTU3MjIzNTE0MDY3MTAw"

#define RCColorWithValue(v,a)         [UIColor colorWithRed:(((v) >> 16) & 0xff)/255.0f green:(((v) >> 8) & 0xff)/255.0f blue:((v) & 0xff)/255.0f alpha:a]

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define WEAK(object) __weak typeof(object) weak##object = object;


#define kWhiteBoardUrl  @"https://cloudcapiv4.herewhite.com"
#define kPOSTCreateWhiteBoardUrl [kWhiteBoardUrl stringByAppendingString:@"/room"]
#define kPOSTJoinWhiteBoardUrl [kWhiteBoardUrl stringByAppendingString:@"/room/join"]


#define kRLViewWidth 222
#define kWhiteBoardUid 7
