//
//  BigClassViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCViewController.h"
#import "EESegmentedView.h"
#import "EEPageControlView.h"
#import "EEChatContentTableView.h"
#import "EEWhiteboardTool.h"
#import "EEChatTextFiled.h"
#import "EEStudentVideoView.h"
#import <WhiteSDK.h>
#import "AgoraHttpRequest.h"
#import "MainViewController.h"
#import "EEPublicMethodsManager.h"
#import "RoomMessageModel.h"
#import "EEColorShowView.h"
#import "EEPublicMethodsManager.h"
#import "EEBCStudentAttrs.h"
#import "EEBCTeactherAttrs.h"
#import "EEMessageView.h"


@interface BCViewController ()<EESegmentedDelegate,EEWhiteboardToolDelegate,EEPageControlDelegate,UIViewControllerTransitioningDelegate,WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate,AgoraRtmDelegate,UITextFieldDelegate,AgoraRtmChannelDelegate,WhiteRoomCallbackDelegate,StudentViewDelegate>
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

@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic, weak) UIButton *closeButton;
@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet EEStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet EESegmentedView *segmentedView;
@property (nonatomic, assign) NSInteger segmentedIndex;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *windowShareView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;
@property (nonatomic, strong) AgoraRtcVideoCanvas *teacherCanvas;
@property (nonatomic, strong) AgoraRtcVideoCanvas *studentCanvas;
@property (nonatomic, strong) NSMutableDictionary *studentListDict;
@property (nonatomic, strong) EEBCTeactherAttrs *teacherAttr;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (nonatomic, strong) WhiteBoardView *boardView;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong, nullable) WhiteRoom *room;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
@property (nonatomic, strong) UIColor *pencilColor;
@property (nonatomic, strong) WhiteMemberState *memberState;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) StudentLinkState linkState;
@property (nonatomic, strong) AgoraRtmChannel *rtmChannel;
@property (nonatomic, strong) NSMutableArray *channelAttrs;

@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) AgoraRtmKit *rtmKit;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;
@property (nonatomic, copy) NSString *linkUserId;
@property (nonatomic, assign) BOOL teacherInRoom;
@end

@implementation BCViewController
#pragma mark ------------------------ SET/GET -----------------------------
- (void)setParams:(NSDictionary *)params {
    _params = params;
    if (params[@"rtmKit"]) {
        self.rtmKit = params[@"rtmKit"];
        self.channelName = params[@"channelName"];
        self.userName = params[@"userName"];
        self.userId = params[@"userId"];
        self.rtmChannelName = params[@"rtmChannelName"];
        NSLog(@"rtmChannelName----- %@",_rtmChannelName);
    }
}

- (void)setChannelAttrsWithVideo:(BOOL)video audio:(BOOL)audio {
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.userId;
    setAttr.value = [EEPublicMethodsManager setAndUpdateStudentChannelAttrsWithName:self.userName video:NO audio:NO];
    AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
    options.enableNotificationToChannelMembers = YES;
    NSArray *attrArray = [NSArray arrayWithObjects:setAttr, nil];
    [self.rtmKit addOrUpdateChannel:self.rtmChannelName Attributes:attrArray Options:options completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
       if (errorCode == AgoraRtmAttributeOperationErrorOk) {
           NSLog(@"更新成功");
       }else {
           NSLog(@"更新失败");
       }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationView updateChannelName:self.channelName];
    [self addNotification];
    [self setUpView];

    self.studentListDict = [NSMutableDictionary dictionary];

    [self.rtmKit setAgoraRtmDelegate:self];

    [self joinAgoraRtcChannel];
    [self joinRtmChannel];
    [self setChannelAttrsWithVideo:NO audio:NO];
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    if (duration == UIDeviceOrientationLandscapeLeft || duration == UIDeviceOrientationLandscapeRight) {
        [self landscapeConstraints];
    }else {
        [self verticalScreenConstraints];
    }
}

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textFiledBottomConstraint.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textFiledBottomConstraint.constant = 0;
}

