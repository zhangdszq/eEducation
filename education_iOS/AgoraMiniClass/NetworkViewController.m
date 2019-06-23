//
//  networkTestViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/12.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "NetworkViewController.h"
#import "RoomViewController.h"

@interface NetworkViewController ()<AgoraRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lostRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rttLabel;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *networkQualityImageView;

@end

@implementation NetworkViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.agoraKit.delegate = self;
    AgoraLastmileProbeConfig *lastmileConfig = [[AgoraLastmileProbeConfig alloc] init];
    lastmileConfig.probeUplink = YES;
    lastmileConfig.probeDownlink = YES;
    lastmileConfig.expectedUplinkBitrate = 800;
    lastmileConfig.expectedDownlinkBitrate = 800;
    [self.agoraKit  startLastmileProbeTest:lastmileConfig];
}

- (IBAction)backButton:(UIButton *)sender {
    UIViewController * presentingViewController = self.presentingViewController;
    while (presentingViewController.presentingViewController) {
        presentingViewController = presentingViewController.presentingViewController;
    }
    [presentingViewController dismissViewControllerAnimated:NO completion:nil];

}

- (IBAction)joinChannel:(UIButton *)sender {
//    RoomViewController *roomVC = [[RoomViewController alloc] init];
//    roomVC.agoraKit = self.agoraKit;
//    [self presentViewController:roomVC animated:NO completion:nil];
}

#pragma mark ----- agoraDelegate -----
- (void)rtcEngine:(AgoraRtcEngineKit *)engine lastmileQuality:(AgoraNetworkQuality)quality {
    NSString *qualityStr = @"  Nomal";
    switch (quality) {
        case AgoraNetworkQualityUnknown:
            qualityStr = @"  Nomal";
            break;
        case AgoraNetworkQualityExcellent:
        case AgoraNetworkQualityGood:
        case AgoraNetworkQualityPoor:
            [ self.networkQualityImageView setImage:[UIImage imageNamed:@"networkGood"]];
            qualityStr = @"Good";
            break;
        case AgoraNetworkQualityBad:
        case AgoraNetworkQualityVBad:
        case AgoraNetworkQualityDown:
            qualityStr = @"Bad";
              [ self.networkQualityImageView setImage:[UIImage imageNamed:@"networkBad"]];
            break;

        default:
            break;
    }
    [self.qualityLabel setText:qualityStr];

}
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine lastmileProbeTestResult:(AgoraLastmileProbeResult *_Nonnull)result {
    [self.lostRateLabel setText:[NSString stringWithFormat:@"%ld",result.uplinkReport.packetLossRate]];
    [self.rttLabel setText:[NSString stringWithFormat:@"%ldms",result.rtt]];

}
- (void)dealloc
{
    NSLog(@"NetworkViewController is dealloc");
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"networkToRoom"]) {
        RoomViewController *roomVC = segue.destinationViewController;
        roomVC.agoraKit = self.agoraKit;
    }
}

@end
