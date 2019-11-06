//
//  EEBCStudentAttr.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEBCStudentAttrs.h"

@implementation EEBCStudentAttrs
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
    @"video":@"attrs.video",
    @"audio":@"attrs.audio",
    @"whiteboard":@"attrs.whiteboard",
    @"chatroom":@"attrs.chatroom",
    @"connect_state":@"attrs.connect_state",
    @"link_state":@"attrs.link_state",
    };
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.video = NO;
        self.auudio = NO;
        self.whiteboard = NO;
        self.link_state = @"none";
    }
    return self;
}
@end



