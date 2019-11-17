//
//  EEBCRoomDataManager.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEPublicMethodsManager : NSObject
+ (NSString *)studentApplyLink;
+ (NSString *)setAndUpdateStudentChannelAttrsWithName:(NSString *)name video:(BOOL)video audio:(BOOL)audio;
+ (void)parseWhiteBoardRoomWithUuid:(NSString *)uuid token:(void (^)(NSString *token))token failure:(void (^)(NSString *msg))failure;
+ (NSString *)MD5WithString:(NSString *)str;
+ (BOOL)judgeClassRoomText:(NSString *)text;
+ (void)addShadowWithView:(UIView *)view alpha:(CGFloat)alpha;
+ (NSString *)muteVideoStream:(BOOL)stream;
+ (NSString *)muteAudioStream:(BOOL)stream;
+ (NSString *)muteChatContent:(BOOL)isMute;
@end

NS_ASSUME_NONNULL_END
