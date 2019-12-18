//
//  EEBCStudentAttr.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AEStudentModel : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) NSInteger video;
@property (nonatomic, assign) NSInteger audio;
@property (nonatomic, assign) NSInteger chat;

@end

NS_ASSUME_NONNULL_END