#pragma mark -----------------------------------Private Method ---------------------------
- (void)setUpView {

    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardView addSubview:self.boardView];

    [self.navigationView.closeButton addTarget:self action:@selector(closeRoom:) forControlEvents:(UIControlEventTouchUpInside)];
    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;

    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;
    [EEPublicMethodsManager addShadowWithView:self.handUpButton alpha:0.1];

    self.tipLabel.layer.backgroundColor = RCColorWithValue(0x000000, 0.7).CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    [EEPublicMethodsManager addShadowWithView:self.tipLabel alpha:0.25];

    self.segmentedView.delegate = self;
    self.whiteboardTool.delegate = self;
    self.pageControlView.delegate = self;
    self.studentVideoView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    WEAK(self)
    self.colorShowView.selectColor = ^(NSString *colorString) {
        NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        weakself.memberState.strokeColor = colorArray;
        [weakself.room setMemberState:weakself.memberState];
    };
}

- (void)joinAgoraRtcChannel {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcEngineKit setClientRole:(AgoraClientRoleAudience)];
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit startPreview];
    [self.rtcEngineKit enableAudioVolumeIndication:300 smooth:3 report_vad:NO];
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.channelName info:nil uid:[self.userId integerValue] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
    }];
}

- (void)joinRtmChannel {
    self.rtmChannel  =  [self.rtmKit createChannelWithId:self.rtmChannelName delegate:self];
    [self.rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if (errorCode == AgoraRtmJoinChannelErrorOk) {
            NSLog(@"RTM - 频道加入成功");
        }
    }];
}

- (void)joinWhiteBoardRoomUUID:(NSString *)uuid {
     self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
        WEAK(self)
    [EEPublicMethodsManager parseWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        [weakself.sdk joinRoomWithConfig:roomConfig callbacks:nil completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
            weakself.room = room;
            [weakself getWhiteboardSceneInfo];
            [weakself.room disableDeviceInputs:YES];
        }];
    } failure:^(NSString * _Nonnull msg) {
        NSLog(@"获取失败 %@",msg);
    }];
}
- (void)getWhiteboardSceneInfo {
    WEAK(self)
    [self.room getSceneStateWithResult:^(WhiteSceneState * _Nonnull state) {
        weakself.scenes = [NSArray arrayWithArray:state.scenes];
        weakself.sceneDirectory = @"/";
        weakself.sceneIndex = 1;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",weakself.sceneIndex,weakself.scenes.count]];
   }];
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    [self.messageView updateTableView];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            [self verticalScreenConstraints];
        break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self landscapeConstraints];
        }
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}
- (void)landscapeConstraints {

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
    self.teacherVideoWidthCon.constant = 223;
    self.handupButtonRightCon.constant = 233;
    self.whiteboardToolTopCon.constant = 10;
    self.messageViewWidthCon.constant = 223;
    self.chatTextFiledWidthCon.constant = 223;
    self.tipLabelTopCon.constant = 10;
    self.messageViewTopCon.constant = 0;
    self.whiteboardViewRightCon.constant = isIphoneX ? -267 : -223;
    self.whiteboardViewTopCon.constant = 0;
    self.teacherVideoViewHeightCon.constant = 125;
    self.studentVideoViewLeftCon.constant = 66;
    self.studentViewHeightCon.constant = 85;
    self.studentViewWidthCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    CGFloat boardViewWidth = isIphoneX ? MAX(kScreenHeight, kScreenWidth) - 301 : MAX(kScreenHeight, kScreenWidth) - 223;
    self.boardView.frame = CGRectMake(0, 0,boardViewWidth , MIN(kScreenWidth, kScreenHeight) - 40);
}

- (void)verticalScreenConstraints {
    self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
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
    self.whiteboardViewTopCon.constant = 257;
    self.teacherVideoViewHeightCon.constant = 213;
    self.studentVideoViewLeftCon.constant = kScreenWidth - 100;
    self.studentViewWidthCon.constant = 85;
    self.studentViewHeightCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    self.boardView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 257);
}

