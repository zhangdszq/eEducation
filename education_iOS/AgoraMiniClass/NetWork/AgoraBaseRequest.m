//
//  CYXBaseRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "AgoraBaseRequest.h"
#import "AgoraHttpRequest.h"
#import <MJExtension.h>
#import <UIKit/UIKit.h>

@implementation AgoraBaseRequest

+ (void)getWithUrl:(NSString *)url param:(id)param resultClass:(Class)resultClass success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = [param mj_keyValues];
    
    [AgoraHttpRequest get:url params:[self requestParams:params] success:^(id responseObj) {
        if (success) {
            id result = [resultClass mj_objectWithKeyValues:responseObj];
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)postResultWithUrl:(NSString *)url param:(id)param
              resultClass:(Class)resultClass
                  success:(void (^)(id result))success
                     warn:(void (^)(NSString *warnMsg))warn
                  failure:(void (^)(NSError *error))failure
             tokenInvalid:(void (^)(void))tokenInvalid
{
    [self postBaseWithUrl:url param:param resultClass:resultClass
                  success:^(id responseObj) {
                      if (!resultClass) {
                          success(nil);
                          return;
                      }
                      success([resultClass mj_objectArrayWithKeyValuesArray:responseObj[@"result"]]);
                  }
                     warn:warn
                  failure:failure
             tokenInvalid:tokenInvalid];
}

- (void)postBaseWithUrl:(NSString *)url param:(id)param
            resultClass:(Class)resultClass
                success:(void (^)(id result))success
                   warn:(void (^)(NSString *warnMsg))warn
                failure:(void (^)(NSError *error))failure
           tokenInvalid:(void (^)(void))tokenInvalid
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AgoraHttpRequest *httpRequest = [[AgoraHttpRequest alloc]init];
    [httpRequest post:url params:param success:^(id responseObj) {
        if (success) {
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            success(dictData);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

/**
 *  组合请求参数
 *
 *  @param dict 外部参数字典
 *
 *  @return 返回组合参数
 */
+ (NSMutableDictionary *)requestParams:(NSDictionary *)dict
{
    //
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    return params;
}


@end
