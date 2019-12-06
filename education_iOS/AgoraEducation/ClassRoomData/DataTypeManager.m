//
//  JsonAndStringConversions.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/6/27.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "DataTypeManager.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation DataTypeManager
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
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
    if ([predicate evaluateWithObject:text] && text.length <= 11) {
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

+ (NSString *)getUserID{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970])];
    NSString *uid =  [NSString stringWithFormat:@"%@",[timeSp substringFromIndex:4]];
    return uid;
}
@end
