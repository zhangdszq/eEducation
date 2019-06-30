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
#import "ChatTextView.h"
#import "MemberListView.h"
#import "MessageListView.h"
#import "StudentVideoListView.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
#import "ClassRoomDataManager.h"
#import "RoomMessageModel.h"
#import "AgoraAlertViewController.h"

@interface RoomViewController ()<WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate,AgoraRtmDelegate,AgoraRtmChannelDelegate,WhiteRoomCallbackDelegate>
@property (nonatomic, strong) AgoraRtcEngineKit *agoraEngineKit;
@property (nonatomic, strong) WhiteSDK *writeSDK;
@property (nonatomic, strong) WhiteRoom *whiteRoom;
@property (nonatomic, strong) WhiteBoardView *whiteBoardView;
@property (nonatomic, strong)   NSMutableArray *studentArray;
@property (nonatomic, strong)   NSMutableArray *audienceArray;
@property (nonatomic, strong)  NSMutableArray *messageArray;
@property (weak, nonatomic) IBOutlet UIView *baseWhiteBoardView;
@property (weak, nonatomic) IBOutlet UIView *teactherVideoView;
@property (weak, nonatomic) IBOutlet UILabel *teactherNameLabel;

@property (weak, nonatomic) IBOutlet WhiteBoardToolControl *whiteBoardTool;
@property (weak, nonatomic) IBOutlet UIButton *leaveRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *whiteBoardControlSizeButton;
@property (weak, nonatomic) IBOutlet RoomManageView *roomManagerView;
@property (weak, nonatomic) IBOutlet ChatTextView *chatTextView;
@property (weak, nonatomic) IBOutlet MemberListView *memberListView;
@property (weak, nonatomic) IBOutlet MessageListView *messageListView;
@property (weak, nonatomic) IBOutlet StudentVideoListView *studentListView;
@property (weak, nonatomic) IBOutlet UIButton *unMuteAll;
@property (weak, nonatomic) IBOutlet UIButton *muteAll;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseWhiteBoardTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteBoardLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeftCon;
@property (nonatomic, strong) RoomUserModel *teactherModel;
@property (nonatomic, assign) ClassRoomRole role;
@property (nonatomic, strong) ClassRoomDataManager *roomDataManager;
@property (nonatomic, strong) AgoraRtmKit       *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel   *agoraRtmChannel;
@end

@implementation RoomViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadClassRoomConfig];

    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.memberListView.memberArray = self.studentArray.mutableCopy;
    self.studentListView.studentArray = self.studentArray;
    [self setUpView];
    [self addWhiteBoardKit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [self loadAgoraKit];
}

- (void)loadClassRoomConfig {
    self.roomDataManager = [ClassRoomDataManager shareManager];
    self.roomDataManager.agoraRtmKit.agoraRtmDelegate  = self;
    self.roomDataManager.agoraRtmChannel.channelDelegate = self;

    self.role = self.roomDataManager.roomRole;
    self.agoraRtmChannel = self.roomDataManager.agoraRtmChannel;
    self.agoraRtmKit = self.roomDataManager.agoraRtmKit;
    for (RoomUserModel *userModel in _roomDataManager.memberArray) {
        if (userModel.role == ClassRoomRoleTeacther) {
            self.teactherModel = [userModel yy_modelCopy];
        }else if (userModel.role == ClassRoomRoleStudent) {
            [self.studentArray addObject:userModel];
        }else {
            [self.audienceArray addObject:userModel];
        }
    }
}

- (void)keyboardWasShown:(NSNotification *)notification {
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.textViewBottomCon.constant = frame.size.height - 34;
    self.textViewLeftCon.constant = - (frame.size.width - self.roomManagerView.frame.size.width -40);
    [NSLayoutConstraint activateConstraints:@[self.textViewLeftCon]];
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    // 获取键盘的高度
    self.textViewBottomCon.constant = 9;
    self.textViewLeftCon.constant = 0;
}

