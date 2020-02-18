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
        self.grant_board = NO;
    }
    return self;
}

- (BOOL)isEqual:(id)otherObject {
    if ([otherObject isKindOfClass:[self class]]) {
        BOOL equal = [((StudentModel*)otherObject).account isEqualToString:self.account]
                    & [((StudentModel*)otherObject).uid isEqualToString:self.uid]
                    & ((StudentModel*)otherObject).video == self.video
                    & ((StudentModel*)otherObject).audio == self.audio
                    & ((StudentModel*)otherObject).chat == self.chat
                    & ((StudentModel*)otherObject).grant_board == self.grant_board;
        return equal;
    }

    return NO;
}
@end



