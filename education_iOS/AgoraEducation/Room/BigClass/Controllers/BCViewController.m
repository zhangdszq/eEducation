//
//  BigClassViewController.m
//  AgoraEducation
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
#import "BCStudentVideoView.h"
#import <WhiteSDK.h>
#import "AgoraHttpRequest.h"
#import "MainViewController.h"
#import "AERTMMessageBody.h"
#import "RoomMessageModel.h"
#import "EEColorShowView.h"
#import "AERTMMessageBody.h"
#import "AEStudentModel.h"
#import "AETeactherModel.h"
#import "EEMessageView.h"
#import "AEP2pMessageModel.h"

#define kLandscapeViewWidth    223
@interface BCViewController ()<EESegmentedDelegate,EEWhiteboardToolDelegate,EEPageControlDelegate,UIViewControllerTransitioningDelegate,WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate,AgoraRtmChannelDelegate,WhiteRoomCallbackDelegate,StudentViewDelegate,AgoraRtmDelegate>
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
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
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
@property (nonatomic, strong) NSMutableDictionary *studentListDict;
@property (nonatomic, strong) AETeactherModel *teacherAttr;
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
@property (nonatomic, strong) AgoraRtcVideoCanvas *shareScreenCanvas;
@property (nonatomic, strong) AgoraRtcVideoCanvas *studentCanvas;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
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
        NSLog(@"rtmChannelName----  %@",self.rtmChannelName);
    }
}

- (void)setChannelAttrsWithVideo:(BOOL)video audio:(BOOL)audio {
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.userId;
    setAttr.value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.userName video:video audio:audio];
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

