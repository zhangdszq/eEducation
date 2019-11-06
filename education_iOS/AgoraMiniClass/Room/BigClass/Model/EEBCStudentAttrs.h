//
//  EEBCStudentAttr.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEBCStudentAttrs : NSObject
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL video;
@property (nonatomic, assign) BOOL auudio;
@property (nonatomic, assign) BOOL screen;
@property (nonatomic, assign) BOOL whiteboard;
@property (nonatomic, assign) BOOL chatroom;
@property (nonatomic, copy)   NSString * _Nullable connect_state;
@property (nonatomic, copy)   NSString * _Nullable link_state;
@end

NS_ASSUME_NONNULL_END
