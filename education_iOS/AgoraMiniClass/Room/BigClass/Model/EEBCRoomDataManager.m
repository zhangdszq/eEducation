//
//  EEBCRoomDataManager.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEBCRoomDataManager.h"


@interface EEBCRoomDataManager ()
@property (nonatomic, strong) NSMutableArray<EEBCStudentAttrs *> *studentArray;
@property (nonatomic, copy) EEBCTeactherAttr *teactherAttr;
@end

static EEBCRoomDataManager *manager = nil;
@implementation EEBCRoomDataManager
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return manager;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return manager;
}

- (NSString *)studentAttrUserName:(NSString *)userName {
    NSDictionary *dict = @{
        @"video":@(false),
        @"audio":@(false),
        @"whiteboard":@(false),
        @"chatroom":@(true),
        @"connect_state": @"connecting",
        @"link_state": @"none",
    };
    NSDictionary *account = @{
        @"account": userName,
        @"attrs": dict,
    };
    NSString *requestStr =  [JsonAndStringConversions dictionaryToJson:account];
    return requestStr;
}

- (void)parseChannelAttrMessage:(NSString *)message {
    
}
- (NSString *)sendHandUpMessage {
    NSDictionary *argsVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"handUp",@"type", @(YES),@"target",nil];
    NSDictionary  *muteVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:argsVideoInfo,@"args", nil];
    NSString *muteVideoStr =  [JsonAndStringConversions dictionaryToJson:muteVideoInfo];
    return muteVideoStr;
}

- (NSString *)cancelHandUpMessage {
    NSDictionary *argsVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"handUp",@"type", @(NO),@"target",nil];
    NSDictionary  *muteVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:argsVideoInfo,@"args", nil];
       NSString *muteVideoStr =  [JsonAndStringConversions dictionaryToJson:muteVideoInfo];
       return muteVideoStr;
}



@end
