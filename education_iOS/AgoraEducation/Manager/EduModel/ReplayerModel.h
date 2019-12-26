//
//  ReplayerModel.h
//  AgoraEducation
//
//  Created by SRS on 2019/12/18.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplayerModel : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;

@end

