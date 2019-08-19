//
//  RoomViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "RoomViewController.h"
#import <White-SDK-iOS/WhiteSDK.h>
#import "WhiteBoardToolControl.h"
#import "RoomManageView.h"
#import "MemberListView.h"
#import "MessageListView.h"
#import "StudentVideoListView.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
#import "ClassRoomDataManager.h"
#import "RoomMessageModel.h"
#import "AgoraAlertViewController.h"
#import "RoomChatTextField.h"

@interface RoomViewController ()<WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate,WhiteRoomCallbackDelegate,UITextFieldDelegate,ClassRoomDataManagerDelegate>
@property (nonatomic, strong) AgoraRtcEngineKit *agoraEngineKit;
@property (nonatomic, strong) WhiteSDK *writeSDK;
@property (nonatomic, strong) WhiteRoom *whiteRoom;
@property (nonatomic, strong) WhiteBoardView *whiteBoardView;
@property (weak, nonatomic) IBOutlet UIView *baseWhiteBoardView;
@property (weak, nonatomic) IBOutlet UIImageView *teactherDefaultImage;

@property (weak, nonatomic) IBOutlet UIView *teactherVideoView;
@property (weak, nonatomic) IBOutlet UILabel *teactherNameLabel;
@property (weak, nonatomic) IBOutlet RoomChatTextField *chatTextField;
@property (weak, nonatomic) IBOutlet UIView *chatTextBaseView;

@property (weak, nonatomic) IBOutlet WhiteBoardToolControl *whiteBoardTool;
@property (weak, nonatomic) IBOutlet UIButton *leaveRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *whiteBoardControlSizeButton;
@property (weak, nonatomic) IBOutlet RoomManageView *roomManagerView;
@property (weak, nonatomic) IBOutlet MemberListView *memberListView;
@property (weak, nonatomic) IBOutlet MessageListView *messageListView;
@property (weak, nonatomic) IBOutlet StudentVideoListView *studentListView;
@property (weak, nonatomic) IBOutlet UIButton *unMuteAll;
@property (weak, nonatomic) IBOutlet UIButton *muteAll;
@property (weak, nonatomic) IBOutlet UIButton *muteLocalVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *muteLocalAudioButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteBoardRightRightCon;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseWhiteBoardTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteBoardLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *studentVideoLeftCon;

@property (nonatomic, assign) ClassRoomRole role;
@property (nonatomic, strong) ClassRoomDataManager *roomDataManager;
@property (nonatomic, strong) AgoraRtmChannel   *agoraRtmChannel;
@property (nonatomic, assign) BOOL  isChatTextFieldKeyboard;
@end

@implementation RoomViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self loadClassRoomConfig];

    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.memberListView.studentArray = self.roomDataManager.studentArray;
    self.studentListView.studentArray = self.roomDataManager.studentArray;
    [self setUpView];
    [self addWhiteBoardKit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [self loadAgoraKit];
}

- (void)loadClassRoomConfig {
    self.roomDataManager = [ClassRoomDataManager shareManager];
    self.roomDataManager.classRoomManagerDelegate = self;

    self.role = self.roomDataManager.roomRole;
    self.agoraRtmChannel = self.roomDataManager.agoraRtmChannel;
}

- (void)keyboardWasShown:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.textFieldBottomCon.constant = frame.size.height;
        self.textFieldRightCon.constant = 0;
        self.textFieldLeftCon.constant = - (self.baseWhiteBoardView.bounds.size.width + 10);
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textFieldBottomCon.constant = 10;
    self.textFieldRightCon.constant = 10;
    self.textFieldLeftCon.constant = 9;
}

