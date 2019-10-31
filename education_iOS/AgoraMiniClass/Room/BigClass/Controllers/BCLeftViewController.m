//
//  BCLeftViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCLeftViewController.h"
@interface BCLeftViewController ()
@end

@implementation BCLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"BCLeftViewController is dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
