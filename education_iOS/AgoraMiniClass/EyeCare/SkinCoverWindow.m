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
            skinCoverLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            skinCoverLayer.backgroundColor = [UIColor blackColor].CGColor;
            skinCoverLayer.opacity = 0.5;
            [self.layer addSublayer:skinCoverLayer];
        }
    }
    return self;
}


@end