- (void)closeRoom:(UIButton *)sender {
    WEAK(self)
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"是否退出房间" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [weakself.rtcEngineKit leaveChannel:nil];
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [weakself.rtmKit deleteChannel:weakself.channelName AttributesByKeys:@[weakself.userId] Options:options completion:nil];
        [weakself.rtmChannel leaveWithCompletion:nil];
        [weakself dismissViewControllerAnimated:NO completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:confirmAction];
    [self presentViewController:alertVC animated:NO completion:nil];
}

- (IBAction)handUpEvent:(UIButton *)sender {
    WEAK(self)
    [self.rtmKit sendMessage:[[AgoraRtmMessage alloc] initWithText:[EEPublicMethodsManager studentApplyLink]] toPeer:self.teacherAttr.uid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            weakself.linkState = StudentLinkStateApply;
            [sender setBackgroundImage:[UIImage imageNamed:@"icon-handup x"] forState:(UIControlStateNormal)];
        }
    }];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakself.linkState == StudentLinkStateApply) {
            weakself.handUpButton.enabled = YES;
            weakself.linkState = StudentLinkStateTimeout;
            [sender setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
        }
    });

    if (self.linkState == StudentLinkStateAccept) {
        [self.rtcEngineKit setClientRole:(AgoraClientRoleAudience)];
        self.studentCanvas.view = nil;
        self.studentCanvas.uid = [self.userId integerValue];
        [self.rtcEngineKit setupLocalVideo:self.studentCanvas];
        [self.studentVideoView updateAudioImageWithMuteState:NO];
        [self.studentVideoView updateVideoImageWithMuteState:NO];
        self.studentVideoView.hidden = YES;
    }
}

- (void)parsingTheChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    if (attributes.count > 0) {
        for (AgoraRtmChannelAttribute *channelAttr in attributes) {
           NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
           if ([channelAttr.key isEqualToString:@"teacher"]) {
               self.teacherAttr = [EEBCTeactherAttrs yy_modelWithDictionary:valueDict];
               self.teacherInRoom = YES;
               [self joinWhiteBoardRoomUUID:self.teacherAttr.whiteboard_uid];
           }else {
               EEBCStudentAttrs *studentAttr = [EEBCStudentAttrs yy_modelWithJSON:valueDict];
               studentAttr.userId = channelAttr.key;
               [self.studentListDict setValue:studentAttr forKey:channelAttr.key];
           }
        }
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    WEAK(self)
    __block NSString *content = textField.text;
    [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:textField.text] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            messageModel.content = content;
            messageModel.name = weakself.userName;
            messageModel.isSelfSend = YES;
            [weakself.messageView addMessageModel:messageModel];
        }
    }];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

#pragma mark --------------------- Segment Delegate -------------------
- (void)selectedItemIndex:(NSInteger)index {
    if (self.colorShowView.hidden == NO) {
        self.colorShowView.hidden = YES;
    }
    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.pageControlView.hidden = self.teacherInRoom ? NO: YES;
        self.handUpButton.hidden = NO;
        self.whiteboardTool.hidden = self.linkState == StudentLinkStateApply ? NO : YES;
        self.whiteboardTool.hidden = self.teacherInRoom ? NO: YES;
        self.handUpButton.hidden = self.teacherInRoom ? NO: YES;
    }else {
        self.segmentedIndex = 0;
        self.messageView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.pageControlView.hidden = YES;
        self.handUpButton.hidden = YES;
        self.whiteboardTool.hidden = YES;
        self.unreadMessageCount = 0;
        [self.segmentedView hiddeBadge];
    }
}

