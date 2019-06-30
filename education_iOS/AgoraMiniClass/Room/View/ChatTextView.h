//
//  ChatTextView.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChatMessageBlock)(NSString * _Nullable messageString);

NS_ASSUME_NONNULL_BEGIN

@interface ChatTextView : UITextView
@property (nonatomic, copy) ChatMessageBlock chatMessage;
@end

NS_ASSUME_NONNULL_END
