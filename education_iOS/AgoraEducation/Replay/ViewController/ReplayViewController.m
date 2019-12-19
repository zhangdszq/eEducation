//
//  ReplayNoVideoViewController.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/10.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "ReplayViewController.h"
#import <AVKit/AVKit.h>

#import "EducationManager.h"

#import "ReplayControlView.h"
#import "AgoraHttpRequest.h"
#import "EduButton.h"
#import "LoadingView.h"


@interface ReplayViewController ()<ReplayControlViewDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;
@property (weak, nonatomic) IBOutlet EduButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet LoadingView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;

@property (nonatomic, strong) EducationManager *educationManager;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, weak) WhiteVideoView *videoView;

// can seek when has buffer for m3u8 video
@property (nonatomic, assign) BOOL canSeek;

@end

@implementation ReplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    for video test
//    self.videoPath = @"https://white-pan.oss-cn-shanghai.aliyuncs.com/101/oceans.mp4";

    [self setupView];
    [self initData];
    [self setupWhiteBoard];
}

- (void)initData {
    
    self.canSeek = NO;
    if(self.videoPath == nil || self.videoPath.length == 0) {
        self.canSeek = YES;
    }
    self.controlView.delegate = self;
    self.educationManager = [[EducationManager alloc] init];
}

- (void)setupWhiteBoard {
    
    // init white sdk
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];

    if(self.videoPath == nil || self.videoPath.length == 0) {
        
        ReplayerModel *replayerModel = [ReplayerModel new];
        replayerModel.uuid = self.roomid;
        replayerModel.videoPath = nil;
        replayerModel.startTime = self.startTime;
        replayerModel.endTime = self.endTime;
        [self createWhiteReplayerWithModel:replayerModel];
        
    } else {
        __block NSTimeInterval time = 0;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.videoPath]];
            time = CMTimeGetSeconds([asset duration]);

            dispatch_async(dispatch_get_main_queue(), ^{
                
                ReplayerModel *replayerModel = [ReplayerModel new];
                replayerModel.uuid = self.roomid;
                replayerModel.videoPath = self.videoPath;
                replayerModel.startTime = self.startTime;
                if(self.startTime.length == 13) {
                    replayerModel.endTime = [NSString stringWithFormat:@"%ld", self.startTime.integerValue + (long)(time * 1000)];
                } else {
                    replayerModel.endTime = [NSString stringWithFormat:@"%ld", self.startTime.integerValue + (long)time];
                }
                [self createWhiteReplayerWithModel:replayerModel];
            });
        });
    }
}

