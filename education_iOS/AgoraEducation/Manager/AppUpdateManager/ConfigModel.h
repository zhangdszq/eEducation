//
//  ConfigModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/1/6.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface ConfigAllInfoModel : NSObject

//@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *appCode;
@property (nonatomic, assign) NSInteger osType;
@property (nonatomic, assign) NSInteger terminalType;
@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *latestVersion;
@property (nonatomic, strong) NSString *appPackage;
@property (nonatomic, strong) NSString *upgradeDescription;
@property (nonatomic, assign) NSInteger forcedUpgrade;//1 no update 2update 3force update
@property (nonatomic, strong) NSString *upgradeUrl;
@property (nonatomic, assign) NSInteger reviewing;
@property (nonatomic, assign) NSInteger remindTimes;

@end


@interface ConfigModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString* msg;
@property (nonatomic, strong) ConfigAllInfoModel* data;

@end

NS_ASSUME_NONNULL_END
