//
//  CYXBaseRequest.h
//  TenMinDemo
//
//  Created by apple开发 on 16/5/31.
//  Copyright © 2016年 CYXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AgoraBaseRequest : NSObject

+ (void)getWithUrl:(NSString *)url param:(id)param resultClass:(Class)resultClass success:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)postResultWithUrl:(NSString *)url param:(id)param
              resultClass:(Class)resultClass
                  success:(void (^)(id result))success
                     warn:(void (^)(NSString *warnMsg))warn
                  failure:(void (^)(NSError *error))failure
             tokenInvalid:(void (^)(void))tokenInvalid;



@end
