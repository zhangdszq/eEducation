//
//  WhiteBoardToolControl.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/18.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WhiteBoardAppliance) {
    WhiteBoardAppliancePencil       = 0,
    WhiteBoardApplianceSelector     = 1,
    WhiteBoardApplianceRectangle    = 2,
    WhiteBoardApplianceEraser       = 3,
    WhiteBoardApplianceText         = 4,
    WhiteBoardApplianceEllipse          = 5,
};

typedef void(^SelectAppliance)(WhiteBoardAppliance applicate);

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardToolControl : UIView
@property (nonatomic, copy) SelectAppliance selectAppliance;
@end

NS_ASSUME_NONNULL_END
