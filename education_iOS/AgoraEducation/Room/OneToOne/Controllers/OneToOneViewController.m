//
//  OneToOneViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 yangmoumou. All rights reserved.
//
// 1V1 注意分享屏幕就可以

#import "OneToOneViewController.h"
#import "EENavigationView.h"
#import "EEWhiteboardTool.h"
#import "EEPageControlView.h"
#import "EEChatTextFiled.h"
#import "AERoomMessageModel.h"
#import "EEMessageView.h"
#import "AETeactherModel.h"
#import "AERTMMessageBody.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "AERTMMessageBody.h"
#import "AEStudentModel.h"
#import <WhiteSDK.h>
#import "EEColorShowView.h"
#import "AgoraHttpRequest.h"

@interface OneToOneViewController ()<UITextFieldDelegate,AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,WhiteCommonCallbackDelegate,WhiteRoomCallbackDelegate,AEClassRoomProtocol>
@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomCon;

@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet UIView *chatRoomView;
@property (weak, nonatomic) IBOutlet OTOTeacherView *teacherView;
@property (weak, nonatomic) IBOutlet OTOStudentView *studentView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageListView;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;

@property (nonatomic, strong) AETeactherModel *teacherAttr;

@property (nonatomic, assign) BOOL teacherInRoom;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@end

@implementation OneToOneViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpView];
    [self setWhiteBoardBrushColor];
    [self addTeacherObserver];
    [self addNotification];
    [self loadAgoraEngine];
    [self getRtmChannelAttrs];
    [self.studentView updateUserName:self.userName];
    self.ownAttrs = [[AEStudentModel alloc] initWithParams:[AERTMMessageBody paramsStudentWithUserId:self.userId name:self.userName video:YES audio:YES]];
    [self setChannelAttrsWithVideo:YES audio:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.boardView.frame = self.whiteboardView.bounds;
}

- (void)setUpView {
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self addWhiteBoardViewToView:self.whiteboardView];
    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    [self.navigationView updateChannelName:self.channelName];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.textFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
        self.textFiledBottomCon.constant = bottom;
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textFiledWidthCon.constant = 222;
    self.textFiledBottomCon.constant = 0;
}

- (void)getRtmChannelAttrs {
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingChannelAttr:attributes];
    }];
}

- (void)parsingChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    for (AgoraRtmChannelAttribute *channelAttr in attributes) {
        NSDictionary *valueDict =   [DataTypeManager dictionaryWithJsonString:channelAttr.value];
        if ([channelAttr.key isEqualToString:@"teacher"]) {
            if (!self.teacherAttr) {
                self.teacherAttr = [[AETeactherModel alloc] init];
            }
            [self.teacherAttr modelWithDict:valueDict];
            self.teacherView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
            [self.teacherView updateSpeakerEnabled:self.teacherAttr.audio];
            [self.teacherView updateUserName:self.teacherAttr.account];
            if (!self.teacherAttr.video) {
                [self.teacherView.defaultImageView setImage:[UIImage imageNamed:@"video-close"]];
            }else {
                [self.teacherView.defaultImageView setHidden:YES];
            }
        }else if ([channelAttr.key isEqualToString:self.userId]) {
            self.ownAttrs = [AEStudentModel yy_modelWithDictionary:valueDict];
        }
    }
}

