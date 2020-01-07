//
//  OneToOneViewController.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneToOneEducationManager.h"
#import "VCParamsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OneToOneViewController : UIViewController

@property (nonatomic, strong) VCParamsModel *paramsModel;
@property (nonatomic, strong) OneToOneEducationManager *educationManager;

@end

NS_ASSUME_NONNULL_END
