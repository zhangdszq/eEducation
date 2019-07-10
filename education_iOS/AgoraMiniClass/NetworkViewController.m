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

@interface NetworkViewController ()<AgoraRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lostRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rttLabel;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UIButton *netWorkQualityImage;

@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, strong) ClassRoomDataManager * classRoomDataManager;
@end

@implementation NetworkViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    self.classRoomDataManager = [ClassRoomDataManager shareManager];
    AgoraLastmileProbeConfig *lastmileConfig = [[AgoraLastmileProbeConfig alloc] init];
    lastmileConfig.probeUplink = YES;
    lastmileConfig.probeDownlink = YES;
    lastmileConfig.expectedUplinkBitrate = 800;
    lastmileConfig.expectedDownlinkBitrate = 800;
    [self.agoraKit  startLastmileProbeTest:lastmileConfig];
    [self setUpView];
}

- (void)setUpView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
}

- (IBAction)backButton:(UIButton *)sender {
    [self.agoraKit  stopLastmileProbeTest];
    UIViewController * presentingViewController = self.presentingViewController;
    while (presentingViewController.presentingViewController) {
        presentingViewController = presentingViewController.presentingViewController;
    }
    [presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)joinChannel:(UIButton *)sender {
    if (self.activityIndicator.animating == NO) {
        [self.agoraKit  stopLastmileProbeTest];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        RoomViewController *roomVC = [story instantiateViewControllerWithIdentifier:@"room"];
        [self presentViewController:roomVC animated:YES completion:nil];
    }
}

#pragma mark ----- agoraDelegate -----
- (void)rtcEngine:(AgoraRtcEngineKit *)engine lastmileQuality:(AgoraNetworkQuality)quality {
    switch (quality) {
        case AgoraNetworkQualityUnknown:
        {
            [self.netWorkQualityImage setImage:[UIImage imageNamed:@"networkNomal"] forState:(UIControlStateNormal)];
            [self.netWorkQualityImage setTitle:@"Nomal" forState:(UIControlStateNormal)];
        }
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
    [self.activityIndicator stopAnimating];
    [self.lostRateLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)result.uplinkReport.packetLossRate]];
    [self.rttLabel setAttributedText:[self changeLabelWithText:[NSString stringWithFormat:@"%lums",(unsigned long)result.rtt]]];
}

- (void)dealloc
{
    self.activityIndicator = nil;
    NSLog(@"NetworkViewController is dealloc");
}

-(NSMutableAttributedString*)changeLabelWithText:(NSString*)needText
{
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
@end