- (void)setUpView {
    self.studentVideoLeftCon.constant = (kScreenHeight / kScreenWidth > 1.78) ? -44 : 0;
    [self.baseWhiteBoardView addSubview:self.whiteBoardView];
    [self.baseWhiteBoardView bringSubviewToFront:self.whiteBoardTool];
    [self.baseWhiteBoardView bringSubviewToFront:self.leaveRoomButton];
    [self.baseWhiteBoardView bringSubviewToFront:self.whiteBoardControlSizeButton];
    [self.baseWhiteBoardView bringSubviewToFront:self.muteLocalAudioButton];
    [self.baseWhiteBoardView bringSubviewToFront:self.muteLocalVideoButton];

    [self.teactherVideoView bringSubviewToFront:self.teactherNameLabel];

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.leaveRoomButton.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(16, 16)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.leaveRoomButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.leaveRoomButton.layer.mask = maskLayer;

    WEAK(self)
    self.memberListView.muteCamera = ^(BOOL isMute, RoomUserModel * _Nullable userModel) {
        [weakself muteVideo:isMute target:@[userModel.uid].mutableCopy];
    };
    self.memberListView.muteMic = ^(BOOL isMute, RoomUserModel * _Nullable userModel) {
        [weakself muteAudio:isMute target:@[userModel.uid].mutableCopy];
    };

    self.chatTextField.delegate = self;
    self.whiteBoardTool.selectAppliance = ^(WhiteBoardAppliance applicate) {
        switch (applicate) {
            case WhiteBoardAppliancePencil:
                [weakself setWhiteBoardAppliance:AppliancePencil];
                break;
            case WhiteBoardApplianceSelector:
                [weakself setWhiteBoardAppliance:ApplianceSelector];
                break;
            case WhiteBoardApplianceRectangle:
                [weakself setWhiteBoardAppliance:ApplianceRectangle];
                break;
            case WhiteBoardApplianceEraser:
                [weakself setWhiteBoardAppliance:ApplianceEraser];
                break;
            case WhiteBoardApplianceText:
                [weakself setWhiteBoardAppliance:ApplianceText];
                break;
            case WhiteBoardApplianceEllipse:
                [weakself setWhiteBoardAppliance:ApplianceEllipse];
                break;
            default:
                break;
        }
    };
}

- (void)addWhiteBoardKit {
    self.writeSDK = [[WhiteSDK alloc] initWithWhiteBoardView:self.whiteBoardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
    WEAK(self)
    if (self.roomDataManager.uuid && self.roomDataManager.roomToken) {
        NSString *roomToken = self.roomDataManager.roomToken;
        NSString *uuid = self.roomDataManager.uuid;
        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:roomToken];
        [self.writeSDK joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nonnull room, NSError * _Nonnull error) {
            if (success) {
                weakself.title = NSLocalizedString(@"我的白板", nil);
                weakself.whiteRoom = room;
                WhiteRectangleConfig *config = [[WhiteRectangleConfig alloc] initWithInitialPosition:kScreenWidth height:kScreenHeight animation:(AnimationModeContinuous)];
                [weakself.whiteRoom moveCameraToContainer:config];
                if (weakself.role == ClassRoomRoleAudience) {
                    weakself.whiteBoardTool.hidden = YES;
                    [weakself.whiteRoom disableOperations:YES];
                    weakself.muteLocalVideoButton.hidden = YES;
                    weakself.muteLocalAudioButton.hidden = YES;
                }else {
                    [weakself.whiteRoom disableOperations:NO];
                    [weakself setWhiteBoardAppliance:AppliancePencil];
                }
                [weakself.whiteRoom refreshViewSize];
            } else {
                weakself.title = NSLocalizedString(@"加入失败", nil);
            }
        }];
    }
}

