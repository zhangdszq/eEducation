//
//  ReplayViewController.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/10.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "ReplayViewController.h"
#import <AVKit/AVKit.h>
#import <Whiteboard/Whiteboard.h>
#import "OTOTeacherView.h"
#import "ReplayControlView.h"
#import "AgoraHttpRequest.h"
#import "EduButton.h"

#define PREFERRED_TIME_SCALE 100

@interface ReplayViewController ()<WhiteCombineDelegate, WhiteCommonCallbackDelegate, WhitePlayerEventDelegate, ReplayControlViewDelegate, WhiteRoomCallbackDelegate>

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;

@property (weak, nonatomic) IBOutlet EduButton *backButton;

@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;

@property (nonatomic, strong) WhiteSDK *whiteSDK;
@property (nonatomic, strong) WhiteCombinePlayer *combinePlayer;

@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, weak) WhiteVideoView *videoView;
@property (nonatomic, assign) BOOL canSeek;

@end

@implementation ReplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initData];
}

- (void)initData {
    
    self.controlView.delegate = self;
    self.canSeek = NO;
  
//     [self setupWhiteboardWithRoomId:@"ed4071b95ca94a339f69bf74077a98f9" roomToken:@"WHITEcGFydG5lcl9pZD0zZHlaZ1BwWUtwWVN2VDVmNGQ4UGI2M2djVGhncENIOXBBeTcmc2lnPWI3NTEyNmVkNzIzNDgxZDViMDk2Nzc2MWM5YTA3MzUyMGFmNDU4YzE6YWRtaW5JZD0xNTgmcm9vbUlkPWVkNDA3MWI5NWNhOTRhMzM5ZjY5YmY3NDA3N2E5OGY5JnRlYW1JZD0yODMmcm9sZT1yb29tJmV4cGlyZV90aW1lPTE2MDc1MTg4MDQmYWs9M2R5WmdQcFlLcFlTdlQ1ZjRkOFBiNjNnY1RoZ3BDSDlwQXk3JmNyZWF0ZV90aW1lPTE1NzU5NjE4NTImbm9uY2U9MTU3NTk2MTg1MjQ3MjAw"];
    WEAK(self)
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:self.roomid token:^(NSString * _Nonnull token) {

        [weakself setupWhiteboardWithRoomId:weakself.roomid roomToken:token];

    } failure:^(NSString * _Nonnull msg) {
        NSLog(@"获取token失败 %@",msg);
    }];
}

- (void)setupWhiteboardWithRoomId:(NSString *)roomId roomToken:(NSString*)roomToken{
    //配置 SDK 设置
    WhiteSdkConfiguration *config = [WhiteSdkConfiguration defaultConfig];
    //通过实例化，并已经添加在视图栈中 Whiteboard，初始化 WhiteSDK。
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:config commonCallbackDelegate:self];

    //初始化回放配置类
    WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:roomId roomToken:roomToken];
    if(self.startTime.length == 13){
        self.startTime = [self.startTime substringToIndex:10];
    }
    playerConfig.beginTimestamp = @(self.startTime.integerValue);
    
//    // 现在还没有视频
//    NSString *videoPath = @"";
////    NSString *videoPath = @"https://white-pan.oss-cn-shanghai.aliyuncs.com/101/oceans.mp4";
//    __block NSTimeInterval time = 0;
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];
//        time = CMTimeGetSeconds([asset duration]);
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            playerConfig.duration = @((int)time);
//            [self createReplyWithConfig:playerConfig videoPath:videoPath];
//        });
//    });
    
    [self createReplyWithConfig:playerConfig videoPath:@"https://www.baidu.com/"];
}

- (void)setupView {

    WhiteVideoView *videoView = [[WhiteVideoView alloc] initWithFrame:self.teacherView.bounds];
    videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.teacherView addSubview:videoView];
    self.videoView = videoView;
    
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.whiteboardBaseView insertSubview:boardView belowSubview:self.playBackgroundView];
    self.boardView = boardView;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
}
                       
