//
//  networkTestViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/12.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "NetworkViewController.h"
#import "RoomViewController.h"
#import "ClassRoomDataManager.h"

@interface NetworkViewController ()<AgoraRtcEngineDelegate,ClassRoomDataManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lostRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rttLabel;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UIButton *netWorkQualityImage;
@property (weak, nonatomic) IBOutlet UIButton *joinClassRoomButton;
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *joinRoomActivityIndicator;
@property (nonatomic, strong) ClassRoomDataManager * classRoomDataManager;
@end

@implementation NetworkViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    self.classRoomDataManager = [ClassRoomDataManager shareManager];
    self.classRoomDataManager.classRoomManagerDelegate = self;
    AgoraLastmileProbeConfig *lastmileConfig = [[AgoraLastmileProbeConfig alloc] init];
    lastmileConfig.probeUplink = YES;
    lastmileConfig.probeDownlink = YES;
    lastmileConfig.expectedUplinkBitrate = 800;
    lastmileConfig.expectedDownlinkBitrate = 800;
    [self.agoraKit  startLastmileProbeTest:lastmileConfig];
}

- (void)setUpView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor clearColor];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
}

- (IBAction)backButton:(UIButton *)sender {
    [self.agoraKit  stopLastmileProbeTest];
    [self.classRoomDataManager removeClassRoomInfo];
    [self.classRoomDataManager.agoraRtmChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
    }];
    UIViewController * presentingViewController = self.presentingViewController;
    while (presentingViewController.presentingViewController) {
        presentingViewController = presentingViewController.presentingViewController;
    }
    [presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)joinChannel:(UIButton *)sender {
    [self setUpView];
    [self.classRoomDataManager joinClassRoom];
    self.joinClassRoomButton.enabled = NO;
}

#pragma mark ----- agoraDelegate -----
- (void)rtcEngine:(AgoraRtcEngineKit *)engine lastmileQuality:(AgoraNetworkQuality)quality {
    switch (quality) {
        case AgoraNetworkQualityUnknown:
            [self.netWorkQualityImage setImage:[UIImage imageNamed:@"networkNomal"] forState:(UIControlStateNormal)];
            [self.netWorkQualityImage setTitle:@"Nomal" forState:(UIControlStateNormal)];
            break;
        case AgoraNetworkQualityExcellent:
        case AgoraNetworkQualityGood:
        case AgoraNetworkQualityPoor:
            [self.netWorkQualityImage setImage:[UIImage imageNamed:@"networkGood"] forState:(UIControlStateNormal)];
            [self.netWorkQualityImage setTitle:@"Good" forState:(UIControlStateNormal)];
            break;
        case AgoraNetworkQualityBad:
        case AgoraNetworkQualityVBad:
        case AgoraNetworkQualityDown:
            [self.netWorkQualityImage setImage:[UIImage imageNamed:@"networkBad"] forState:(UIControlStateNormal)];
            [self.netWorkQualityImage setTitle:@"Bad" forState:(UIControlStateNormal)];
            break;

        default:
            break;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine lastmileProbeTestResult:(AgoraLastmileProbeResult *_Nonnull)result {
    [self.lostRateLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)result.uplinkReport.packetLossRate]];
    [self.rttLabel setAttributedText:[self changeLabelWithText:[NSString stringWithFormat:@"%lums",(unsigned long)result.rtt]]];
}

- (void)dealloc {
    self.activityIndicator = nil;
    NSLog(@"NetworkViewController is dealloc");
}

-(NSMutableAttributedString*)changeLabelWithText:(NSString*)needText {
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:needText];
    UIFont *font = [UIFont systemFontOfSize:36 weight:UIFontWeightMedium];
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,needText.length - 2)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(needText.length - 2,2)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(needText.length - 2,2)];
    [attrString addAttribute:NSForegroundColorAttributeName value:RCColorWithValue(0x333333, 1.f) range:NSMakeRange(0,needText.length - 2)];
    [attrString addAttribute:NSForegroundColorAttributeName value:RCColorWithValue(0x666666, 1.f) range:NSMakeRange(needText.length - 2,2)];
    return attrString;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark  ------------------------  classRoomManagerDelegate ---------------------
- (void)joinClassRoomSuccess {
    self.joinClassRoomButton.enabled = YES;
    [self.agoraKit  stopLastmileProbeTest];
    [self.activityIndicator stopAnimating];
    if (self.activityIndicator.animating == NO) {
        [self.agoraKit  stopLastmileProbeTest];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        RoomViewController *roomVC = [story instantiateViewControllerWithIdentifier:@"room"];
        [self presentViewController:roomVC animated:YES completion:nil];
    }
}

- (void)joinClassRoomError:(ClassRoomErrorcode)errorCode {
    self.joinClassRoomButton.enabled = YES;
    [self.activityIndicator stopAnimating];
    UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"join classRoom error" message:@"no network" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alterVC addAction:sure];
    [self presentViewController:alterVC animated:YES completion:nil];
}
@end
