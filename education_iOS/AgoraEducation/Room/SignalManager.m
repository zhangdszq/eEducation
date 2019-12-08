//
//  SignalManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "SignalManager.h"

@interface SignalManager()

@end

static SignalManager *manager = nil;

@implementation SignalManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

@end
