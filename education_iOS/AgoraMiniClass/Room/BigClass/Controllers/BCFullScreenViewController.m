//
//  BCFullScreenViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCFullScreenViewController.h"
#import "EENavigationView.h"
#import "EEPageControlView.h"
#import "EEWhiteboardTool.h"
#import "EEChatContentTableView.h"
#import "EETeactherVideoView.h"
#import "EEStudentVideoView.h"

@interface BCFullScreenViewController ()<EEPageControlDelegate,EEWhiteboardToolDelegate>
@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet EEChatContentTableView *chatContentTableView;
@property (weak, nonatomic) IBOutlet EETeactherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet EEStudentVideoView *studentVideoView;

@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;


@end

@implementation BCFullScreenViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self prefersStatusBarHidden];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationView.titleLabelBottomConstraint.constant = 5;
    self.navigationView.closeButtonBottomConstraint.constant = 5;
    self.navigationView.wifiSignalImage.hidden = NO;
    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;

    self.tipLabel.hidden = YES;

    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:229/255.0 alpha:1.0].CGColor;

    self.handUpButton.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.handUpButton.layer.cornerRadius = 6;
    self.handUpButton.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    self.handUpButton.layer.shadowOffset = CGSizeMake(0,2);
    self.handUpButton.layer.shadowOpacity = 2;
    self.handUpButton.layer.shadowRadius = 4;
    self.handUpButton.layer.masksToBounds = YES;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    self.tipLabel.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.25].CGColor;
    self.tipLabel.layer.shadowOffset = CGSizeMake(0,2);
    self.tipLabel.layer.shadowOpacity = 2;
    self.tipLabel.layer.shadowRadius = 4;
    self.tipLabel.layer.masksToBounds = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
    name:UIDeviceOrientationDidChangeNotification object:nil];
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
//    if (self.baseView.rotatingState != RotatingStateLandscape) {
//        return;
//    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self dismissViewControllerAnimated:YES completion:^{
               
            }];
        }
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}

- (void)closeRoom:(UIButton *)sender {
    NSLog(@"closeroom");
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc
{
    NSLog(@"BCFullScreenViewController is dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)firstPage {

}

- (void)lastPage {

}

- (void)nextPage {

}

- (void)previousPage {

}

- (void)selectWhiteboardToolIndex:(NSInteger)index {

}


@end
