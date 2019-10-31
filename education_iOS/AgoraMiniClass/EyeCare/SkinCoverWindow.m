//
//  SkinCoverWindow.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/9/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "SkinCoverWindow.h"
#import "SkinCoverLayer.h"

@implementation SkinCoverWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (self = [super initWithFrame:frame]) {
            [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            SkinCoverLayer *skinCoverLayer = [SkinCoverLayer layer];
            UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
            if (duration == UIDeviceOrientationLandscapeLeft || duration == UIDeviceOrientationLandscapeRight) {
                skinCoverLayer.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
            }else {
                skinCoverLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            }
            skinCoverLayer.backgroundColor = RCColorWithValue(0xFF9900, 0.1f).CGColor;
            [self.layer addSublayer:skinCoverLayer];
        }
    }
    return self;
}


@end
