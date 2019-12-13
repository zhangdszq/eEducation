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

#define kLandscapeViewWidth    223
@interface BCViewController ()<BCSegmentedDelegate,UIViewControllerTransitioningDelegate,WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate,AgoraRtmChannelDelegate,WhiteRoomCallbackDelegate,AgoraRtmDelegate,AEClassRoomProtocol>
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

@property (nonatomic, strong) NSMutableDictionary *studentListDict;
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
    [self.navigationView updateChannelName:self.channelName];
    [self addNotification];
    [self setUpView];
    [self setWhiteBoardBrushColor];
    [self addTeacherObserver];
    [self.rtmKit setAgoraRtmDelegate:self];
    self.studentListDict = [NSMutableDictionary dictionary];
    [self joinAgoraRtcChannel];
}

- (void)getRtmChannelAttrs{
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingChannelAttr:attributes];
    }];
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

    [DataTypeManager addShadowWithView:self.handUpButton alpha:0.1];
    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    [DataTypeManager addShadowWithView:self.tipLabel alpha:0.25];
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
        [weakself setChannelAttrsWithVideo:NO audio:NO];
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
            self.teacherUid = [new integerValue];
            self.teactherVideoView.defaultImageView.hidden = YES;
            AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
            canvas.uid = uid;
            canvas.view = self.teactherVideoView.teacherRenderView;
            [self.rtcEngineKit setupRemoteVideo:canvas];
        }else {
            self.teacherUid = 0;
        }
    }else if ([keyPath isEqualToString:@"account"]) {
        [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
    }else if ([keyPath isEqualToString:@"link_uid"]) {
        self.linkUserId = [new integerValue];
        if (self.linkUserId > 0) {
            AEStudentModel *studentModel = [self.studentListDict valueForKeyPath:new];
            [self.studentVideoView updateVideoImageWithMuted:!studentModel.video];
            [self.studentVideoView updateAudioImageWithMuted:!studentModel.audio];
            if (self.linkUserId == [self.userId integerValue]) {
                [self addStudentVideoWithUid:self.linkUserId remoteVideo:NO];
            }else {
                [self.studentVideoView setButtonEnabled:NO];
                [self addStudentVideoWithUid:self.linkUserId remoteVideo:YES];
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
        self.studentCanvas.view = self.studentVideoView.studentRenderView;
        if (remote) {
            self.studentCanvas.uid = uid;
            [self.rtcEngineKit setupRemoteVideo:self.studentCanvas];
        }else {
            self.studentCanvas.uid = 0;
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
            [self.studentVideoView updateVideoImageWithMuted:NO];
            [self.studentVideoView updateAudioImageWithMuted:NO];
            break;
        default:
            break;
    }
}

- (void)studentApplyLink {
    WEAK(self)
    [self.rtmKit sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody studentApplyLink]] toPeer:self.teacherAttr.uid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            weakself.linkState = StudentLinkStateApply;
            [weakself.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakself.linkState == StudentLinkStateApply) {
            [weakself studentCancelLink];
            weakself.handUpButton.enabled = YES;
            weakself.linkState = StudentLinkStateIdle;
            [weakself.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
        }
    });
}

- (void)studentCancelLink {
    WEAK(self)
    if (self.segmentedIndex == 0) {
        self.whiteboardTool.hidden = YES;
    }
    [self.rtmKit sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody studentCancelLink]] toPeer:self.teacherAttr.uid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            weakself.linkState = StudentLinkStateIdle;
            [weakself removeStudentVideo];
        }
    }];
}

