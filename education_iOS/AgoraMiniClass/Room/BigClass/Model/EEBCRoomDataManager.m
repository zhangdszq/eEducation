//
//  EEBCRoomDataManager.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEBCRoomDataManager.h"


@interface EEBCRoomDataManager ()
@property (nonatomic, strong) NSMutableArray<EEBCStudentAttr *> *studentArray;
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
@end
