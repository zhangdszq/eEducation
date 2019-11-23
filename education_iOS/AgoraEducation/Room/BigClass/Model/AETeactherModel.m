//
//  EEBCTeactherAttr.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "AETeactherModel.h"

@implementation AETeactherModel
- (void)modelWithDict:(NSDictionary *)dict {
   NSMutableArray * keys = [NSMutableArray array];
   NSMutableArray * attributes = [NSMutableArray array];
   unsigned int outCount;
   objc_property_t * properties = class_copyPropertyList([self class], &outCount);
   for (int i = 0; i < outCount; i ++) {
       objc_property_t property = properties[i];
       NSString * propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
       [keys addObject:propertyName];
       NSString * propertyAttribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
       [attributes addObject:propertyAttribute];
   }
   free(properties);
   for (NSString * key in keys) {
       if ([dict valueForKey:key] == nil) continue;
       [self setValue:[dict valueForKey:key] forKey:key];
   }
}
@end
