//
//  AEP2pMessageModel.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AEP2pMessageModel : NSObject
@property (nonatomic, assign) RTMp2pType cmd;
@property (nonatomic, copy) NSString *text;
@end

NS_ASSUME_NONNULL_END