- (void)setUpView {
    [self.baseWhiteBoardView addSubview:self.whiteBoardView];
    [self.baseWhiteBoardView bringSubviewToFront:self.whiteBoardTool];
    [self.baseWhiteBoardView bringSubviewToFront:self.leaveRoomButton];
    [self.baseWhiteBoardView bringSubviewToFront:self.whiteBoardControlSizeButton];

    WEAK(self)
    self.memberListView.muteCamera = ^(BOOL isMute, RoomUserModel * _Nullable userModel) {
        [weakself muteVideo:isMute target:@[userModel.uid].mutableCopy];
    };
    self.memberListView.muteMic = ^(BOOL isMute, RoomUserModel * _Nullable userModel) {
        [weakself muteVideo:isMute target:@[userModel.uid].mutableCopy];
    };

    self.chatTextView.chatMessage = ^(NSString *messageString) {
        AgoraRtmMessage *message = [[AgoraRtmMessage alloc] initWithText:messageString];
        __strong typeof(weakself) strongSelf = weakself;
        [weakself.agoraRtmChannel sendMessage:message completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
            if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
                RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
                messageModel.content = message.text;
                messageModel.name = strongSelf.roomDataManager.userName;
                [weakself.messageArray addObject:messageModel];
                strongSelf.messageListView.messageArray = strongSelf.messageArray;
            }
        }];
    };
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
            case WhiteBoardUserControl:
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
                [weakself setWhiteBoardAppliance:AppliancePencil];
            } else {
                weakself.title = NSLocalizedString(@"加入失败", nil);
            }
        }];
    }

}

- (void)loadAgoraKit {
    self.agoraEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    if ([self.teactherModel.uid isEqualToString:self.roomDataManager.uid]) {
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid  = 0;
        canvas.view = self.teactherVideoView;
        [self.agoraEngineKit setupLocalVideo:canvas];
        self.memberListView.isTeacther = YES;
    }else {
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid  =[self.teactherModel.uid integerValue];
        canvas.view = self.teactherVideoView;
        [self.agoraEngineKit setupRemoteVideo:canvas];
        self.memberListView.isTeacther = NO;
    }
    self.teactherNameLabel.text = self.teactherModel.name;
    [self.agoraEngineKit enableVideo];
    [self.agoraEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    if (self.role == ClassRoomRoleTeacther || self.role == ClassRoomRoleStudent) {
        [self.agoraEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    }else {
        [self.agoraEngineKit setClientRole:(AgoraClientRoleAudience)];
    }
    self.roomManagerView.classRoomRole = self.role;
    WEAK(self)
    self.studentListView.studentVideoList = ^(UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nullable indexPath) {
        if (weakself.studentArray.count > 0) {
            RoomUserModel *userModel = weakself.studentArray[indexPath.row];
            if ([userModel.uid isEqualToString:weakself.roomDataManager.uid]) {
                AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
                canvas.uid = [userModel.uid integerValue];
                canvas.view = cell.contentView;
                [weakself.agoraEngineKit setupLocalVideo:canvas];
            }else {
                AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
                canvas.uid = [userModel.uid integerValue];
                canvas.view = cell.contentView;
                [weakself.agoraEngineKit setupRemoteVideo:canvas];
            }
        }
    };
    [self.agoraEngineKit joinChannelByToken:nil channelId:self.roomDataManager.className info:nil uid:[self.roomDataManager.uid integerValue] joinSuccess:nil];
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
        [weakself.agoraRtmChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {

        }];
        [[NSNotificationCenter defaultCenter] removeObserver:weakself];
        [weakself.agoraEngineKit leaveChannel:nil];
        UIViewController * presentingViewController = weakself.presentingViewController;
        while (presentingViewController.presentingViewController) {
            presentingViewController = presentingViewController.presentingViewController;
        }
        [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alterVC addAction:sure];
    [alterVC addAction:cancle];
    [self presentViewController:alterVC animated:YES completion:nil];
}

- (IBAction)whiteBoardZoom:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        self.baseWhiteBoardTopCon.constant = 10;
        self.whiteBoardLeftCon.constant = 10;
        [sender setImage:[UIImage imageNamed:@"whiteBoardMin"] forState:(UIControlStateNormal)];
        self.roomManagerView.hidden = YES;
        [self.view bringSubviewToFront:self.teactherVideoView];
    }else {
        self.baseWhiteBoardTopCon.constant = 105;
        self.roomManagerView.hidden = NO;
        self.whiteBoardLeftCon.constant = 238;
        [sender setImage:[UIImage imageNamed:@"whiteBoardMax"] forState:(UIControlStateNormal)];
    }
}

