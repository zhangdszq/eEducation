//
//  BCTestViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/5.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCTestViewController.h"
#import "EETeactherVideoView.h"
#import "EENavigationView.h"

@interface BCTestViewController ()
@property (weak, nonatomic) IBOutlet EETeactherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *teacherWidthCon;
@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeight;

@end

@implementation BCTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    self.teacherWidthCon.constant = kScreenWidth;


    
}
//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
//    if (self.baseView.rotatingState != RotatingStateSmall) {
//        return;
//    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            self.teacherWidthCon.constant = 220;
            self.navigationHeight.constant = 30;

            self.navigationView.titleLabelBottomConstraint.constant = 5;
//            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//            self.fullScreenVC = [story instantiateViewControllerWithIdentifier:@"bcfsroom"];
//            [self presentToViewController:self.fullScreenVC];
        }
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
