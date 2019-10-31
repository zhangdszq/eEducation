//
//  EEBCRoomDataManager.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEBCStudentAttr.h"
#import "EEBCTeactherAttr.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEBCRoomDataManager : NSObject
+ (instancetype)shareManager;
@property (nonatomic, readonly) NSMutableArray<EEBCStudentAttr *> *studentArray;
@property (nonatomic, readonly) EEBCTeactherAttr *teactherAttr;

@end

NS_ASSUME_NONNULL_END
