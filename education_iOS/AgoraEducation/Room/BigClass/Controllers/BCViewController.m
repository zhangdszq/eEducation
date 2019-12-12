//
//  BigClassViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCViewController.h"
#import "BCSegmentedView.h"
#import "EEPageControlView.h"
#import "EEWhiteboardTool.h"
#import "EEChatTextFiled.h"
#import "BCStudentVideoView.h"
#import <WhiteSDK.h>
#import "AgoraHttpRequest.h"
#import "MainViewController.h"
#import "AERTMMessageBody.h"
#import "AERoomMessageModel.h"
#import "EEColorShowView.h"
#import "AERTMMessageBody.h"
#import "AEStudentModel.h"
#import "AETeactherModel.h"
#import "EEMessageView.h"
#import "AEP2pMessageModel.h"

#import "SignalManager.h"

#define kLandscapeViewWidth    223
@interface BCViewController ()<BCSegmentedDelegate,UIViewControllerTransitioningDelegate,WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate,WhiteRoomCallbackDelegate,AEClassRoomProtocol, SignalDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *teacherVideoWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *handupButtonRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteboardToolTopCon; //默认 267
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelTopCon;//默认 267
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteboardViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteboardViewTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteboardViewLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *teacherVideoViewHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studentVideoViewLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studentViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studentViewHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareScreenTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareScreenRightCon;


@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic, weak) UIButton *closeButton;
@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet BCSegmentedView *segmentedView;
@property (nonatomic, assign) NSInteger segmentedIndex;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

@property (nonatomic, strong) NSArray<RolesStudentInfoModel*> *studentList;
@property (nonatomic, strong) AETeactherModel *teacherAttr;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) StudentLinkState linkState;
@property (nonatomic, strong) NSMutableArray *channelAttrs;

@property (nonatomic, assign) NSUInteger linkUserId;
@property (nonatomic, assign) BOOL teacherInRoom;
@property (nonatomic, strong) AgoraRtcVideoCanvas *studentCanvas;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;
@end

@implementation BCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.studentList = [NSArray array];
    
    [self.navigationView updateChannelName:self.channelName];
    [self addNotification];
    [self setUpView];
    [self setWhiteBoardBrushColor];
    [self addTeacherObserver];
    
    SignalManager.shareManager.messageDelegate = self;
    [SignalManager.shareManager joinChannelWithName:self.rtmChannelName completeSuccessBlock:nil completeFailBlock:nil];
    
    [self joinAgoraRtcChannel];
}

- (void)onSignalReceived:(NSNotification *)notification{
    AEP2pMessageModel *messageModel = [notification object];
    
    BOOL audio = SignalManager.shareManager.currentStuModel.audio;
    BOOL video = SignalManager.shareManager.currentStuModel.video;
    
    switch (messageModel.cmd) {
        case RTMp2pTypeMuteAudio:
            
        {
            NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:video audio:NO];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteAudio:
        {
            NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:video audio:YES];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            
            break;
        case RTMp2pTypeMuteVideo:
        {
            NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:NO audio:audio];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteVideo:
        {
            NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:YES audio:audio];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeApply:
            break;
        case RTMp2pTypeReject:
        {
            self.linkState = StudentLinkStateReject;
//            self.handUpButton.enabled = YES;
//            [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
        }
            break;
        case RTMp2pTypeAccept:
        {
            [self teacherAcceptLink];
        }
            break;
        case RTMp2pTypeCancel:
        {
            self.whiteboardTool.hidden = YES;
            self.linkState = StudentLinkStateIdle;
            [self removeStudentVideo];
            [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
        }
            break;
        case RTMp2pTypeMuteChat:
            self.chatTextFiled.contentTextFiled.placeholder = @" 禁言中";
            self.chatTextFiled.contentTextFiled.enabled = NO;
            break;
        case RTMp2pTypeUnMuteChat:
            self.chatTextFiled.contentTextFiled.placeholder = @" 说点什么";
            self.chatTextFiled.contentTextFiled.enabled = YES;
            break;
        default:
            break;
    }
}

- (void)getRtmChannelAttrs{
    
    WEAK(self)
    [SignalManager.shareManager queryGlobalStateWithChannelName:self.rtmChannelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
        
        [weakself updateTeacherStatusWithModel:rolesInfoModel.teactherModel];
        
        weakself.studentList = rolesInfoModel.studentModels;
    }];
}

