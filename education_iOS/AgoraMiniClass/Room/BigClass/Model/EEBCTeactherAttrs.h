//
//  EEBCTeactherAttr.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEBCTeactherAttrs : NSObject
@property (nonatomic, copy)   NSString *account;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy)   NSString *whiteboard_uuid;
@property (nonatomic, copy)   NSString *link_uid;
@property (nonatomic, copy)   NSString *shared_uid;
@property (nonatomic, copy) NSString *mute_chat;
@end

NS_ASSUME_NONNULL_END
