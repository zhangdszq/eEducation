//
//  AgoraAlertViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/6/30.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "AgoraAlertViewController.h"

@interface AgoraAlertViewController ()

@end

@implementation AgoraAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)autoDismiss:(float)time {
    WEAK(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself dismissViewControllerAnimated:YES completion:nil];
    });
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}
- (void)dealloc {
    NSLog(@"AgoraAlertViewController is   Dealloc");
}
@end