-(void)updateTeacherStatusWithModel:(AETeactherModel*)model{
 
    if(model != nil){
        [self.teacherAttr modelWithTeactherModel:model];
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = NO;
            self.pageControlView.hidden = NO;
        }
        [self.teactherVideoView updateSpeakerImageWithMuted:!self.teacherAttr.audio];
        self.teactherVideoView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
        [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
    }
}

- (void)setUpView {
    [self addWhiteBoardViewToView:self.whiteboardView];
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    if (duration == UIDeviceOrientationLandscapeLeft || duration == UIDeviceOrientationLandscapeRight) {
        [self stateBarHidden:YES];
        [self landscapeScreenConstraints];
    }else {
        [self stateBarHidden:NO];
        [self verticalScreenConstraints];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;

    [AERTMMessageBody addShadowWithView:self.handUpButton alpha:0.1];
    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    [AERTMMessageBody addShadowWithView:self.tipLabel alpha:0.25];
    self.segmentedView.delegate = self;
    self.studentVideoView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
}

- (void)joinAgoraRtcChannel {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcEngineKit setClientRole:(AgoraClientRoleAudience)];
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit startPreview];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    WEAK(self)
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"join channel success");
        [weakself getRtmChannelAttrs];
        
        NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:weakself.userName video:NO audio:NO];
        [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if ([keyPath isEqualToString:@"uid"]) {
        NSUInteger uid = [change[@"new"] integerValue];
        if (uid > 0 ) {
            self.teacherInRoom = YES;
//            self.teacherUid = [new integerValue];
            self.teactherVideoView.defaultImageView.hidden = YES;
            AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
            canvas.uid = uid;
            canvas.view = self.teactherVideoView.teacherRenderView;
            [self.rtcEngineKit setupRemoteVideo:canvas];
        }
//        else {
//            self.teacherUid = 0;
//        }
    }else if ([keyPath isEqualToString:@"account"]) {
        [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
    }else if ([keyPath isEqualToString:@"link_uid"]) {
        self.linkUserId = [new integerValue];
        if (self.linkUserId > 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", new];
            NSArray<RolesStudentInfoModel *> *filteredArray = [self.studentList filteredArrayUsingPredicate:predicate];
            if(filteredArray.count > 0){
//                AEStudentModel *studentModel = filteredArray.firstObject.studentModel;
                [self.studentVideoView updateVideoImageWithMuted:NO];
                [self.studentVideoView updateAudioImageWithMuted:NO];
                if (self.linkUserId == [self.userId integerValue]) {
                   [self addStudentVideoWithUid:self.linkUserId remoteVideo:NO];
                }else {
                   [self.studentVideoView setButtonEnabled:NO];
                   [self addStudentVideoWithUid:self.linkUserId remoteVideo:YES];
                }
            } else {
                [self removeStudentVideo];
            }
        }else {
            [self removeStudentVideo];
        }
    }

    if (![new isEqualToString:old]) {
        if ([keyPath isEqualToString:@"whiteboard_uid"]) {
            if (change[@"new"]) {
                [self joinWhiteBoardRoomUUID:change[@"new"] disableDevice:true];
            }
        }else if ([keyPath isEqualToString:@"mute_chat"]) {
            if ([change[@"new"] boolValue]) {
                self.chatTextFiled.contentTextFiled.enabled = NO;
                self.chatTextFiled.contentTextFiled.placeholder = @" 禁言中";
            }else {
                self.chatTextFiled.contentTextFiled.enabled = YES;
                self.chatTextFiled.contentTextFiled.placeholder = @" 说点什么";
            }
        }
    }
}

- (void)addStudentVideoWithUid:(NSInteger)uid remoteVideo:(BOOL)remote {
    self.studentVideoView.hidden = NO;
    if (!self.studentCanvas || uid != self.studentCanvas.uid) {
        self.studentVideoView.defaultImageView.hidden = YES;
        self.studentCanvas = [[AgoraRtcVideoCanvas alloc] init];
        self.studentCanvas.uid = uid;
        self.studentCanvas.view = self.studentVideoView.studentRenderView;
        if (remote) {
            [self.rtcEngineKit setupRemoteVideo:self.studentCanvas];
        }else {
            [self.rtcEngineKit setupLocalVideo:self.studentCanvas];
        }
    }
}

- (void)removeStudentVideo {
    [self.rtcEngineKit setClientRole:(AgoraClientRoleAudience)];
    self.studentVideoView.defaultImageView.hidden = NO;
    self.studentVideoView.hidden = YES;
    self.studentCanvas = nil;
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    [self.messageView updateTableView];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self stateBarHidden:NO];
            [self verticalScreenConstraints];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self stateBarHidden:YES];
            [self landscapeScreenConstraints];
        }
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}

