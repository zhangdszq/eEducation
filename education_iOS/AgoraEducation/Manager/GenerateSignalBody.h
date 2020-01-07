//
//  GenerateSignalBodyr.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StudentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GenerateSignalBody : NSObject

+ (NSString *)studentApplyLink;
+ (NSString *)studentCancelLink;
+ (NSString *)muteVideoStream:(BOOL)stream;
+ (NSString *)muteAudioStream:(BOOL)stream;
+ (NSString *)muteChatContent:(BOOL)isMute;

+ (NSString *)messageWithName:(NSString *)name content:(NSString *)content;

+ (NSString *)channelAttrsWithValue:(StudentModel *)model;

@end

NS_ASSUME_NONNULL_END
