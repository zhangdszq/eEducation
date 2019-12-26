//
//  UIColor+Addition.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/3.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Addition)
//设置RGB颜色
+ (UIColor *)red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;
//将颜色转换成RGB
+ (NSArray *)convertColorToRGB:(UIColor *)color;
//设置十六进制颜色
+ (UIColor *)colorWithHex:(NSInteger)hex;
+ (UIColor*)colorWithHexString:(NSString *)hexString;
+(UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
@end

NS_ASSUME_NONNULL_END
