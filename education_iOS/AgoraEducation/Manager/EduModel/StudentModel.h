//
//  EEBCStudentAttr.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StudentModel : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) NSInteger video;
@property (nonatomic, assign) NSInteger audio;
@property (nonatomic, assign) NSInteger chat;
@property (nonatomic, assign) NSInteger grant_board;

- (BOOL)isEqual:(id)otherObject;

@end

NS_ASSUME_NONNULL_END
