//
//  OneToOneViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "OneToOneViewController.h"

@interface OneToOneViewController ()

@end

@implementation OneToOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view.
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(kScreenWidth / 2 - 100, kScreenHeight/2 - 20, 200, 40);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:tipLabel];
    [tipLabel setText:@"暂未开放"];
    tipLabel.backgroundColor = [UIColor blackColor];

    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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