- (void)createWhiteReplayerWithModel:(ReplayerModel *)replayerModel {
    
    WEAK(self)
    
    // create white replayer
    [self.educationManager createWhiteReplayerWithModel:replayerModel completeSuccessBlock:^(WhitePlayer * _Nullable whitePlayer, AVPlayer * _Nullable avPlayer) {

        if(weakself.videoPath != nil && weakself.videoPath.length > 0 && avPlayer != nil) {
            [weakself.videoView setAVPlayer: avPlayer];
        }
        
        [weakself.view layoutIfNeeded];
        [weakself.educationManager refreshWhiteViewSize];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)setupView {
    
    if(self.videoPath != nil && self.videoPath.length > 0) {
        WhiteVideoView *videoView = [[WhiteVideoView alloc] initWithFrame:self.teacherView.bounds];
        videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.teacherView addSubview:videoView];
        self.videoView = videoView;
    }

    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.whiteboardBaseView insertSubview:boardView belowSubview:self.playBackgroundView];
    self.boardView = boardView;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
    
    self.backButton.layer.cornerRadius = 6;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc {
    [self.educationManager stopWhite];
}

#pragma mark Click Event
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onPlayClick:(id)sender {
    
    [self setPlayViewsVisible:YES];
    [self.educationManager playWhite];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setLoadingViewVisible:(BOOL)onPlay {
    onPlay ? [self.loadingView showLoading] : [self.loadingView hiddenLoading];
    onPlay ? (self.playBackgroundView.hidden = NO) : (self.playBackgroundView.hidden = YES);
}

-(void)setPlayViewsVisible:(BOOL)onPlay {
    self.playBackgroundView.hidden = onPlay;
    self.playButton.hidden = onPlay;
    self.controlView.playOrPauseBtn.selected = onPlay;
}

-(void)hideControlView {
    self.controlView.hidden = YES;
}

- (void)seekToTimeInterval:(NSTimeInterval)seconds completionHandler:(void (^)(BOOL finished))completionHandler {
    CMTime cmTime = CMTimeMakeWithSeconds(seconds, 100);
    [self.educationManager seekWhiteToTime:cmTime completionHandler:completionHandler];
}

- (NSTimeInterval)timeTotleDuration {
    return [self.educationManager whiteTotleTimeDuration];
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
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    if ([self timeTotleDuration] > 0) {
        Float64 seconds = [self timeTotleDuration] * value;
        [self seekToTimeInterval:seconds completionHandler:^(BOOL finished) {
        }];
    }
}
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value {
    if(!self.canSeek) {
        self.controlView.sliderView.isdragging = NO;
        return;
    }
    
    if ([self timeTotleDuration] == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = [self timeTotleDuration] * value;
    
    WEAK(self)
    [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
        if(finished) {
            NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
            NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
            NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
            weakself.controlView.timeLabel.text = timeStr;
        }
        weakself.controlView.sliderView.isdragging = NO;
    }];
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
        self.controlView.sliderView.isdragging = NO;
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    self.controlView.sliderView.isdragging = YES;
    
    if([self timeTotleDuration] > 0) {
        float currentTime = [self timeTotleDuration] * value;
        WEAK(self)
        [self seekToTimeInterval:currentTime completionHandler:^(BOOL finished) {
            if(finished) {
                NSString *currentTimeStr = [weakself convertTimeSecond: currentTime];
                NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
                NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
                weakself.controlView.timeLabel.text = timeStr;
            }
            weakself.controlView.sliderView.isdragging = NO;
        }];
    } else {
        self.controlView.sliderView.value = 0;
        self.controlView.sliderView.isdragging = NO;
    }
}
// 播放暂停按钮点击
- (void)playPauseButtonClicked:(BOOL)play {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    [self setPlayViewsVisible:play];
    
    if(play) {
        [self.educationManager playWhite];
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
    } else {
        [self.educationManager pauseWhite];
    }
}

#pragma mark WhitePlayDelegate
/** 进度时间变化 */
- (void)whitePlayerTimeChanged:(NSTimeInterval)time {
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

/**
 进入缓冲状态，WhitePlayer，NativePlayer 任一进入缓冲，都会回调。
 */
- (void)whitePlayerStartBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:YES];
    }
}

/**
 结束缓冲状态，WhitePlayer，NativePlayer 全部完成缓冲，才会回调。
 */
- (void)whitePlayerEndBuffering {
    if(self.playButton.hidden){
        [self setLoadingViewVisible:NO];
    }
    self.canSeek = YES;
}

/**
 播放结束
 */
- (void)whitePlayerDidFinish {
    [self.educationManager pauseWhite];

    WEAK(self)
    [self seekToTimeInterval:0 completionHandler:^(BOOL finished) {
        if(finished) {
            [weakself setLoadingViewVisible:NO];
            [weakself setPlayViewsVisible:NO];
        
            weakself.controlView.sliderView.value = 0;
            NSString *totleTimeStr = [weakself convertTimeSecond: [weakself timeTotleDuration]];
            NSString *currentTimeStr = [weakself convertTimeSecond: 0];
            NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
            weakself.controlView.timeLabel.text = timeStr;
        }
    }];
}

/**
 播放失败

 @param error 错误原因
 */
- (void)whitePlayerError:(NSError * _Nullable)error {
    NSLog(@"ReplayVideoViewController Stopped Err:%@", error);
}


@end
