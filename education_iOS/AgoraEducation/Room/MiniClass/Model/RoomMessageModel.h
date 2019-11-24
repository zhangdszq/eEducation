//
//  RoomMessageModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/6/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomMessageModel : NSObject
@property (nonatomic, assign) BOOL isSelfSend;
@property (nonatomic, copy)   NSString *account;
@property (nonatomic, copy)   NSString *content;
@end

NS_ASSUME_NONNULL_END