- (void)stateBarHidden:(BOOL)hidden {
    self.statusBarHidden = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
    self.isLandscape = hidden; // 横屏隐藏
}

- (IBAction)handUpEvent:(UIButton *)sender {
    
    switch (self.linkState) {
        case StudentLinkStateIdle:
            [self studentApplyLink];
            break;
        case StudentLinkStateAccept:
            [self studentCancelLink];
            break;
        case StudentLinkStateApply:
            [self studentApplyLink];
            break;
        case StudentLinkStateReject:
            [self studentApplyLink];
            break;
        default:
            break;
    }
}

- (void)studentApplyLink {
    WEAK(self)
    NSString *msgText = [AERTMMessageBody studentApplyLink];
    NSString *peerId = self.teacherAttr.uid;
    [SignalManager.shareManager setSignalWithValue:msgText toPeer:peerId completeSuccessBlock:^{
        
        weakself.linkState = StudentLinkStateApply;
//        [weakself.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];
        
    } completeFailBlock:nil];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (weakself.linkState == StudentLinkStateApply) {
//            [weakself studentCancelLink];
//            weakself.handUpButton.enabled = YES;
//            weakself.linkState = StudentLinkStateIdle;
//            [weakself.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
//        }
//    });
}

- (void)studentCancelLink {
    WEAK(self)
//    if (self.segmentedIndex == 0) {
//        self.whiteboardTool.hidden = YES;
//    }
    
    NSString *msgText = [AERTMMessageBody studentCancelLink];
    NSString *peerId = self.teacherAttr.uid;
    [SignalManager.shareManager setSignalWithValue:msgText toPeer:peerId completeSuccessBlock:^{
        
        weakself.linkState = StudentLinkStateIdle;
        [weakself removeStudentVideo];
        
    } completeFailBlock:nil];
}

- (void)teacherAcceptLink {
    WEAK(self)
    
    NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:YES audio:YES];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
        
        [weakself.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
        weakself.linkState = StudentLinkStateAccept;
//        [weakself addStudentVideoWithUid:[weakself.userId integerValue] remoteVideo:NO];
        [weakself.studentVideoView setButtonEnabled:YES];
        [weakself.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];
        
        [weakself.tipLabel setText:[NSString stringWithFormat:@"%@接受了你的连麦申请!",self.teacherAttr.account]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakself.tipLabel.hidden = YES;
        });
        
    } completeFailBlock:nil];
}