- (void)loadAgoraKit {
    self.agoraEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    if (self.roomDataManager.teactherArray.count > 0) {
        RoomUserModel *teactherModel = self.roomDataManager.teactherArray[0];
        if ([teactherModel.uid isEqualToString:self.roomDataManager.uid]) {
            AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
            canvas.uid  = 0;
            canvas.view = self.teactherVideoView;
            [self.agoraEngineKit setupLocalVideo:canvas];
            self.memberListView.isTeacther = YES;
        }else {
            [self updateTeactherVideo:teactherModel.uid];
            self.memberListView.isTeacther = NO;
        }
        self.teactherDefaultImage.hidden = YES;
        self.teactherNameLabel.text = teactherModel.name;
    }
    [self.agoraEngineKit setParameters:@"{\"rtc.force_unified_communication_mode\":true}"];
    [self.agoraEngineKit enableWebSdkInteroperability:YES];
    [self.agoraEngineKit enableVideo];
    [self.agoraEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    if (self.role == ClassRoomRoleTeacther || self.role == ClassRoomRoleStudent) {
        [self.agoraEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    }else {
        [self.agoraEngineKit setClientRole:(AgoraClientRoleAudience)];
    }

     WEAK(self)
    self.roomManagerView.classRoomRole = self.role;
    self.roomManagerView.topButtonType = ^(UIButton *button) {
        weakself.chatTextBaseView.hidden = button.tag == 1000 ? NO : YES;
    };

    self.studentListView.studentVideoList = ^(UIView * _Nonnull imageView, NSIndexPath * _Nullable indexPath) {
        if (weakself.roomDataManager.studentArray.count > 0) {
            RoomUserModel *userModel = weakself.roomDataManager.studentArray[indexPath.row];
            if ([userModel.uid isEqualToString:weakself.roomDataManager.uid]) {
                AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
                canvas.uid = [userModel.uid integerValue];
                canvas.view = imageView;
                [weakself.agoraEngineKit setupLocalVideo:canvas];
            }else {
                AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
                canvas.uid = [userModel.uid integerValue];
                canvas.view = imageView;
                [weakself.agoraEngineKit setupRemoteVideo:canvas];
            }
        }
    };
    [self.agoraEngineKit joinChannelByToken:nil channelId:self.roomDataManager.className info:nil uid:[self.roomDataManager.uid integerValue] joinSuccess:nil];
}

- (void)updateTeactherVideo:(NSString *)uid {
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid  = [uid integerValue];
    canvas.view = self.teactherVideoView;
    [self.agoraEngineKit setupRemoteVideo:canvas];
}

- (void)refreshUserModelAudioMuted:(BOOL)mute {
    if (self.role == ClassRoomRoleTeacther) {
        RoomUserModel *userModel = self.roomDataManager.teactherArray[0];
        userModel.isMuteAudio = mute;
        [self.roomDataManager.teactherArray replaceObjectAtIndex:0 withObject:userModel];
    }else {
        NSMutableArray *studentArray = self.roomDataManager.studentArray;
        for (NSInteger i = 0; i < studentArray.count; i++) {
            RoomUserModel *userModel = studentArray[i];
            if ([userModel.uid isEqualToString:self.roomDataManager.uid]) {
                userModel.isMuteAudio = mute;
            }
            [self.roomDataManager.studentArray replaceObjectAtIndex:i withObject:userModel];
        }
    }
}

- (void)refreshUserModelVideoMuted:(BOOL)mute {
    if (self.role == ClassRoomRoleTeacther) {
        self.teactherDefaultImage.hidden = mute == YES ? NO : YES;
        RoomUserModel *userModel = self.roomDataManager.teactherArray[0];
        userModel.isMuteVideo = mute;
        [self.roomDataManager.teactherArray replaceObjectAtIndex:0 withObject:userModel];
    }else {
        NSMutableArray *studentArray = self.roomDataManager.studentArray;
        for (NSInteger i = 0; i < studentArray.count; i++) {
            RoomUserModel *userModel = studentArray[i];
            if ([userModel.uid isEqualToString:self.roomDataManager.uid]) {
                userModel.isMuteVideo = mute;
            }
            [self.roomDataManager.studentArray replaceObjectAtIndex:i withObject:userModel];
        }
        self.studentListView.studentArray = self.roomDataManager.studentArray;
    }
}
#pragma mark -------------------   Methods ----------------
- (void)setWhiteBoardAppliance:(WhiteApplianceNameKey)appliance {
    WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
    memberState.currentApplianceName =  appliance;
    [self.whiteRoom setMemberState:memberState];
}

- (IBAction)leaveRoom:(UIButton *)sender {
    AgoraAlertViewController *alterVC = [AgoraAlertViewController alertControllerWithTitle:@"点击确定后将退出当前课堂，" message:@"是否确定退出？" preferredStyle:UIAlertControllerStyleAlert];
    WEAK(self)
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself leaveClassRoom];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alterVC addAction:sure];
    [alterVC addAction:cancel];
    [self presentViewController:alterVC animated:YES completion:nil];
}

