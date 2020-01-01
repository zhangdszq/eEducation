//
//  EEBCStudentAttr.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "StudentModel.h"

@implementation StudentModel
- (instancetype)init {
    if(self = [super init]) {
        
        self.account = @"";
        self.uid = @"";

        self.video = NO;
        self.audio = NO;
        self.chat = NO;
    }
    return self;
}
@end