- (IBAction)muteAll:(UIButton *)sender {
    NSMutableArray *uidArray = [NSMutableArray array];
    for (RoomUserModel *userModel in _studentArray) {
        userModel.isMuteAudio = YES;
        userModel.isMuteVideo = YES;
        [uidArray addObject:userModel.uid];
    }
    [self muteVideo:YES target:uidArray];
    self.memberListView.memberArray = self.studentArray;
}

- (IBAction)unMuteAll:(UIButton *)sender {
    NSMutableArray *uidArray = [NSMutableArray array];
    for (RoomUserModel *userModel in _studentArray) {
        userModel.isMuteAudio = NO;
        userModel.isMuteVideo = NO;
        [uidArray addObject:userModel.uid];
    }
     [self muteVideo:NO target:uidArray];
    self.memberListView.memberArray = self.studentArray;
}

- (void)muteVideo:(BOOL)mute target:(NSMutableArray *)target{
    if (mute) {
        NSDictionary *argsVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"video",@"type",target,@"target", nil];
        NSDictionary  *muteVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Mute",@"name",argsVideoInfo,@"args", nil];
        NSString *muteVideoStr =  [JsonAndStringConversions dictionaryToJson:muteVideoInfo];
        AgoraRtmMessage *videoMessage = [[AgoraRtmMessage alloc] initWithText:muteVideoStr];
        [self.agoraRtmKit sendMessage:videoMessage toPeer:self.roomDataManager.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        }];
    }else {
        NSDictionary *argsVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"video",@"type", target,@"target",nil];
        NSDictionary  *muteVideoInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Unmute",@"name",argsVideoInfo,@"args", nil];
        NSString *muteVideoStr =  [JsonAndStringConversions dictionaryToJson:muteVideoInfo];
        AgoraRtmMessage *videoMessage = [[AgoraRtmMessage alloc] initWithText:muteVideoStr];
        [self.agoraRtmKit sendMessage:videoMessage toPeer:self.roomDataManager.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        }];
    }
}
- (void)muteAudio:(BOOL)mute {
    if (mute) {
        NSDictionary *argsAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"video",@"type", nil];
        NSDictionary  *muteAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Mute",@"name",argsAudioInfo,@"args", nil];
        NSString *muteAudioStr =  [JsonAndStringConversions dictionaryToJson:muteAudioInfo];
        AgoraRtmMessage *audioMessage = [[AgoraRtmMessage alloc] initWithText:muteAudioStr];
        [self.agoraRtmKit sendMessage:audioMessage toPeer:self.roomDataManager.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        }];
    }else {
        NSDictionary *argsAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"video",@"type", nil];
        NSDictionary  *muteAudioInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Unmute",@"name",argsAudioInfo,@"args", nil];
        NSString *muteAudioStr =  [JsonAndStringConversions dictionaryToJson:muteAudioInfo];
        AgoraRtmMessage *audioMessage = [[AgoraRtmMessage alloc] initWithText:muteAudioStr];
        [self.agoraRtmKit sendMessage:audioMessage toPeer:self.roomDataManager.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        }];
    }
}
#pragma mark ---------- Agora Delegate -----------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"ddasadsads----");
}
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {

}

