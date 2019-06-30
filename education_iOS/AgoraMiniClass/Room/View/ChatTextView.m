//
//  ChatTextView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "ChatTextView.h"

@interface ChatTextView ()<UITextViewDelegate>
@end

@implementation ChatTextView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
    }
    return self;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (self.chatMessage) {
            self.chatMessage(self.text);
        }
        self.text = nil;
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}


@end
