//
//  Configs.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>




#define kAgoraAppid  <#@"Agora AppID"#>
#define kWhiteBoardToken <#@"netless Token"#>


#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define WEAK(object) __weak typeof(object) weak##object = object;


#define kWhiteBoardUrl  @"https://cloudcapiv4.herewhite.com"
#define kPOSTCreateWhiteBoardUrl [kWhiteBoardUrl stringByAppendingString:@"/room"]
#define kPOSTJoinWhiteBoardUrl [kWhiteBoardUrl stringByAppendingString:@"/room/join"]


#define kRLViewWidth 222
#define kWhiteBoardUid 7