#pragma mark --------------------- WhiteBoard Tool Delegate -------------------
- (void)selectWhiteboardToolIndex:(NSInteger)index {

   self.memberState = [[WhiteMemberState alloc] init];
    switch (index) {
        case 0:
            self.memberState.currentApplianceName = ApplianceSelector;
            [self.room setMemberState:self.memberState];
            break;
        case 1:
            self.memberState.currentApplianceName = AppliancePencil;
            [self.room setMemberState:self.memberState];
        break;
        case 2:
            self.memberState.currentApplianceName = ApplianceText;
            [self.room setMemberState:self.memberState];
        break;
        case 3:
            self.memberState.currentApplianceName = ApplianceEraser;
            [self.room setMemberState:self.memberState];
        break;

        default:
            break;
    }
    if (index == 4) {
         self.colorShowView.hidden = NO;
    }else {
        if (self.colorShowView.hidden == NO) {
            self.colorShowView.hidden = YES;
        }
    }
}

#pragma mark ----------------------------------- PageControl Delegate ---------------------------
- (void)previousPage {
    if (self.sceneIndex > 1) {
        self.sceneIndex = self.sceneIndex -1;
       [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
       [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.scenes.count) {
        self.sceneIndex = self.sceneIndex + 1;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)lastPage {
    self.sceneIndex = self.scenes.count;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex-1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
}

- (void)firstPage {
    self.sceneIndex = 1;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex-1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
}

#pragma mark --------------------- RTC Delegate -------------------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    if (uid == [self.teacherAttr.uid integerValue]) {
        self.teactherVideoView.defaultImageView.hidden = NO;
        self.teacherCanvas = [[AgoraRtcVideoCanvas alloc] init];
        self.teacherCanvas.uid = uid;
        self.teacherCanvas.view = self.teactherVideoView.teacherRenderView;
        [self.rtcEngineKit setupRemoteVideo:self.teacherCanvas];
    }else {
        self.studentVideoView.hidden = NO;
        [self.studentVideoView setButtonEnabled:NO];
        self.studentCanvas = [[AgoraRtcVideoCanvas alloc] init];
        self.studentCanvas.uid = uid;
        self.studentCanvas.view = self.studentVideoView.studentRenderView;
        [self.rtcEngineKit setupRemoteVideo:self.studentCanvas];
        self.linkUserId = [NSString stringWithFormat:@"%ld",uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (uid != [self.teacherAttr.uid integerValue]) {
        EEBCStudentAttrs *studentAttrs = [self.studentListDict objectForKey:@(uid)];
        [self.studentVideoView updateVideoImageWithMuteState:studentAttrs.video];
        [self.studentVideoView updateAudioImageWithMuteState:studentAttrs.audio];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid == [self.teacherAttr.uid integerValue]) {
        self.teacherCanvas = nil;
    }else {
        self.studentCanvas = nil;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    [self.studentVideoView updateVideoImageWithMuteState:muted];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    [self.studentVideoView updateVideoImageWithMuteState:muted];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo *> *)speakers totalVolume:(NSInteger)totalVolume {
    if (speakers.count > 0) {
        for (AgoraRtcAudioVolumeInfo *info in speakers) {
            if (info.uid == [self.teacherAttr.uid integerValue]) {
                NSArray *imageArray = @[@"eeSpeaker1",@"eeSpeaker2",@"eeSpeaker3"];
                [self.teactherVideoView.speakerImage setAnimationImages:imageArray];
                [self.teactherVideoView.speakerImage setAnimationRepeatCount:0];
                [self.teactherVideoView.speakerImage setAnimationDuration:3.0f];
                [self.teactherVideoView.speakerImage startAnimating];
            }
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type {
    switch (type) {
        case AgoraNetworkTypeUnknown:
        case AgoraNetworkTypeMobile4G:
        case AgoraNetworkTypeWIFI:
            [self.navigationView updateSignalImageName:@"icon-Wifi-signal_good"];
            break;
        case AgoraNetworkTypeMobile3G:
        case AgoraNetworkTypeMobile2G:
             [self.navigationView updateSignalImageName:@"icon-Wifi-signal_medium"];
            break;
        case AgoraNetworkTypeLAN:
        case AgoraNetworkTypeDisconnected:
            [self.navigationView updateSignalImageName:@"icon-Wifi-signal_bad"];
            break;
        default:
            break;
    }
}
#pragma mark --------------------- RTM Delegate -------------------
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    NSString *userName = nil;
    if ([member.userId isEqualToString: self.teacherAttr.uid]) {
        userName = self.teacherAttr.account;
    }else {
        EEBCStudentAttrs *attrs = self.studentListDict[member.userId];
        userName = attrs.account;
    }
    RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
    messageModel.content = message.text;
    messageModel.name = userName;
    messageModel.isSelfSend = NO;
    [self.messageView addMessageModel:messageModel];
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    if ([peerId isEqualToString:self.teacherAttr.uid]) {
        NSDictionary *dict = [JsonAndStringConversions dictionaryWithJsonString:message.text];
        if ([dict[@"type"] isEqualToString:@"mute"]) {
            if ([dict[@"resource"] isEqualToString:@"video"]) {
                [self.rtcEngineKit muteLocalVideoStream:YES];
                [self.studentVideoView updateVideoImageWithMuteState:YES];
            }else if([dict[@"resource"] isEqualToString:@"audio"]) {
                [self.rtcEngineKit muteLocalAudioStream:YES];
                [self.studentVideoView updateAudioImageWithMuteState:YES];
            }
        }else if([dict[@"type"] isEqualToString:@"unmute"]){
            if ([dict[@"resource"] isEqualToString:@"video"]) {
               [self.rtcEngineKit muteLocalVideoStream:NO];
                [self.studentVideoView updateVideoImageWithMuteState:NO];
            }else if([dict[@"resource"] isEqualToString:@"audio"]) {
               [self.rtcEngineKit muteLocalAudioStream:NO];
               [self.studentVideoView updateAudioImageWithMuteState:NO];
            }
        }else if ([dict[@"type"] isEqualToString:@"accept"]) {
            [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
            self.linkState = StudentLinkStateAccept;
            self.studentCanvas = [[AgoraRtcVideoCanvas alloc] init];
            self.studentCanvas.uid = [self.userId integerValue];
            self.studentCanvas.view = self.studentVideoView.studentRenderView;
            [self.rtcEngineKit setupLocalVideo:self.studentCanvas];
            self.studentVideoView.hidden = NO;
            [self.studentVideoView setButtonEnabled:YES];
            [self.tipLabel setText:[NSString stringWithFormat:@"%@接受了你的连麦申请!",self.teacherAttr.account]];
            [self setChannelAttrsWithVideo:YES audio:YES];
            WEAK(self)
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               weakself.tipLabel.hidden = YES;
           });
            self.handUpButton.enabled = YES;
        }else if ([dict[@"type"] isEqualToString:@"reject"]) {
            [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
            self.linkState = StudentLinkStateReject;
            self.handUpButton.enabled = YES;
        }
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingTheChannelAttr:attributes];
}

#pragma mark ------------------------- whiteboard Delegate ---------------------------
- (void)fireRoomStateChanged:(WhiteRoomState *)modifyState {
    if (modifyState.sceneState && modifyState.sceneState.scenes.count > self.scenes.count) {
        self.scenes = [NSArray arrayWithArray:modifyState.sceneState.scenes];
        self.sceneDirectory = @"/";
        self.sceneIndex = self.sceneIndex+1;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex - 1].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.scenes.count,self.scenes.count]];
    }
}
- (void)clickMuteVideoButton {
    EEBCStudentAttrs *attrs =  [self.studentListDict objectForKey:self.userId];
    [self setChannelAttrsWithVideo:!attrs.video audio:attrs.audio];
    [self.studentVideoView updateVideoImageWithMuteState:!attrs.video];
}

- (void)clickMuteAudioButton {
    EEBCStudentAttrs *attrs =  [self.studentListDict objectForKey:self.userId];
    [self setChannelAttrsWithVideo:attrs.video audio:!attrs.audio];
    [self.studentVideoView updateAudioImageWithMuteState:!attrs.audio];
}

#pragma mark  ------------------------- System methods --------------------------------
- (void)dealloc {
    NSLog(@"BCViewController is Dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}
@end

