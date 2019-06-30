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
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@end

@implementation NetworkViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    AgoraLastmileProbeConfig *lastmileConfig = [[AgoraLastmileProbeConfig alloc] init];
    lastmileConfig.probeUplink = YES;
    lastmileConfig.probeDownlink = YES;
    lastmileConfig.expectedUplinkBitrate = 800;
    lastmileConfig.expectedDownlinkBitrate = 800;
    [self.agoraKit  startLastmileProbeTest:lastmileConfig];
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
    [self.agoraKit  stopLastmileProbeTest];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    RoomViewController *roomVC = [story instantiateViewControllerWithIdentifier:@"room"];
    [self presentViewController:roomVC animated:YES completion:nil];
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
    [self.rttLabel setAttributedText:[self changeLabelWithText:[NSString stringWithFormat:@"%ldms",result.rtt]]];
}

- (void)dealloc
{
    NSLog(@"NetworkViewController is dealloc");
}

-(NSMutableAttributedString*)changeLabelWithText:(NSString*)needText
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:needText];
    UIFont *font = [UIFont systemFontOfSize:36];
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0,needText.length - 2)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(needText.length - 2,2)];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(needText.length - 2,2)];
    [attrString addAttribute:NSForegroundColorAttributeName value:RCColorWithValue(0x333333, 1.f) range:NSMakeRange(0,needText.length - 2)];
    [attrString addAttribute:NSForegroundColorAttributeName value:RCColorWithValue(0x666666, 1.f) range:NSMakeRange(needText.length - 2,2)];
    return attrString;
}
@end
