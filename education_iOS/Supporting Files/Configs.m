//
//  Configs.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>




#define kAgoraAppid  <#@"请获取正确的appid后测试"#>

#define RCColorWithValue(v,a)         [UIColor colorWithRed:(((v) >> 16) & 0xff)/255.0f green:(((v) >> 8) & 0xff)/255.0f blue:((v) & 0xff)/255.0f alpha:a]

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define WEAK(object) __weak typeof(object) weak##object = object;

#define kBaseUrl           <#@"请部署服务端系统，写入正确的baseUrl"#>
#define kGetServerRtmIdUrl  [kBaseUrl stringByAppendingString:@"/edu_control/sentry"]
#define kGetWhiteBoardUuid [kBaseUrl stringByAppendingString:@"/edu_whiteboard/v1/room"]
#define kGetWhiteBoardRoomToken  [kBaseUrl stringByAppendingString:@"/edu_whiteboard/v1/room/join"]