- (IBAction)whiteBoardZoom:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        self.baseWhiteBoardTopCon.constant = 10;
        self.whiteBoardLeftCon.constant = 10;
        self.whiteBoardRightRightCon.constant = 10;
        self.roomManagerView.hidden = YES;
        self.studentListView.hidden = YES;
        self.chatTextField.hidden = YES;
        self.chatTextBaseView.hidden = YES;
        [self.view bringSubviewToFront:self.teactherVideoView];
        [sender setImage:[UIImage imageNamed:@"whiteBoardMin"] forState:(UIControlStateNormal)];
    }else {
        self.baseWhiteBoardTopCon.constant = 105;
        self.roomManagerView.hidden = NO;
        self.whiteBoardLeftCon.constant = 10;
        self.whiteBoardRightRightCon.constant = 238;
        self.studentListView.hidden = NO;
        self.chatTextField.hidden = NO;
        self.chatTextBaseView.hidden = NO;
        [sender setImage:[UIImage imageNamed:@"whiteBoardMax"] forState:(UIControlStateNormal)];
    }
}

- (IBAction)muteAll:(UIButton *)sender {
    NSMutableArray *uidArray = [NSMutableArray array];
    for (RoomUserModel *userModel in self.roomDataManager.studentArray) {
        userModel.isMuteAudio = YES;
        userModel.isMuteVideo = YES;
        [uidArray addObject:userModel.uid];
    }
    [self muteVideo:YES target:uidArray];
    [self muteAudio:YES target:uidArray];
    self.memberListView.studentArray = self.roomDataManager.studentArray;
}

- (IBAction)unMuteAll:(UIButton *)sender {
    NSMutableArray *uidArray = [NSMutableArray array];
    for (RoomUserModel *userModel in self.roomDataManager.studentArray) {
        userModel.isMuteAudio = NO;
        userModel.isMuteVideo = NO;
        [uidArray addObject:userModel.uid];
    }
    [self muteVideo:NO target:uidArray];
    [self muteAudio:NO target:uidArray];
    self.memberListView.studentArray = self.roomDataManager.studentArray;
}

- (IBAction)muteLocalAudio:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraEngineKit muteLocalAudioStream:sender.selected];
    NSString *imageName = sender.selected == YES ? @"roomMicOff" : @"roomMicon";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    [self refreshUserModelAudioMuted:sender.selected];
}

- (IBAction)muteLocalVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.agoraEngineKit muteLocalVideoStream:sender.selected];
    NSString *imageName = sender.selected == YES ? @"roomCameraOff" : @"roomCameraOn";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    [self refreshUserModelVideoMuted:sender.selected];
}

- (void)leaveClassRoom {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.agoraRtmChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {

    }];
    self.agoraRtmChannel = nil;
    [self.roomDataManager removeClassRoomInfo];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.agoraEngineKit leaveChannel:nil];
    UIViewController * presentingViewController = self.presentingViewController;
    while (presentingViewController.presentingViewController) {
        presentingViewController = presentingViewController.presentingViewController;
    }
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)muteVideo:(BOOL)mute target:(NSMutableArray *)target{
    if (mute) {
        NSDictionary *argsVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"video",@"type",target,@"target", nil];
        NSDictionary  *muteVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Mute",@"name",argsVideoInfo,@"args", nil];
        NSString *muteVideoStr =  [JsonAndStringConversions dictionaryToJson:muteVideoInfo];
        [self.roomDataManager sendMessage:muteVideoStr completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {

        }];
    }else {
        NSDictionary *argsVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"video",@"type", target,@"target",nil];
        NSDictionary  *muteVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Unmute",@"name",argsVideoInfo,@"args", nil];
        NSString *muteVideoStr =  [JsonAndStringConversions dictionaryToJson:muteVideoInfo];
        [self.roomDataManager sendMessage:muteVideoStr completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {

        }];
    }
}

