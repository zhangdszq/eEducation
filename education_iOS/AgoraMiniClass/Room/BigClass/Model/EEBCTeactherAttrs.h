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
@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *whiteboard_uid;
@property (nonatomic, copy) NSString *room;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, assign) BOOL video;
@property (nonatomic, assign) BOOL audio;
@end

NS_ASSUME_NONNULL_END
