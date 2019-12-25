//
//  CYXHttpRequest.m
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import "AgoraHttpRequest.h"
#import <AFNetworking.h>

@interface AgoraHttpRequest ()

@property (nonatomic,strong) AFHTTPSessionManager * manager;

@end

@implementation AgoraHttpRequest

- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    [mgr GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];

}

- (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *mgr = self.manager;
    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr.requestSerializer.timeoutInterval = 10;
    [mgr POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
                   success(responseObject);
               }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
          failure(error);
        }
    }];
}

+ (void)POSTWhiteBoardRoomWithUuid:(NSString *)uuid token:(void (^)(NSString *token))token failure:(void (^)(NSString *msg))failure{
    
    NSString *urlString = @"https://cloudcapiv4.herewhite.com/room/join";
    AgoraHttpRequest *request = [[AgoraHttpRequest alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@?uuid=%@&token=%@",urlString,uuid,kWhiteBoardToken];
    [request post:url params:nil success:^(id responseObj) {
        if ([responseObj[@"code"] integerValue] == 200) {
            if (token) {
                token(responseObj[@"msg"][@"roomToken"]);
            }
        }else {
            if (failure) {
                failure(@"获取roomToken失败");
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(@"获取roomToken失败");
        }
    }];
}
@end