- (void)addTeacherObserver {
    self.teacherAttr = [[AETeactherModel alloc] init];
    [self.teacherAttr addObserver:self forKeyPath:@"shared_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"whiteboard_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"mute_chat" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"account" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"link_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];

}

- (void)removeTeacherObserver {
    [self.teacherAttr removeObserver:self forKeyPath:@"shared_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"whiteboard_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"mute_chat"];
    [self.teacherAttr removeObserver:self forKeyPath:@"account"];
    [self.teacherAttr removeObserver:self forKeyPath:@"link_uid"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if (![new isEqualToString:old]) {
         if ([keyPath isEqualToString:@"shared_uid"]) {
             NSUInteger shared_uid = [change[@"new"] integerValue];
            if (!self.shareScreenCanvas && shared_uid > 0) {
                [self addShareScreenVideoWithUid:shared_uid];
            }
        }else if ([keyPath isEqualToString:@"uid"]) {
            NSUInteger uid = [change[@"new"] integerValue];
            if (uid > 0 ) {
                self.teacherInRoom = YES;
            }
        }else if ([keyPath isEqualToString:@"whiteboard_uid"]) {
            if (change[@"new"]) {
                [self joinWhiteBoardRoomUUID:change[@"new"]];
            }
        }else if ([keyPath isEqualToString:@"mute_chat"]) {
            if ([change[@"new"] boolValue]) {
                self.chatTextFiled.contentTextFiled.enabled = NO;
                self.chatTextFiled.contentTextFiled.placeholder = @"禁言中";
            }else {
                self.chatTextFiled.contentTextFiled.enabled = YES;
            }
        }else if ([keyPath isEqualToString:@"account"]) {
            [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
        }else if ([keyPath isEqualToString:@"link_uid"]) {
            NSUInteger link_uid = [new integerValue];
            if (!self.studentCanvas && link_uid > 0) {
                [self addStudentVideoWithUid:link_uid];
            }
        }
    }
}


- (void)addShareScreenVideoWithUid:(NSInteger)uid {
    self.windowShareView.hidden = NO;
    self.shareScreenCanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.shareScreenCanvas.uid = uid;
    self.shareScreenCanvas.view = self.windowShareView;
    [self.rtcEngineKit setupLocalVideo:self.shareScreenCanvas];
}

- (void)removeShareScreen {
    self.windowShareView.hidden = YES;
    self.shareScreenCanvas = nil;
}

- (void)addStudentVideoWithUid:(NSInteger)uid {
    self.studentVideoView.hidden = NO;
    self.studentCanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.studentCanvas.uid = uid;
    self.studentCanvas.view = self.studentVideoView.studentRenderView;
    [self.rtcEngineKit setupLocalVideo:self.studentCanvas];
}

- (void)removeStudentVideo {
    self.studentVideoView.hidden = YES;
    self.studentCanvas = nil;
}
#pragma mark ------------------------ sys methods -----------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationView updateChannelName:self.channelName];
    [self addNotification];
    [self setUpView];
    [self addTeacherObserver];
    [self addTeacherObserver];
    [self.rtmKit setAgoraRtmDelegate:self];
    self.studentListDict = [NSMutableDictionary dictionary];
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
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
           float bottom = frame.size.height;
           self.textFiledBottomConstraint.constant = bottom;
    }
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
    [AERTMMessageBody addShadowWithView:self.handUpButton alpha:0.1];

    self.tipLabel.layer.backgroundColor = RCColorWithValue(0x000000, 0.7).CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    [AERTMMessageBody addShadowWithView:self.tipLabel alpha:0.25];

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
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    [self.rtcEngineKit enableAudioVolumeIndication:300 smooth:3 report_vad:NO];
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
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
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
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
        weakself.sceneIndex = state.index;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",(long)weakself.sceneIndex,(long)weakself.scenes.count]];
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
    self.teacherVideoWidthCon.constant = kLandscapeViewWidth;
    self.handupButtonRightCon.constant = 233;
    self.whiteboardToolTopCon.constant = 10;
    self.messageViewWidthCon.constant = kLandscapeViewWidth;
    self.chatTextFiledWidthCon.constant = kLandscapeViewWidth;
    self.tipLabelTopCon.constant = 10;
    self.messageViewTopCon.constant = 0;
    self.whiteboardViewRightCon.constant = isIphoneX ? -267 : -kLandscapeViewWidth;
    self.whiteboardViewTopCon.constant = 0;
    self.teacherVideoViewHeightCon.constant = 125;
    self.studentVideoViewLeftCon.constant = 66;
    self.studentViewHeightCon.constant = 85;
    self.studentViewWidthCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    CGFloat boardViewWidth = isIphoneX ? MAX(kScreenHeight, kScreenWidth) - 301 : MAX(kScreenHeight, kScreenWidth) - kLandscapeViewWidth;
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
    [EEAlertView showAlertWithController:self title:@"是否退出房间?" sureHandler:^(UIAlertAction * _Nullable action) {
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

- (IBAction)handUpEvent:(UIButton *)sender {
    WEAK(self)
    switch (self.linkState) {
        case StudentLinkStateIdle:
        {
            [self.rtmKit sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody studentApplyLink]] toPeer:self.teacherAttr.uid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
                if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
                    weakself.linkState = StudentLinkStateApply;
                    [sender setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];
                }
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakself.linkState == StudentLinkStateApply) {
                    weakself.handUpButton.enabled = YES;
                    weakself.linkState = StudentLinkStateIdle;
                    [sender setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
                }
            });
        }
            break;
        case StudentLinkStateAccept:
        {
            if (self.segmentedIndex == 0) {
                self.whiteboardTool.hidden = YES;
            }
            [self.rtmKit sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody studentCancelLink]] toPeer:self.teacherAttr.uid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
                if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
                    weakself.linkState = StudentLinkStateIdle;
                    weakself.studentVideoView.hidden = YES;
                    [weakself.rtcEngineKit setClientRole:(AgoraClientRoleAudience)];
                    [sender setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
                }
            }];
        }
            break;
        case StudentLinkStateApply:
        {
            [self.studentVideoView updateAudioImageWithMuteState:NO];
            [self.studentVideoView updateVideoImageWithMuteState:NO];
            self.studentVideoView.hidden = YES;
        }
             break;
        default:
            break;
    }
}

- (void)parsingTheChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    if (attributes.count > 0) {
        for (AgoraRtmChannelAttribute *channelAttr in attributes) {
           NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
           if ([channelAttr.key isEqualToString:@"teacher"]) {
               [self.teacherAttr modelWithDict:valueDict];

               if (self.segmentedIndex == 0) {
                   self.handUpButton.hidden = NO;
                   self.pageControlView.hidden = NO;
               }
           }else {
               AEStudentModel *studentAttr = [AEStudentModel yy_modelWithJSON:valueDict];
               studentAttr.userId = channelAttr.key;
               [self.studentListDict setValue:studentAttr forKey:channelAttr.key];
           }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    WEAK(self)
    __block NSString *content = textField.text;
    [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody sendP2PMessageWithName:self.userName content:content]] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
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
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
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
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%zd",(long)self.sceneIndex+1,self.scenes.count]];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.scenes.count - 1) {
        self.sceneIndex ++;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%zd",(long)self.sceneIndex+1,self.scenes.count]];
    }
}

- (void)lastPage {
    self.sceneIndex = self.scenes.count;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex - 1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%zd/%zd",self.scenes.count,self.scenes.count]];
}

- (void)firstPage {
    self.sceneIndex = 0;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[0].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"1/%zd",self.scenes.count]];
}


