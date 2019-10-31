//
//  BigClassViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCViewController.h"
#import "EESegmentedView.h"
#import "EEPageControlView.h"
#import "EEChatContentTableView.h"
#import "EEWhiteboardTool.h"
#import "EEChatTextFiled.h"
#import "EEStudentVideoView.h"
#import "BCFullScreenViewController.h"
#import "BCLeftViewController.h"
#import "EEEnterFullScreenTransition.h"
#import "BCLeftViewController.h"
#import "BCRightViewController.h"
#import "EEExitFullScreenTransitioning.h"

@interface BCViewController ()<EESegmentedDelegate,EEWhiteboardToolDelegate,EEPageControlDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic, weak) UIButton *closeButton;
@property (weak, nonatomic) IBOutlet EETeactherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet EEStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet EESegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstraint;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEChatContentTableView *chatContentTableView;
@property (nonatomic, strong) EEEnterFullScreenTransition *landscapeTransition;
@property (nonatomic, strong) BCFullScreenViewController *fullScreenViewController;
@end

@implementation BCViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    CGFloat navigationBarHeight =  (kScreenHeight / kScreenWidth > 1.78) ? 88 : 64;
    self.navigationHeightConstraint.constant = navigationBarHeight;
    [self.navigationView.closeButton addTarget:self action:@selector(closeRoom:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.segmentedView setNeedsLayout];
    [self.segmentedView layoutIfNeeded];
    self.segmentedView.delegate = self;
    self.chatContentTableView.hidden = YES;
    self.chatTextFiled.hidden = YES;
    self.whiteboardTool.delegate = self;
    self.studentVideoView.hidden = YES;
    self.pageControlView.delegate = self;
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


    self.transitioningDelegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
//    if (self.baseView.rotatingState != RotatingStateSmall) {
//        return;
//    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;

        case UIDeviceOrientationLandscapeLeft:
        {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            BCRightViewController *rightVC = [story instantiateViewControllerWithIdentifier:@"bcfsroom"];
            [self presentToViewController:rightVC];
        }
            NSLog(@"向左");
            break;
        case UIDeviceOrientationLandscapeRight:
        {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            BCLeftViewController *leftVC = [story instantiateViewControllerWithIdentifier:@"bcfsroom"];
            [self presentToViewController:leftVC];
        }
            NSLog(@"向右");
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"垂直");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}
- (void)presentToViewController:(BCFullScreenViewController *)viewController {
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.modalPresentationCapturesStatusBarAppearance = YES;
    viewController.transitioningDelegate = self;;
    [self presentViewController:viewController animated:YES completion:^{

    }];
}

- (void)selectedItemIndex:(NSInteger)index {
    if (index == 0) {
        self.chatContentTableView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.pageControlView.hidden = NO;
        self.handUpButton.hidden = NO;
        self.whiteboardTool.hidden = NO;
    }else {
        self.chatContentTableView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.pageControlView.hidden = YES;
        self.handUpButton.hidden = YES;
        self.whiteboardTool.hidden = YES;
    }
}

- (void)selectWhiteboardToolIndex:(NSInteger)index {
    NSLog(@"点击了那个道具");
}

- (void)closeRoom:(UIButton *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
//   UIViewController * presentingViewController = self.presentingViewController;
//    while (presentingViewController.presentingViewController) {
//        presentingViewController = presentingViewController.presentingViewController;
//    }
//    [presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)previousPage {

}
- (void)nextPage {

}
- (void)lastPage {

}
- (void)firstPage {

}

- (IBAction)handUpEvent:(UIButton *)sender {

}


- (void)dealloc {
    NSLog(@"BigClassViewController is Dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    EEEnterFullScreenTransition *landscapeTransition = [[EEEnterFullScreenTransition alloc] init];
   return  landscapeTransition;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    EEExitFullScreenTransitioning *fullScreenTransitioning  = [[EEExitFullScreenTransitioning alloc] init];
    return fullScreenTransitioning;
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
