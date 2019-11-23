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
#import "RoomMessageModel.h"
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

@interface OneToOneViewController ()<EEPageControlDelegate,EEWhiteboardToolDelegate,UITextFieldDelegate,AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,WhiteCommonCallbackDelegate,WhiteRoomCallbackDelegate,AEClassRoomProtocol>
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

@property (nonatomic, strong) AgoraRtmChannel *rtmChannel;
@property (nonatomic, strong) AETeactherModel *teacherAttr;
@property (nonatomic, strong) AEStudentModel *studentAttrs;

@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) AgoraRtmKit *rtmKit;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;

@property (nonatomic, strong) WhiteBoardView *boardView;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong, nullable) WhiteRoom *room;

@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
@property (nonatomic, strong) UIColor *pencilColor;
@property (nonatomic, strong) WhiteMemberState *memberState;
@property (nonatomic, assign) BOOL teacherInRoom;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, strong) AgoraRtcVideoCanvas *shareScreenCanvas;

@end

@implementation OneToOneViewController
- (void)setParams:(NSDictionary *)params {
    _params = params;
    if (params[@"rtmKit"]) {
        self.rtmKit = params[@"rtmKit"];
        self.channelName = params[@"channelName"];
        self.userName = params[@"userName"];
        self.userId = params[@"userId"];
        self.rtmChannelName = params[@"rtmChannelName"];
        NSLog(@"rtmChannelName-----  %@",self.rtmChannelName);
    }
}

- (void)getRtmChannelAttrs{
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingTheChannelAttr:attributes];
        [weakself addChannelAttrsWithVideo:YES audio:YES];
    }];

}

- (void)addChannelAttrsWithVideo:(BOOL)video audio:(BOOL)audio {
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

- (void)parsingTheChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {

    for (AgoraRtmChannelAttribute *channelAttr in attributes) {
        NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
        if ([channelAttr.key isEqualToString:@"teacher"]) {
            [self.teacherAttr modelWithDict:valueDict];
            [self.navigationView startTimer];
            if (!self.teacherAttr.video) {
                [self.teacherView.defaultImageView setImage:[UIImage imageNamed:@"video-close"]];
            }else {
                [self.teacherView.defaultImageView setHidden:YES];
            }
        }
    }
}

- (void)joinWhiteBoardRoomUUID:(NSString *)uuid {
    self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
    if (self.room) {
        [self.room disconnect:^{
        }];
    }
    WEAK(self)
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        [weakself.sdk joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
            weakself.room = room;
            [weakself getWhiteboardSceneInfo];
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
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",(long)weakself.sceneIndex,weakself.scenes.count]];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpView];
    [self addTeacherObserver];
    [self addNotification];
    [self loadAgoraEngine];
    [self joinRTMChannel];
    [self getRtmChannelAttrs];
    [self.studentView updateUserName:self.userName];

}

- (void)joinRTMChannel {
    self.rtmChannel  =  [self.rtmKit createChannelWithId:self.rtmChannelName delegate:self];
    [self.rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {

    }];
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
    self.boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardView addSubview:self.boardView];

    self.whiteboardTool.delegate = self;
    self.pageControlView.delegate = self;
    self.studentView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    [self.navigationView.closeButton addTarget:self action:@selector(closeRoom:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView updateChannelName:self.channelName];
    WEAK(self)

    self.colorShowView.selectColor = ^(NSString *colorString) {
        NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        weakself.memberState.strokeColor = colorArray;
        [weakself.room setMemberState:weakself.memberState];
    };
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

    self.studentAttrs = [[AEStudentModel alloc] initWithParams:[AERTMMessageBody paramsStudentWithUserId:self.userId name:self.userName video:video audio:audio]];
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

- (void)addTeacherObserver {
    self.teacherAttr = [[AETeactherModel alloc] init];
    [self.teacherAttr addObserver:self forKeyPath:@"shared_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"whiteboard_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"mute_chat" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)removeTeacherObserver {
    [self.teacherAttr removeObserver:self forKeyPath:@"shared_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"whiteboard_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"mute_chat"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if (![new isEqualToString:old]) {
        if ([keyPath isEqualToString:@"shared_uid"]) {
            NSUInteger shared_uid = [change[@"new"] integerValue];
            if (!self.shareScreenCanvas && shared_uid > 0) {
                [self addShareScreenVideoWithUid:shared_uid];
            }
        }else  if ([keyPath isEqualToString:@"whiteboard_uid"]) {
            if (change[@"new"]) {
                [self joinWhiteBoardRoomUUID:change[@"new"]];
            }
        }
    }
}

- (void)addShareScreenVideoWithUid:(NSInteger)uid {
    self.shareScreenView.hidden = NO;
    self.shareScreenCanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.shareScreenCanvas.uid = uid;
    self.shareScreenCanvas.view = self.shareScreenView;
    [self.rtcEngineKit setupLocalVideo:self.shareScreenCanvas];
}

- (void)removeShareScreen {
    self.shareScreenView.hidden = YES;
    self.shareScreenCanvas = nil;
}

- (void)closeRoom:(UIButton *)sender {
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

- (IBAction)hideAndShowChatRoomView:(UIButton *)sender {
    self.chatRoomViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.textFiledRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.chatRoomView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
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
            [weakself.messageListView addMessageModel:messageModel];
        }
    }];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
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
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = uid;
    if (uid == [self.teacherAttr.uid integerValue]) {
        canvas.view = self.teacherView.videoRenderView;
        self.teacherView.defaultImageView.hidden = YES;
    }else if(uid == [self.studentAttrs.userId integerValue]) {

    }else if(!self.shareScreenCanvas){
        [self addShareScreenVideoWithUid:uid];
    }
    [self.teacherView updateUserName:self.teacherAttr.account];
    [self.rtcEngineKit setupRemoteVideo:canvas];
}


- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid == [self.teacherAttr.shared_uid integerValue]) {
        [self removeShareScreen];
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

#pragma mark ------------------------- whiteboard Delegate ---------------------------
- (void)fireRoomStateChanged:(WhiteRoomState *)modifyState {
    if (modifyState.sceneState && modifyState.sceneState.scenes.count > self.scenes.count) {
        self.scenes = [NSArray arrayWithArray:modifyState.sceneState.scenes];
        self.sceneDirectory = @"/";
        self.sceneIndex = modifyState.sceneState.index;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",(long)self.sceneIndex+1,(long)self.scenes.count]];
    }
}

#pragma mark --------------------- RTM Delegate -------------------
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    NSDictionary *dict =  [JsonAndStringConversions dictionaryWithJsonString:message.text];
    RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
    messageModel.content = dict[@"content"];
    messageModel.name = dict[@"account"];
    messageModel.isSelfSend = NO;
    [self.messageListView addMessageModel:messageModel];
}
- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingTheChannelAttr:attributes];
    if (self.teacherAttr) {
        self.teacherView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
        [self.teacherView updateSpeakerEnabled:self.teacherAttr.audio];
        [self.teacherView updateUserName:self.teacherAttr.account];
    }
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {

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
    [self setChannelAttrsWithVideo:!stream audio:self.studentAttrs.audio];
}

- (void)muteAudioStream:(BOOL)stream {
    [self.rtcEngineKit muteLocalAudioStream:stream];
    [self setChannelAttrsWithVideo:self.studentAttrs.video audio:!stream];
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