- (void)createReplyWithConfig:(WhitePlayerConfig *)playerConfig videoPath:(NSString*)videoPath {
        
    WEAK(self)
    [self.whiteSDK createReplayerWithConfig:playerConfig callbacks:self completionHandler:^(BOOL success, WhitePlayer * _Nonnull player, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"创建回放房间失败 error:%@", [error localizedDescription]);
        } else {
            // 视频的url
            weakself.combinePlayer = [[WhiteCombinePlayer alloc] initWithMediaUrl:[NSURL URLWithString:videoPath] whitePlayer:player];
            [weakself.videoView setAVPlayer:weakself.combinePlayer.nativePlayer];
            weakself.combinePlayer.delegate = weakself;
            
            [weakself.view layoutIfNeeded];
            [weakself.combinePlayer.whitePlayer refreshViewSize];
            NSLog(@"创建回放房间成功");
        }
    }];
}
- (IBAction)onBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPlayClick:(id)sender {
    
    [self setPlayViewsVisible:YES];
    [self setLoadingViewVisible:YES];
    [self.combinePlayer play];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (void)setLoadingViewVisible:(BOOL)onPlay {
    
    self.loadingView.hidden = !onPlay;
    [self.loadingView.layer removeAllAnimations];
    if(onPlay) {
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
        rotationAnimation.duration = 2;
        rotationAnimation.repeatCount = HUGE_VALF;
        [self.loadingView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

-(void)setPlayViewsVisible:(BOOL)onPlay {
    self.playBackgroundView.hidden = onPlay;
    self.playButton.hidden = onPlay;
    self.controlView.playOrPauseBtn.selected = onPlay;
}

#pragma mark WhiteCommonCallbackDelegate
/** 当sdk出现未捕获的全局错误时，会在此处对抛出 NSError 对象 */
- (void)throwError:(NSError *)error {
    NSLog(@"创建白板信息==》%@", [error localizedDescription]);
}

#pragma mark WhiteCombineDelegate
- (void)combinePlayerStartBuffering
{
    NSLog(@"combinePlayerStartBuffering");
    if(self.playButton.hidden){
        [self setLoadingViewVisible:YES];
    }
}

- (void)combinePlayerEndBuffering
{
    NSLog(@"combinePlayerEndBuffering");
    self.canSeek = YES;
    [self setLoadingViewVisible:NO];
}

- (void)nativePlayerDidFinish {
    [self.combinePlayer pause];

    CMTime cmTime = CMTimeMakeWithSeconds(0, PREFERRED_TIME_SCALE);
    [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
        
    }];
    
    [self setPlayViewsVisible:NO];

    self.controlView.sliderView.value = 0;
    NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
    NSString *currentTimeStr = [self convertTimeSecond: 0];
    NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
    self.controlView.timeLabel.text = timeStr;
}

#pragma mark WhitePlayerEventDelegate
/** 播放状态切换回调 */
- (void)phaseChanged:(WhitePlayerPhase)phase {
    [self.combinePlayer updateWhitePlayerPhase:phase];
}

/** 进度时间变化 */
- (void)scheduleTimeChanged:(NSTimeInterval)time {
    
    if(self.controlView.sliderView.isdragging){
        return;
    }
    
    if([self timeTotleDuration] > 0){
        float value = time / [self timeTotleDuration];
        self.controlView.sliderView.value = value;
        NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
        NSString *currentTimeStr = [self convertTimeSecond: time];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    }
}

-(NSTimeInterval) timeTotleDuration {
    return self.combinePlayer.whitePlayer.timeInfo.timeDuration;
}


#pragma mark ReplayControlViewDelegate
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value {
    if(!self.canSeek) {
        return;
    }
    
    self.controlView.sliderView.isdragging = YES;
}
// 滑块滑动中
- (void)sliderValueChanged:(float)value {
    if(!self.canSeek) {
        return;
    }
    
    if ([self timeTotleDuration] > 0) {
        Float64 seconds = [self timeTotleDuration] * value;
        
        CMTime cmTime = CMTimeMakeWithSeconds(seconds, PREFERRED_TIME_SCALE);
        [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
            
        }];
    }
}
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value {
    if(!self.canSeek) {
        return;
    }
    
    if ([self timeTotleDuration] == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = [self timeTotleDuration] * value;
    
    Float64 seconds = currentTime;
    CMTime cmTime = CMTimeMakeWithSeconds(seconds, PREFERRED_TIME_SCALE);
    [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
        
    }];
    
    NSString *currentTimeStr = [self convertTimeSecond: currentTime];
    NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
    NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
    self.controlView.timeLabel.text = timeStr;
    
    self.controlView.sliderView.isdragging = NO;
}

- (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

// 滑杆点击
- (void)sliderTapped:(float)value {
    if(!self.canSeek) {
        return;
    }
    
    self.controlView.sliderView.isdragging = YES;
    
    if([self timeTotleDuration] > 0) {
        float currentTime = [self timeTotleDuration] * value;
        CMTime cmTime = CMTimeMakeWithSeconds(currentTime, PREFERRED_TIME_SCALE);
        WEAK(self)
        [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
            weakself.controlView.sliderView.isdragging = NO;
        }];
//        self.controlView.sliderView.isdragging = NO;
        
//        [self.player seekToScheduleTime:currentTime];
        NSString *currentTimeStr = [self convertTimeSecond: currentTime];
        NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    } else {
        self.controlView.sliderView.value = 0;
        self.controlView.sliderView.isdragging = NO;
    }
}
// 播放暂停按钮点击
- (void)playPauseButtonClicked:(BOOL)play {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    [self setPlayViewsVisible:play];
    [self setLoadingViewVisible:play];
    
    if(play) {
        [self.combinePlayer play];
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
    } else {
        [self.combinePlayer pause];
    }
}

-(void)hideControlView {
    self.controlView.hidden = YES;
}
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
