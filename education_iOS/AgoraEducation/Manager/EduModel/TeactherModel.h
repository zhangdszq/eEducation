//
//  EEBCTeactherAttr.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TeactherModel : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *whiteboard_uid;
@property (nonatomic, copy) NSString *link_uid;
@property (nonatomic, copy) NSString *shared_uid;

@property (nonatomic, assign) BOOL mute_chat;
@property (nonatomic, assign) BOOL video;
@property (nonatomic, assign) BOOL audio;

@property (nonatomic, assign) BOOL class_state;

- (void)modelWithDict:(NSDictionary *)dict;
- (void)modelWithTeactherModel:(TeactherModel *)model;
@end

NS_ASSUME_NONNULL_END
