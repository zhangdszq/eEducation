//
//  EEBCTeactherAttr.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "TeacherModel.h"

@implementation TeacherModel

- (instancetype)init {
    if(self = [super init]) {
        
        self.account = @"";
        self.uid = @"";
        self.whiteboard_uid = @"";
        self.link_uid = @"";
        self.shared_uid = @"";
        
        self.mute_chat = YES;
        self.video = NO;
        self.audio = NO;
        self.class_state = NO;
    }
    return self;
}

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

- (void)modelWithteacherModel:(TeacherModel *)model {
    
    if(model.account){
        self.account = model.account;
    }
    if(model.uid){
        self.uid = model.uid;
    }
    if(model.whiteboard_uid){
        self.whiteboard_uid = model.whiteboard_uid;
    }
    if(model.link_uid){
        self.link_uid = model.link_uid;
    }
    if(model.shared_uid){
        self.shared_uid = model.shared_uid;
    }
    
    self.mute_chat = model.mute_chat;
    self.class_state = model.class_state;
    self.video = model.video;
    self.audio = model.audio;
}
@end
