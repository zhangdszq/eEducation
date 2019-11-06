//
//  EEBCRoomDataManager.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EEBCStudentAttrs.h"
#import "EEBCTeactherAttr.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEBCRoomDataManager : NSObject
+ (instancetype)shareManager;
@property (nonatomic, readonly) NSMutableArray<EEBCStudentAttrs *> *studentArray;
@property (nonatomic, readonly) EEBCTeactherAttr *teactherAttr;
- (NSString *)sendHandUpMessage;
@end

NS_ASSUME_NONNULL_END