- (void)muteAudio:(BOOL)mute target:(NSMutableArray *)target{
    if (mute) {
        NSDictionary *argsAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"audio",@"type",target,@"target", nil];
        NSDictionary  *muteAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Mute",@"name",argsAudioInfo,@"args", nil];
        NSString *muteAudioStr =  [JsonAndStringConversions dictionaryToJson:muteAudioInfo];
        [self.roomDataManager sendMessage:muteAudioStr completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {

        }];
    }else {
        NSDictionary *argsAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"audio",@"type", target,@"target",nil];
        NSDictionary  *muteAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Unmute",@"name",argsAudioInfo,@"args", nil];
        NSString *muteAudioStr =  [JsonAndStringConversions dictionaryToJson:muteAudioInfo];
        [self.roomDataManager sendMessage:muteAudioStr completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {

        }];
    }
}

- (void)sendChatMessage:(NSString *)message {
    if (message.length <= 0) {
        return;
    }
    NSDictionary *argsAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message", nil];
    NSDictionary  *muteAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Chat",@"name",argsAudioInfo,@"args", nil];
    NSString *muteAudioStr =  [JsonAndStringConversions dictionaryToJson:muteAudioInfo];
    WEAK(self)
    [self.roomDataManager sendMessage:muteAudioStr completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode != AgoraRtmSendPeerMessageErrorOk) {
            AgoraAlertViewController *alterVC = [AgoraAlertViewController alertControllerWithTitle:@"send message Failure" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [weakself presentViewController:alterVC animated:YES completion:nil];
            [alterVC autoDismiss:1.5];
        }
    }];
}
#pragma mark ---------- Agora Delegate -----------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {
    if (errorCode == AgoraErrorCodeNotReady
        || errorCode == AgoraErrorCodeNotInitialized
        || errorCode == AgoraErrorCodeAlreadyInUse
        || errorCode == AgoraErrorCodeInvalidAppId
        || errorCode == AgoraErrorCodeInvalidChannelId
        || errorCode == AgoraErrorCodeLoadMediaEngine
        || errorCode == AgoraErrorCodeStartCall
        || errorCode == AgoraErrorCodeInvalidToken) {
        AgoraAlertViewController *alterVC = [AgoraAlertViewController alertControllerWithTitle:@"AgoraEngine ERROR" message:@"请退出" preferredStyle:UIAlertControllerStyleAlert];
        WEAK(self)
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself leaveClassRoom];
        }];
        [alterVC addAction:sure];
        [self presentViewController:alterVC animated:YES completion:nil];
    }
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"-d-----------");
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    if (self.roomDataManager.teactherArray.count > 0) {
        if (uid == [self.roomDataManager.teactherArray[0].uid integerValue]) {
            self.teactherDefaultImage.hidden = muted ? NO : YES;
        }
    }
    for (NSInteger i = 0; i < self.roomDataManager.studentArray.count; i++) {
        RoomUserModel *userModel = self.roomDataManager.studentArray[i];
        if (uid == [userModel.uid  integerValue]) {
            userModel.isMuteVideo = muted;
        }
        [self.roomDataManager.studentArray replaceObjectAtIndex:i withObject:userModel];
    }
    self.studentListView.studentArray = self.roomDataManager.studentArray;
    self.memberListView.studentArray = self.roomDataManager.studentArray;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    for (NSInteger i = 0; i < self.roomDataManager.studentArray.count; i++) {
        RoomUserModel *userModel = self.roomDataManager.studentArray[i];
        if (uid == [userModel.uid  integerValue]) {
            userModel.isMuteAudio= muted;
        }
        [self.roomDataManager.studentArray replaceObjectAtIndex:i withObject:userModel];
    }
    self.studentListView.studentArray = self.roomDataManager.studentArray;
    self.memberListView.studentArray = self.roomDataManager.studentArray;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {

}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberJoined:(AgoraRtmMember * _Nonnull)member {
    NSLog(@"%@----- %@",member.userId,member.channelId);

}
- (void)firePhaseChanged:(WhiteRoomPhase)phase {
    NSLog(@"白板连接状态---- %ld",(long)phase);
}