#pragma mark ---------- Agora RTM   Delegate -----------
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    NSLog(@"%@",message.text);
    if ([peerId isEqualToString:self.roomDataManager.serverRtmId]) {
        NSString *messageStr = message.text;
        NSDictionary *messageDict  =  [JsonAndStringConversions dictionaryWithJsonString:messageStr];
        if ([[messageDict objectForKey:@"name"] isEqualToString:@"MemberJoined"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            if ([[argsDict objectForKey:@"role"] integerValue] == ClassRoomRoleTeacther) {
            }else if ([[argsDict objectForKey:@"role"] integerValue] == ClassRoomRoleStudent){
                RoomUserModel *userModel = [RoomUserModel yy_modelWithDictionary:argsDict];
                [self.studentArray addObject:userModel];
                self.memberListView.memberArray = self.studentArray;
                self.studentListView.studentArray = self.studentArray;
            }else {
                RoomUserModel *userModel = [RoomUserModel yy_modelWithDictionary:argsDict];
                [self.audienceArray addObject:userModel];
            }
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"MemberLeft"]){
            NSDictionary *argsDict = messageDict[@"args"];
            NSMutableArray *temArray = self.studentArray;
            for (NSInteger i = 0; i < temArray.count; i++) {
                RoomUserModel *userModel = temArray[i];
                if ([argsDict[@"uid"] isEqualToString:userModel.uid]) {
                    [self.studentArray removeObjectAtIndex:i];
                }
            }
            self.studentListView.studentArray = self.studentArray;
        }else if ([[messageDict objectForKey:@"name"] isEqualToString:@"ChannelMessage"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            NSString *uid = [argsDict objectForKey:@"uid"];
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            messageModel.isTeacther = [uid isEqualToString:self.teactherModel.uid] ? YES : NO;
            messageModel.content = [argsDict objectForKey:@"message"];
            messageModel.name = [argsDict objectForKey:@"uid"];
            [self.messageArray addObject:messageModel];
            self.messageListView.messageArray = self.messageArray;
        }else if ([[messageDict objectForKey:@"name"] isEqualToString:@"Muted"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            if ([argsDict[@"type"] isEqualToString:@"video"]) {
                [self.agoraEngineKit muteLocalVideoStream:YES];
            }else if ([argsDict[@"type"] isEqualToString:@"audio"]) {
                [self.agoraEngineKit muteLocalVideoStream:YES];
            }
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"Unmuted"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            if ([argsDict[@"type"] isEqualToString:@"video"]) {
                [self.agoraEngineKit muteLocalVideoStream:NO];
            }else if ([argsDict[@"type"] isEqualToString:@"audio"]) {
                [self.agoraEngineKit muteLocalVideoStream:NO];
            }
        }
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberJoined:(AgoraRtmMember * _Nonnull)member {
    NSLog(@"%@----- %@",member.userId,member.channelId);

}
- (void)firePhaseChanged:(WhiteRoomPhase)phase {
    NSLog(@"白板连接状态---- %ld",phase);
}

#pragma mark -----------------  Lazy -----------------
- (NSMutableArray *)studentArray {
    if (!_studentArray) {
        _studentArray = [NSMutableArray array];
    }
    return _studentArray;
}

- (NSMutableArray *)audienceArray {
    if (!_audienceArray) {
        _audienceArray = [NSMutableArray array];
    }
    return _audienceArray;
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

- (WhiteBoardView *)whiteBoardView {
    if (!_whiteBoardView) {
        _whiteBoardView = [[WhiteBoardView alloc] init];
        _whiteBoardView.frame = self.baseWhiteBoardView.bounds;
        _whiteBoardView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
        _whiteBoardView.scrollView.contentOffset = CGPointZero;
    }
    return _whiteBoardView;
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)dealloc
{
    NSLog(@"RoomViewController dealloc");
}
@end
