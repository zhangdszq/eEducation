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
        
        self.mute_chat = NO;
        self.video = NO;
        self.audio = NO;
        self.class_state = NO;
        self.lock_board = NO;
    }
    return self;
}
@end
