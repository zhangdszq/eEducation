//
//  EEBCRoomDataManager.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEPublicMethodsManager.h"
#import "AgoraHttpRequest.h"
#import <CommonCrypto/CommonCrypto.h>

@interface EEPublicMethodsManager ()

@end


@implementation EEPublicMethodsManager
+ (NSString *)studentApplyLink {
    NSDictionary *dict = @{
        @"type":@"apply",
        @"resource":@"co-video",
    };
    NSString *applyString = [JsonAndStringConversions dictionaryToJson:dict];
    return applyString;
}

+ (NSString *)setChannelAttrsWithName:(NSString *)name {
    NSDictionary *dict = @{
           @"account":name,
       };
    NSString *nameString = [JsonAndStringConversions dictionaryToJson:dict];
    return nameString;
}

+ (void)parseWhiteBoardRoomWithUuid:(NSString *)uuid token:(void (^)(NSString *token))token failure:(void (^)(NSString *msg))failure;{
         AgoraHttpRequest *request = [[AgoraHttpRequest alloc] init];
         NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"uuid", nil];
         [request post:kGetWhiteBoardRoomToken params:params success:^(id responseObj) {
             NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
                  if ([responseObject[@"code"] integerValue] == 200) {
                      if (token) {
                          token(responseObject[@"msg"][@"roomToken"]);
                      }
                  }else {
                      if (failure) {
                          failure(@"获取失败");
                      }
                  }
         } failure:^(NSError *error) {
             if (failure) {
                 failure(@"获取失败");
             }
         }];
}

+ (NSString *)MD5WithString:(NSString *)str {
    const char *fooData = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(fooData, (CC_LONG)strlen(fooData), result);
    NSMutableString *saveResult = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    return saveResult;
}

+ (BOOL)judgeClassRoomText:(NSString *)text {
    NSString *regex = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:text] && text.length < 11) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)addShadowWithView:(UIView *)view alpha:(CGFloat)alpha {
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:alpha].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,2);
    view.layer.shadowOpacity = 2;
    view.layer.shadowRadius = 4;
    view.layer.masksToBounds = YES;
}
@end
