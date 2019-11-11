//
//  EEBCRoomDataManager.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEPublicMethodsManager : NSObject
+ (NSString *)studentApplyLink;
+ (NSString *)setChannelAttrsWithName:(NSString *)name;

+ (void)parseWhiteBoardRoomWithUuid:(NSString *)uuid token:(void (^)(NSString *token))token failure:(void (^)(NSString *msg))failure;
+ (NSString *)MD5WithString:(NSString *)str;
+ (BOOL)judgeClassRoomText:(NSString *)text;
+ (void)addShadowWithView:(UIView *)view alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