- (void)landscapeScreenConstraints {
    BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
    self.pageControlView.hidden = self.teacherInRoom ? NO : YES;
    self.handUpButton.hidden = self.teacherInRoom ? NO : YES;
    self.segmentedView.hidden = YES;
    self.lineView.hidden = NO;
    self.chatTextFiled.hidden = NO;
    self.messageView.hidden = NO;
    self.navigationHeightCon.constant = 30;
    self.navigationView.titleLabelBottomConstraint.constant = 5;
    self.navigationView.closeButtonBottomConstraint.constant = 0;
    self.teacherVideoWidthCon.constant = kLandscapeViewWidth;
    self.handupButtonRightCon.constant = 233;
    self.whiteboardToolTopCon.constant = 10;
    self.messageViewWidthCon.constant = kLandscapeViewWidth;
    self.chatTextFiledWidthCon.constant = kLandscapeViewWidth;
    self.tipLabelTopCon.constant = 10;
    self.messageViewTopCon.constant = 0;
    self.whiteboardViewRightCon.constant = -kLandscapeViewWidth;
    self.shareScreenRightCon.constant = kLandscapeViewWidth;
    self.whiteboardViewTopCon.constant = 0;
    self.shareScreenTopCon.constant = 0;
    self.teacherVideoViewHeightCon.constant = 125;
    self.studentVideoViewLeftCon.constant = 66;
    self.studentViewHeightCon.constant = 85;
    self.studentViewWidthCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    CGFloat boardViewWidth = isIphoneX ? MAX(kScreenHeight, kScreenWidth) - 311 : MAX(kScreenHeight, kScreenWidth) - kLandscapeViewWidth;
    self.boardView.frame = CGRectMake(0, 0,boardViewWidth , MIN(kScreenWidth, kScreenHeight) - 30);
}

- (void)verticalScreenConstraints {
    self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.messageView.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.whiteboardView.hidden = self.segmentedIndex == 0 ? NO : YES;
    self.lineView.hidden = YES;
    self.segmentedView.hidden = NO;
    self.pageControlView.hidden = self.teacherInRoom ? NO : YES;
    self.handUpButton.hidden = self.teacherInRoom ? NO : YES;
    CGFloat navigationBarHeight =  (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? 88 : 64;
    self.navigationHeightCon.constant = navigationBarHeight;
    self.navigationView.titleLabelBottomConstraint.constant = 12;
    self.navigationView.closeButtonBottomConstraint.constant = 7;
    self.teacherVideoWidthCon.constant = kScreenWidth;
    self.handupButtonRightCon.constant = 10;
    self.whiteboardToolTopCon.constant = 267;
    self.messageViewWidthCon.constant = kScreenWidth;
    self.chatTextFiledWidthCon.constant = kScreenWidth;
    self.tipLabelTopCon.constant = 267;
    self.messageViewTopCon.constant = 44;
    self.whiteboardViewRightCon.constant = 0;
    self.shareScreenRightCon.constant = 0;
    self.whiteboardViewTopCon.constant = 257;
    self.shareScreenTopCon.constant = 257;
    self.teacherVideoViewHeightCon.constant = 213;
    self.studentVideoViewLeftCon.constant = kScreenWidth - 100;
    self.studentViewWidthCon.constant = 85;
    self.studentViewHeightCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    self.boardView.frame = CGRectMake(0, 0, MIN(kScreenWidth, kScreenHeight), MAX(kScreenHeight, kScreenWidth) - 257);
}
#pragma mark ---------------------------- Notification ----------------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onSignalReceived:) name:NOTICE_KEY_ON_SIGNAL_RECEIVED object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = (isIphoneX && self.isLandscape) ? kScreenWidth - 44 : kScreenWidth;
        self.textFiledBottomConstraint.constant = bottom;
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textFiledBottomConstraint.constant = 0;
    self.chatTextFiledWidthCon .constant = self.isLandscape ? kLandscapeViewWidth : MIN(kScreenHeight, kScreenWidth);
}

#pragma mark ---------------------------- Delegate ----------------------------
- (void)selectedItemIndex:(NSInteger)index {
    if (self.colorShowView.hidden == NO) {
        self.colorShowView.hidden = YES;
    }
    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.pageControlView.hidden = self.teacherInRoom ? NO: YES;
        self.whiteboardTool.hidden = YES;
        self.handUpButton.hidden = self.teacherInRoom ? NO: YES;
    }else {
        self.segmentedIndex = 1;
        self.messageView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.pageControlView.hidden = YES;
        self.handUpButton.hidden = YES;
        self.whiteboardTool.hidden = YES;
        self.unreadMessageCount = 0;
        [self.segmentedView hiddeBadge];
    }
}

