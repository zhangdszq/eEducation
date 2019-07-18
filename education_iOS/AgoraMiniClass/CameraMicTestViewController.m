//
//  CameraMicTestViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/11.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "CameraMicTestViewController.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "NetworkViewController.h"

@interface CameraMicTestViewController ()<AgoraRtcEngineDelegate>
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;
@property (weak, nonatomic) IBOutlet UIView *localVideoView;
@property (weak, nonatomic) IBOutlet UIProgressView *micVolumeView;


@end

@implementation CameraMicTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    [self.agoraKit startPreview];
    [self.agoraKit enableAudioVolumeIndication:300 smooth:1];
    [self setUpLocalVideo];
}

- (void)setUpLocalVideo {
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid  = 0;
    canvas.view = self.localVideoView;
    [self.agoraKit setupLocalVideo:canvas];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (IBAction)adjustVolume:(UISlider *)sender {
    [self.agoraKit adjustPlaybackSignalVolume:sender.value * 100];
}

- (IBAction)switchCamera:(UIButton *)sender {
    [self.agoraKit switchCamera];
}

- (IBAction)backButton:(UIButton *)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ------ AgoraDelegate -----
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    NSLog(@"error---- %ld",(long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraWarningCode)warningCode {
    NSLog(@"warningCode---- %ld",(long)warningCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo *> *)speakers
    totalVolume:(NSInteger)totalVolume {
    for (AgoraRtcAudioVolumeInfo *info in speakers) {
        if (info.uid == 0 ) {
            self.micVolumeView.progress = (float)totalVolume / 255.f;
        }
    }

    
}
- (void)dealloc {
    NSLog(@"CameraMicTestViewController is Dealloc");
}

@end
