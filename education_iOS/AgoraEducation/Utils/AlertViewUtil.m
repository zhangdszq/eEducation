//
//  AlertViewUtil.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/20.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AlertViewUtil.h"

@implementation AlertViewUtil
+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title sureHandler:(KAlertHandler)sureHandler {
    [[AlertViewUtil alloc] initWithDeleteDecideWithController:viewController title:title sureHandler:sureHandler];
}

+ (void)showAlertWithController:(UIViewController *)viewController title:(NSString *)title {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:actionCancel];
    [viewController presentViewController:alertVc animated:YES completion:nil];
}

- (void)initWithDeleteDecideWithController:(UIViewController *)viewController title:(NSString *)title sureHandler:(KAlertHandler)sureHandler
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !sureHandler ? : sureHandler(action);
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVc addAction:actionDone];
    [alertVc addAction:actionCancel];
    [viewController presentViewController:alertVc animated:YES completion:nil];
}
@end