#pragma mark --------------------- Text Delegate ------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendChatMessage:textField.text];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

#pragma mark ---------------- ClassRoomManagerDelegate ------
- (void)teactherJoinSuccess {
    self.teactherDefaultImage.hidden = YES;
    if (self.roomDataManager.teactherArray.count > 0) {
        RoomUserModel *userModel = self.roomDataManager.teactherArray[0];
        [self updateTeactherVideo:userModel.uid];
        self.teactherNameLabel.text = userModel.name;
    }
}

- (void)teactherLeaveClassRoom {
    self.teactherDefaultImage.hidden = NO;
    self.teactherNameLabel.text = nil;
    [self.teactherVideoView bringSubviewToFront:self.teactherDefaultImage];
    AgoraAlertViewController *alterVC = [AgoraAlertViewController alertControllerWithTitle:@"老师退出课堂" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alterVC addAction:cancel];
    [self presentViewController:alterVC animated:YES completion:nil];
}

- (void)updateStudentList {
    self.studentListView.studentArray = self.roomDataManager.studentArray;
    self.memberListView.studentArray = self.roomDataManager.studentArray;
}

- (void)updateChatMessageList {
    self.messageListView.messageArray = self.roomDataManager.messageArray;
}

- (void)muteLoaclVideoStream:(BOOL)stream {
    NSString  *imageName = stream == YES ? @"roomCameraOff" :  @"roomCameraOn";
    self.muteLocalVideoButton.selected = stream;
    [self.muteLocalVideoButton setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    [self.agoraEngineKit muteLocalVideoStream:stream];
    [self refreshUserModelVideoMuted:stream];
    NSString *promptMessage = stream == YES ? @"老师关闭了你的摄像头" : @"老师打开了你的摄像头";
    [self autoPromptViewMessage:promptMessage];
}

- (void)muteLoaclAudioStream:(BOOL)stream {
    NSString  *imageName = stream == YES ? @"roomMicOff" :  @"roomMicon";
    self.muteLocalAudioButton.selected = stream;
    [self.muteLocalAudioButton setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    [self.agoraEngineKit muteLocalAudioStream:stream];
    [self refreshUserModelAudioMuted:stream];
    NSString *promptMessage = stream == YES ? @"老师关闭了你的麦克风" : @"老师打开了你的麦克风";
    [self autoPromptViewMessage:promptMessage];
}

- (void)autoPromptViewMessage:(NSString *)message {
    AgoraAlertViewController *alterVC = [AgoraAlertViewController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alterVC animated:YES completion:nil];
    [alterVC autoDismiss:1.5];
}
#pragma mark -----------------  Lazy ----------------
- (WhiteBoardView *)whiteBoardView {
    if (!_whiteBoardView) {
        _whiteBoardView = [[WhiteBoardView alloc] init];
        _whiteBoardView.frame = _baseWhiteBoardView.bounds;
        _whiteBoardView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
        _whiteBoardView.scrollView.contentOffset = CGPointZero;
    }
    return _whiteBoardView;
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate {
    return NO;
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

- (void)dealloc
{
    NSLog(@"RoomViewController dealloc");
}
@end