#pragma mark --------------------- RTC Delegate -------------------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed {
    if (uid == [self.teacherAttr.uid integerValue]) {
        self.teactherVideoView.defaultImageView.hidden = YES;
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid = uid;
        canvas.view = self.teactherVideoView.teacherRenderView;
        [self.rtcEngineKit setupRemoteVideo:canvas];
    }else {
        [self addStudentVideoWithUid:uid];
        self.linkUserId = [NSString stringWithFormat:@"%ld",(unsigned long)uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (uid != [self.teacherAttr.uid integerValue] && !self.studentCanvas) {
        AEStudentModel *studentAttrs = [self.studentListDict objectForKey:@(uid)];
        [self.studentVideoView updateVideoImageWithMuteState:studentAttrs.video];
        [self.studentVideoView updateAudioImageWithMuteState:studentAttrs.audio];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid  == [self.teacherAttr.uid integerValue]) {
        self.teacherInRoom = NO;
    }else if (uid == [self.teacherAttr.shared_uid integerValue]) {
         [self removeShareScreen];

    }else {
        [self removeStudentVideo];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    [self.studentVideoView updateVideoImageWithMuteState:muted];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    [self.studentVideoView updateVideoImageWithMuteState:muted];
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
#pragma mark --------------------- RTM Delegate -------------------
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
   NSDictionary *dict =  [JsonAndStringConversions dictionaryWithJsonString:message.text];
    RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
    messageModel.content = dict[@"content"];
    messageModel.name = dict[@"account"];
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
        AEP2pMessageModel *model = [AEP2pMessageModel yy_modelWithDictionary:dict];
        switch (model.cmd) {
            case RTMp2pTypeMuteAudio:
            {
                [self.rtcEngineKit muteLocalAudioStream:YES];
                              [self.studentVideoView updateAudioImageWithMuteState:YES];
            }
                break;
            case RTMp2pTypeUnMuteAudio:
            {
                [self.rtcEngineKit muteLocalAudioStream:NO];
                              [self.studentVideoView updateAudioImageWithMuteState:NO];
            }
                          break;
            case RTMp2pTypeMuteVideo:
            {
                [self.rtcEngineKit muteLocalVideoStream:YES];
                                             [self.studentVideoView updateVideoImageWithMuteState:YES];
            }
                          break;
            case RTMp2pTypeUnMuteVideo:
            {
                [self.rtcEngineKit muteLocalVideoStream:NO];
                               [self.studentVideoView updateVideoImageWithMuteState:NO];
            }
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
                [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
                 self.linkState = StudentLinkStateAccept;
                 AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
                 canvas.uid = [self.userId integerValue];
                 canvas.view = self.studentVideoView.studentRenderView;
                 [self.rtcEngineKit setupLocalVideo:canvas];
                 self.studentVideoView.hidden = NO;
                 [self.studentVideoView setButtonEnabled:YES];
                 [self.tipLabel setText:[NSString stringWithFormat:@"%@接受了你的连麦申请!",self.teacherAttr.account]];
                 [self setChannelAttrsWithVideo:YES audio:YES];
                 WEAK(self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakself.tipLabel.hidden = YES;
                });
                 self.handUpButton.enabled = YES;
            }
                break;
            case RTMp2pTypeCancel:
            {
                self.whiteboardTool.hidden = YES;
                           self.linkState = StudentLinkStateIdle;
            }
            break;
            case RTMp2pTypeMuteChat:

            break;
            case RTMp2pTypeUnMuteChat:

            break;

            default:
                break;
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
        self.sceneIndex = modifyState.sceneState.index;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",(long)self.sceneIndex+1,self.scenes.count]];
    }
}
- (void)clickMuteVideoButton {
    AEStudentModel *attrs =  [self.studentListDict objectForKey:self.userId];
    [self setChannelAttrsWithVideo:!attrs.video audio:attrs.audio];
    [self.studentVideoView updateVideoImageWithMuteState:!attrs.video];
    [self.rtcEngineKit muteLocalVideoStream:attrs.video];
    self.studentVideoView.defaultImageView.hidden = attrs.video ? NO : YES;
    NSString *imageName = attrs.video ? @"icon-videooff-dark" : @"icon-videoon-dark";
    [self.studentVideoView updateImageName:imageName];
}

- (void)clickMuteAudioButton {
    AEStudentModel *attrs =  [self.studentListDict objectForKey:self.userId];
    [self setChannelAttrsWithVideo:attrs.video audio:!attrs.audio];
    [self.studentVideoView updateAudioImageWithMuteState:!attrs.audio];
    [self.rtcEngineKit muteLocalVideoStream:attrs.audio];
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

