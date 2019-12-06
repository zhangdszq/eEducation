//
//  DataTypeManager.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/12/6.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataTypeManager : NSObject
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSString *)MD5WithString:(NSString *)str;

+ (BOOL)judgeClassRoomText:(NSString *)text;

+ (void)addShadowWithView:(UIView *)view alpha:(CGFloat)alpha;

+ (NSString *)getUserID;
@end

NS_ASSUME_NONNULL_END