- (void)loadAgoraEngine {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit startPreview];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = 0;
    canvas.view = self.studentView.videoRenderView;
    [self.rtcEngineKit setupLocalVideo:canvas];
    self.studentView.defaultImageView.hidden = YES;
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if (![new isEqualToString:old]) {
        if ([keyPath isEqualToString:@"whiteboard_uid"]) {
            if (change[@"new"]) {
                [self joinWhiteBoardRoomUUID:change[@"new"] disableDevice:false];
            }
        }else if ([keyPath isEqualToString:@"class_state"]) {
            if ([new boolValue] == YES) {
                [self.navigationView startTimer];
            }else {
                [self.navigationView stopTimer];
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

- (void)addShareScreenVideoWithUid:(NSInteger)uid {
    self.shareScreenView.hidden = NO;
    self.shareScreenCanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.shareScreenCanvas.uid = uid;
    self.shareScreenCanvas.view = self.shareScreenView;
    self.shareScreenCanvas.renderMode = AgoraVideoRenderModeFit;
    [self.rtcEngineKit setupRemoteVideo:self.shareScreenCanvas];
}

- (IBAction)chatRoomViewShowAndHide:(UIButton *)sender {
    self.chatRoomViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.textFiledRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.chatRoomView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
}

- (void)teacherMuteStudentVideo:(BOOL)mute {
    [self.rtcEngineKit muteLocalVideoStream:mute];
    [self setChannelAttrsWithVideo:!mute audio:self.ownAttrs.audio];
    self.studentView.defaultImageView.hidden = mute ? NO : YES;
    [self.studentView updateCameraImageWithLocalVideoMute:mute];
}

- (void)teacherMuteStudentAudio:(BOOL)mute {
    [self.rtcEngineKit muteLocalAudioStream:mute];
    [self setChannelAttrsWithVideo:self.ownAttrs.video audio:!mute];
    [self.studentView updateMicImageWithLocalVideoMute:mute];
}

#pragma mark --------------------- Delegate  ---------------------
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
                   [weakself.messageListView addMessageModel:messageModel];
               }
        }];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)closeRoom {
    WEAK(self)
    [EEAlertView showAlertWithController:self title:@"是否退出房间？" sureHandler:^(UIAlertAction * _Nullable action) {
        [weakself.navigationView stopTimer];
        [weakself.rtcEngineKit stopPreview];
        [weakself.rtcEngineKit leaveChannel:nil];
        [weakself removeTeacherObserver];
        [weakself.room disconnect:^{
        }];
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [weakself.rtmKit deleteChannel:weakself.rtmChannelName AttributesByKeys:@[weakself.userId] Options:options completion:nil];
        [weakself.rtmChannel leaveWithCompletion:nil];
        [weakself dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (uid == [self.teacherAttr.uid integerValue]) {
        AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
        canvas.uid = uid;
        canvas.view = self.teacherView.videoRenderView;
        self.teacherView.defaultImageView.hidden = YES;
        [self.rtcEngineKit setupRemoteVideo:canvas];
        [self.teacherView updateUserName:self.teacherAttr.account];
    }else if(uid == kWhiteBoardUid){
        [self addShareScreenVideoWithUid:uid];
    }

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid == [self.teacherAttr.shared_uid integerValue]) {
        [self removeShareScreen];
    }else if (uid == [self.teacherAttr.uid integerValue]) {
        self.teacherView.defaultImageView.hidden = NO;
        [self.teacherView updateUserName:@""];
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
    [self.messageListView addMessageModel:messageModel];
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingChannelAttr:attributes];
}

- (void)channel:(AgoraRtmChannel *)channel memberLeft:(AgoraRtmMember *)member {
    if ([member.userId isEqualToString:self.teacherAttr.uid]) {
        self.teacherView.defaultImageView.hidden = NO;
        [self.teacherView updateUserName:@""];
        [self.teacherView updateSpeakerEnabled:NO];
    }else {
        self.studentView.defaultImageView.hidden = NO;
        [self.studentView updateUserName:@""];
    }
}

- (void)muteVideoStream:(BOOL)stream {
    [self.rtcEngineKit muteLocalVideoStream:stream];
    [self setChannelAttrsWithVideo:!stream audio:self.ownAttrs.audio];
    self.studentView.defaultImageView.hidden = stream ? NO : YES;
}

- (void)muteAudioStream:(BOOL)stream {
    [self.rtcEngineKit muteLocalAudioStream:stream];
    [self setChannelAttrsWithVideo:self.ownAttrs.video audio:!stream];
}

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"OneToOneViewController is dealloc");
}
@end