- (void)closeRoom {
    WEAK(self)
    [EEAlertView showAlertWithController:self title:@"是否退出房间?" sureHandler:^(UIAlertAction * _Nullable action) {
        
        if (weakself.linkState == StudentLinkStateAccept) {
            NSString *msgText = [AERTMMessageBody studentCancelLink];
            NSString *peerId = weakself.teacherAttr.uid;
            [SignalManager.shareManager setSignalWithValue:msgText toPeer:peerId completeSuccessBlock:^{
                NSLog(@"退出消息发送成功");
            } completeFailBlock:^{
                NSLog(@"退出消息发送失败");
            }];
        }
        [weakself.rtcEngineKit leaveChannel:nil];
        [weakself.room disconnect:^{
        }];
        [weakself removeTeacherObserver];
        [SignalManager.shareManager leaveChannel];
        
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *content = textField.text;
    if (content.length > 0) {
        [SignalManager.shareManager sendMessageWithValue:content];
        
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (uid == [self.teacherAttr.uid integerValue]) {
    } else if (uid == kWhiteBoardUid && !self.shareScreenCanvas) {
        [self addShareScreenVideoWithUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid == self.teacherAttr.uid.integerValue) {
        self.teacherInRoom = NO;
        self.teactherVideoView.defaultImageView.hidden = NO;
        [self.teactherVideoView updateAndsetTeacherName:@""];
        
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = YES;
            self.pageControlView.hidden = YES;
        }
        [self.teactherVideoView updateSpeakerImageWithMuted:YES];
        self.teactherVideoView.defaultImageView.hidden = NO;
        [self.teactherVideoView updateAndsetTeacherName:@""];
        
    } else if (uid == kWhiteBoardUid) {
        [self removeShareScreen];
    } else {
        if(self.studentCanvas != nil && self.studentCanvas.uid == uid) {
            [self removeStudentVideo];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    if (uid == [self.teacherAttr.uid integerValue]) {
        [self.teactherVideoView updateSpeakerImageWithMuted:muted];
    }else {
        [self.studentVideoView updateAudioImageWithMuted:muted];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    if (uid == [self.teacherAttr.uid integerValue]) {
        self.teactherVideoView.defaultImageView.hidden = !muted;
    }else {
        [self.studentVideoView updateVideoImageWithMuted:muted];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type {
    switch (type) {
        case AgoraNetworkTypeUnknown:
        case AgoraNetworkTypeMobile4G:
        case AgoraNetworkTypeWIFI:
            [self.navigationView updateSignalImageName:@"icon-signal3"];
            break;
        case AgoraNetworkTypeMobile3G:
        case AgoraNetworkTypeMobile2G:
            [self.navigationView updateSignalImageName:@"icon-signal2"];
            break;
        case AgoraNetworkTypeLAN:
        case AgoraNetworkTypeDisconnected:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
        default:
            break;
    }
}

- (void)muteVideoStream:(BOOL)stream {

    [self.rtcEngineKit muteLocalVideoStream:stream];
    BOOL audio = SignalManager.shareManager.currentStuModel.audio;
    
    NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:!stream audio:audio];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
    
    self.studentVideoView.defaultImageView.hidden = stream ? NO : YES;
}

- (void)muteAudioStream:(BOOL)stream {
    
    [self.rtcEngineKit muteLocalAudioStream:stream];
    
    BOOL video = SignalManager.shareManager.currentStuModel.video;
    
    NSString *value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:video audio:!stream];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)dealloc {
    NSLog(@"BCViewController is Dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark SignalDelegate
- (void)onUpdateMessage:(AERoomMessageModel *_Nonnull)roomMessageModel {
    [self.messageView addMessageModel:roomMessageModel];
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}
- (void)onUpdateTeactherAttribute:(AETeactherModel *_Nullable)teactherModel {
    [self updateTeacherStatusWithModel:teactherModel];
}
- (void)onUpdateStudentsAttribute:(NSArray<RolesStudentInfoModel *> *)studentInfoModels {
    self.studentList = studentInfoModels;
}
@end
