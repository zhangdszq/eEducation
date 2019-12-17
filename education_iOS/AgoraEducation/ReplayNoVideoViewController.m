//
//  ReplayNoVideoViewController.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/10.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "ReplayNoVideoViewController.h"
#import <AVKit/AVKit.h>
#import <Whiteboard/Whiteboard.h>
#import "OTOTeacherView.h"
#import "ReplayControlView.h"
#import "AgoraHttpRequest.h"
#import "EduButton.h"
#import "LoadingView.h"

@interface ReplayNoVideoViewController ()<WhiteCommonCallbackDelegate, WhitePlayerEventDelegate, ReplayControlViewDelegate, WhiteRoomCallbackDelegate>

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet ReplayControlView *controlView;

@property (weak, nonatomic) IBOutlet EduButton *backButton;

@property (weak, nonatomic) IBOutlet UIView *playBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet LoadingView *loadingView;

@property (weak, nonatomic) IBOutlet UIView *teacherView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultTeacherImage;

@property (nonatomic, strong) WhiteSDK *whiteSDK;
@property (nonatomic, strong) WhitePlayer *player;

@property (nonatomic, weak) WhiteBoardView *boardView;

@end

@implementation ReplayNoVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initData];
}

- (void)initData {
    
    self.controlView.delegate = self;
  
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
    if(self.endTime.length == 13){
        self.endTime = [self.endTime substringToIndex:10];
    }
    NSInteger iStartTime = self.startTime.integerValue;
    NSInteger iEndTime = self.endTime.integerValue;
    
    playerConfig.beginTimestamp = @(iStartTime);
    playerConfig.duration = @(labs(iEndTime - iStartTime));
    
    [self createReplyWithConfig:playerConfig];
}

- (void)setupView {

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
                       
- (void)createReplyWithConfig:(WhitePlayerConfig *)playerConfig {
        
    WEAK(self)
    [self.whiteSDK createReplayerWithConfig:playerConfig callbacks:self completionHandler:^(BOOL success, WhitePlayer * _Nonnull player, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"创建回放房间失败 error:%@", [error localizedDescription]);
        } else {
            weakself.player = player;
            [player seekToScheduleTime:0];
            
            [weakself.view layoutIfNeeded];
            [weakself.player refreshViewSize];
            NSLog(@"创建回放房间成功");
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc {
    [self.player stop];
}

#pragma mark Click Event
- (IBAction)onWhiteBoardClick:(id)sender {
    self.controlView.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
}

- (IBAction)onBackClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onPlayClick:(id)sender {
    
    [self setPlayViewsVisible:YES];
    [self setLoadingViewVisible:YES];
    [self.player play];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
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

-(NSTimeInterval) timeTotleDuration {
    return self.player.timeInfo.timeDuration;
}

-(void)hideControlView {
    self.controlView.hidden = YES;
}

#pragma mark WhiteCommonCallbackDelegate
/** 当sdk出现未捕获的全局错误时，会在此处对抛出 NSError 对象 */
- (void)throwError:(NSError *)error {
    NSLog(@"创建白板信息==》%@", [error localizedDescription]);
}

#pragma mark WhitePlayerEventDelegate
/** 播放状态切换回调 */
- (void)phaseChanged:(WhitePlayerPhase)phase {
    
    if(phase == WhitePlayerPhaseWaitingFirstFrame || phase == WhitePlayerPhaseBuffering){
        // play的时候显示loading
        if(self.playButton.hidden){
            [self setLoadingViewVisible:YES];
        }
    } else if (phase == WhitePlayerPhasePlaying || phase == WhitePlayerPhasePause) {
        if(self.playButton.hidden){
            [self setLoadingViewVisible:NO];
        }
    } else if(phase == WhitePlayerPhaseEnded) {
        [self.player pause];

        [self.player seekToScheduleTime:0];

        [self setLoadingViewVisible:NO];
        [self setPlayViewsVisible:NO];
    
        self.controlView.sliderView.value = 0;
        NSString *totleTimeStr = [self convertTimeSecond: [self timeTotleDuration]];
        NSString *currentTimeStr = [self convertTimeSecond: 0];
        NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", currentTimeStr, totleTimeStr];
        self.controlView.timeLabel.text = timeStr;
    }
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

#pragma mark ReplayControlViewDelegate
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value {
    self.controlView.sliderView.isdragging = YES;
}
// 滑块滑动中
- (void)sliderValueChanged:(float)value {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if ([self timeTotleDuration] > 0) {
        Float64 seconds = [self timeTotleDuration] * value;
        [self.player seekToScheduleTime:seconds];
    }
}
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value {
    if ([self timeTotleDuration] == 0) {
        self.controlView.sliderView.value = 0;
        return;
    }
    self.controlView.sliderView.value = value;
    float currentTime = [self timeTotleDuration] * value;
    
    Float64 seconds = currentTime;
    [self.player seekToScheduleTime:seconds];
    
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    self.controlView.sliderView.isdragging = YES;
    
    if([self timeTotleDuration] > 0) {
        float currentTime = [self timeTotleDuration] * value;
        [self.player seekToScheduleTime:currentTime];

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
        [self.player play];
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:3];
    } else {
        [self.player pause];
    }
}

@end