- (void)teacherAcceptLink {
    [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    self.linkState = StudentLinkStateAccept;
    [self addStudentVideoWithUid:[self.userId integerValue] remoteVideo:NO];
    [self.studentVideoView setButtonEnabled:YES];
    [self.tipLabel setText:[NSString stringWithFormat:@"%@接受了你的连麦申请!",self.teacherAttr.account]];
    [self setChannelAttrsWithVideo:YES audio:YES];
    WEAK(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.tipLabel.hidden = YES;
    });
    self.handUpButton.enabled = YES;
}
- (void)parsingChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    if (attributes.count > 0) {
        for (AgoraRtmChannelAttribute *channelAttr in attributes) {
            NSDictionary *valueDict =   [DataTypeManager dictionaryWithJsonString:channelAttr.value];
            if ([channelAttr.key isEqualToString:@"teacher"]) {
                if (!self.teacherAttr) {
                    self.teacherAttr = [[AETeactherModel alloc] init];
                }
                [self.teacherAttr modelWithDict:valueDict];
                if (self.segmentedIndex == 0) {
                    self.handUpButton.hidden = NO;
                    self.pageControlView.hidden = NO;
                }
                [self.teactherVideoView updateSpeakerImageWithMuted:!self.teacherAttr.audio];
                self.teactherVideoView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
                [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
            }else {
                AEStudentModel *studentAttr = [AEStudentModel yy_modelWithJSON:valueDict];
                studentAttr.userId = channelAttr.key;
                [self.studentListDict setValue:studentAttr forKey:channelAttr.key];
            }
        }
    }
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
        self.pageControlView.hidden = self.teacherAttr ? NO: YES;
        self.handUpButton.hidden = NO;
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
            [weakself.rtmKit sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody studentCancelLink]] toPeer:weakself.teacherAttr.uid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
                NSLog(@"退出消息发送成功与否--- %ld",errorCode);
            }];
        }
        [weakself.rtcEngineKit leaveChannel:nil];
        [weakself.room disconnect:^{
        }];
        [weakself removeTeacherObserver];
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [weakself.rtmKit deleteChannel:weakself.channelName AttributesByKeys:@[weakself.userId] Options:options completion:nil];
        [weakself.rtmChannel leaveWithCompletion:nil];
        [weakself dismissViewControllerAnimated:NO completion:nil];
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
    WEAK(self)
    __block NSString *content = textField.text;
    if (content.length > 0) {
        [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody sendP2PMessageWithName:self.userName content:content]] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
              if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
                  AERoomMessageModel *messageModel = [[AERoomMessageModel alloc] init];
                  messageModel.content = content;
                  messageModel.account = weakself.userName;
                  messageModel.isSelfSend = YES;
                  [weakself.messageView addMessageModel:messageModel];
              }
        }];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (uid == [self.teacherAttr.uid integerValue]) {
    }else if (uid == kWhiteBoardUid && !self.shareScreenCanvas) {
        [self addShareScreenVideoWithUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid  == self.teacherUid) {
        self.teacherInRoom = NO;
        self.teactherVideoView.defaultImageView.hidden = NO;
        [self.teactherVideoView updateAndsetTeacherName:@""];
    }else if (uid == kWhiteBoardUid) {
        [self removeShareScreen];
    }else {
        [self removeStudentVideo];
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

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    NSDictionary *dict =  [DataTypeManager dictionaryWithJsonString:message.text];
    AERoomMessageModel *messageModel = [AERoomMessageModel yy_modelWithDictionary:dict];
    messageModel.isSelfSend = NO;
    [self.messageView addMessageModel:messageModel];
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingChannelAttr:attributes];
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    if ([peerId isEqualToString:self.teacherAttr.uid]) {
        NSDictionary *dict = [DataTypeManager dictionaryWithJsonString:message.text];
        AEP2pMessageModel *model = [AEP2pMessageModel yy_modelWithDictionary:dict];
        switch (model.cmd) {
            case RTMp2pTypeMuteAudio:
                break;
            case RTMp2pTypeUnMuteAudio:
                break;
            case RTMp2pTypeMuteVideo:
                break;
            case RTMp2pTypeUnMuteVideo:
                break;
            case RTMp2pTypeApply:
                break;
            case RTMp2pTypeReject:
            {
                self.linkState = StudentLinkStateReject;
                self.handUpButton.enabled = YES;
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
}

- (void)muteVideoStream:(BOOL)stream {
    AEStudentModel *attrs =  [self.studentListDict objectForKey:self.userId];
    [self setChannelAttrsWithVideo:!attrs.video audio:attrs.audio];
    [self.rtcEngineKit muteLocalVideoStream:attrs.video];
    self.studentVideoView.defaultImageView.hidden = stream ? NO : YES;
}

- (void)muteAudioStream:(BOOL)stream {
    AEStudentModel *attrs =  [self.studentListDict objectForKey:self.userId];
    [self setChannelAttrsWithVideo:attrs.video audio:!attrs.audio];
    [self.rtcEngineKit muteLocalAudioStream:attrs.audio];
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)dealloc {
    NSLog(@"BCViewController is Dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
