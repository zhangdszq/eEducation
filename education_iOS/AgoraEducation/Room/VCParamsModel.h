//
//  VCParamsModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/25.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SceneMode) {
    SceneMode1V1 = 1,
    SceneModeSmall = 2,
    SceneModeBig = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface VCParamsModel : NSObject

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *channelName;



@end

NS_ASSUME_NONNULL_END
