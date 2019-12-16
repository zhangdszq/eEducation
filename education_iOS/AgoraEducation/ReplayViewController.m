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

#define PREFERRED_TIME_SCALE 100
@interface ReplayViewController ()<WhiteCombineDelegate, WhiteCommonCallbackDelegate, WhitePlayerEventDelegate, ReplayControlViewDelegate>

@property (nonatomic, strong) WhiteSDK *whiteSDK;
@property (nonatomic, strong) WhitePlayer *player;
@property (nonatomic, strong) WhiteCombinePlayer *combinePlayer;

@property (nonatomic, strong) WhiteBoardView *boardView;
@property (nonatomic, strong) WhiteVideoView *videoView;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;

@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;

@end

@implementation ReplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self setupWhiteboard];
}

- (void)setupWhiteboard {
    //配置 SDK 设置
    WhiteSdkConfiguration *config = [WhiteSdkConfiguration defaultConfig];
    //通过实例化，并已经添加在视图栈中 Whiteboard，初始化 WhiteSDK。
    self.whiteSDK = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:config commonCallbackDelegate:self];

    //初始化回放配置类
    WhitePlayerConfig *playerConfig = [[WhitePlayerConfig alloc] initWithRoom:@"" roomToken:@""];
    
    NSString *videoPath = @"https://white-pan.oss-cn-shanghai.aliyuncs.com/101/oceans.mp4";
    __block NSTimeInterval time = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString: videoPath]];
        time = CMTimeGetSeconds([asset duration]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            playerConfig.duration = @((int)time);
            [self createReplyWithConfig:playerConfig videoPath:videoPath];
        });
    });
    
//    NSString *videoPath = @"https://netless-media.oss-cn-hangzhou.aliyuncs.com/c447a98ece45696f09c7fc88f649c082_3002a61acef14e4aa1b0154f734a991d.m3u8";


//    /** 传入对应的UTC 时间戳(秒)，如果正确，则会在对应的位置开始播放。 */
//    @property (nonatomic, strong, nullable) NSNumber *beginTimestamp;
}

- (void)setupView {
    
    self.controlView.delegate = self;
    
    _videoView = [[WhiteVideoView alloc] initWithFrame:self.teacherView.bounds];
    _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.teacherView addSubview:_videoView];
    
    _boardView = [[WhiteBoardView alloc] init];
    _boardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.whiteboardBaseView insertSubview:_boardView belowSubview:self.playBackgroundView];
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:_boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:_boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:_boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
}
                       
- (void)createReplyWithConfig:(WhitePlayerConfig *)playerConfig videoPath:(NSString*)videoPath {
        
    WEAK(self)
    [self.whiteSDK createReplayerWithConfig:playerConfig callbacks:self completionHandler:^(BOOL success, WhitePlayer * _Nonnull player, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"创建回放房间失败 error:%@", [error localizedDescription]);
        } else {
            weakself.player = player;
            // 视频的url
            weakself.combinePlayer = [[WhiteCombinePlayer alloc] initWithMediaUrl:[NSURL URLWithString:videoPath] whitePlayer:player];
            [weakself.videoView setAVPlayer:weakself.combinePlayer.nativePlayer];
            weakself.combinePlayer.delegate = weakself;
            NSLog(@"创建回放房间成功");
        }
    }];
}

- (IBAction)onPlayClick:(id)sender {
    
    self.playBackgroundView.hidden = YES;
    self.playButton.hidden = YES;
    self.controlView.playOrPauseBtn.selected = YES;
    self.defaultTeacherImage.hidden = YES;
    [self.combinePlayer play];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

#pragma mark WhiteCommonCallbackDelegate
/** 当sdk出现未捕获的全局错误时，会在此处对抛出 NSError 对象 */
- (void)throwError:(NSError *)error {
    NSLog(@"创建白板信息==》%@", [error localizedDescription]);
}

#pragma mark WhiteCombineDelegate
- (void)nativePlayerDidFinish {
    [self.combinePlayer pause];

    CMTime cmTime = CMTimeMakeWithSeconds(0, PREFERRED_TIME_SCALE);
    [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {

    }];
    
    self.playBackgroundView.hidden = NO;
    self.playButton.hidden = NO;
    self.controlView.playOrPauseBtn.selected = NO;
    self.defaultTeacherImage.hidden = NO;

    self.controlView.sliderView.value = 0;
    NSString *totleTimeStr = [self convertTimeSecond: self.player.timeInfo.timeDuration];
    NSString *currentTimeStr = [self convertTimeSecond: 0];
    NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
    self.controlView.timeLabel.text = timeStr;
}

- (void)combinePlayerStartBuffering
{
    NSLog(@"combinePlayerStartBuffering");
}

- (void)combinePlayerEndBuffering
{
    NSLog(@"combinePlayerEndBuffering");
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
    
    if(self.player.timeInfo.timeDuration > 0){
        float value = time / self.player.timeInfo.timeDuration;
        self.controlView.sliderView.value = value;
        NSString *totleTimeStr = [self convertTimeSecond: self.player.timeInfo.timeDuration];
        NSString *currentTimeStr = [self convertTimeSecond: time];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    }
}


#pragma mark ReplayControlViewDelegate
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value {
    self.controlView.sliderView.isdragging = YES;
}
// 滑块滑动中
- (void)sliderValueChanged:(float)value {
    if (self.combinePlayer.whitePlayer.timeInfo.timeDuration > 0) {
        Float64 seconds = self.player.timeInfo.timeDuration * value;
        
        CMTime cmTime = CMTimeMakeWithSeconds(seconds, PREFERRED_TIME_SCALE);
        [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
            
        }];
    }
}
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value {
    
    if (self.player.timeInfo.timeDuration == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = self.player.timeInfo.timeDuration * value;
    
    Float64 seconds = currentTime;
    CMTime cmTime = CMTimeMakeWithSeconds(seconds, PREFERRED_TIME_SCALE);
    [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
        
    }];
    
    NSString *currentTimeStr = [self convertTimeSecond: currentTime];
    NSString *totleTimeStr = [self convertTimeSecond: self.player.timeInfo.timeDuration];
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
    self.controlView.sliderView.isdragging = YES;
    
    if(self.player.timeInfo.timeDuration > 0) {
        float currentTime = self.player.timeInfo.timeDuration * value;
        CMTime cmTime = CMTimeMakeWithSeconds(currentTime, PREFERRED_TIME_SCALE);
        WEAK(self)
        [self.combinePlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
            weakself.controlView.sliderView.isdragging = NO;
        }];
//        self.controlView.sliderView.isdragging = NO;
        
//        [self.player seekToScheduleTime:currentTime];
        NSString *currentTimeStr = [self convertTimeSecond: currentTime];
        NSString *totleTimeStr = [self convertTimeSecond: self.player.timeInfo.timeDuration];
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
    
    if(play) {
        self.playBackgroundView.hidden = YES;
        self.playButton.hidden = YES;
        [self.combinePlayer play];
        self.defaultTeacherImage.hidden = YES;
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
        
    } else {
        self.playBackgroundView.hidden = NO;
        self.playButton.hidden = NO;
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
