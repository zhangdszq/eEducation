//
//  Configs.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>




#define kAgoraAppid getAppid www.agora.io

#define RCColorWithValue(v,a)         [UIColor colorWithRed:(((v) >> 16) & 0xff)/255.0f green:(((v) >> 8) & 0xff)/255.0f blue:((v) & 0xff)/255.0f alpha:a]

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define WEAK(object) __weak typeof(object) weak##object = object;

#define kGetServerRtmIdUrl @"https://webdemo.agora.io/edu_control/sentry"
#define kGetWhiteBoardUuid @"https://webdemo.agora.io/edu_whiteboard/v1/room"
#define kGetWhiteBoardRoomToken @"https://webdemo.agora.io/edu_whiteboard/v1/room/join"
