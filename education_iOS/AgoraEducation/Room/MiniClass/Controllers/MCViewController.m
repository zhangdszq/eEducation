//
//  MCViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCViewController.h"
#import "EENavigationView.h"
#import "MCStudentVideoListView.h"
#import "MCTeacherVideoView.h"
#import "EEWhiteboardTool.h"
#import "EEColorShowView.h"
#import "EEPageControlView.h"
#import "AETeactherModel.h"
#import "AEStudentModel.h"
#import "EEChatTextFiled.h"
#import "AERoomMessageModel.h"
#import "EEMessageView.h"
#import "MCStudentListView.h"
#import "MCSegmentedView.h"
#import <Whiteboard/Whiteboard.h>
#import "AERTMMessageBody.h"
#import "AgoraHttpRequest.h"

#import "SignalManager.h"
#import "AEP2pMessageModel.h"

#define kLandscapeViewWidth    222
@interface MCViewController ()<AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate,WhiteCommonCallbackDelegate,WhiteRoomCallbackDelegate,AEClassRoomProtocol,SignalDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *studentVideoListView;
@property (weak, nonatomic) IBOutlet MCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;
@property (weak, nonatomic) IBOutlet MCStudentListView *studentListView;
@property (weak, nonatomic) IBOutlet MCSegmentedView *segmentedView;

@property (nonatomic, strong) AETeactherModel *teacherAttr;

@property (nonatomic, strong) NSArray<RolesStudentInfoModel*> *studentListArray;

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@end

@implementation MCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.studentListArray = [NSArray array];
    self.studentListView.userId = self.userId;

    [self loadAgoraRtcEngine];
    [self setUpView];
    [self selectSegmentIndex];
    [self setWhiteBoardBrushColor];
    [self addTeacherObserver];
    [self addNotification];

    
    WEAK(self)
    SignalManager.shareManager.messageDelegate = self;
    [SignalManager.shareManager joinChannelWithName:self.rtmChannelName completeSuccessBlock:^{
        
        NSString *value = [AERTMMessageBody setChannelAttrsWithValue: SignalManager.shareManager.currentStuModel];
        [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
            
            [weakself getRtmChannelAttrs];
            
        } completeFailBlock:nil];
        
    } completeFailBlock:nil];
}

- (void)getRtmChannelAttrs{
    WEAK(self)
    [SignalManager.shareManager queryGlobalStateWithChannelName:self.rtmChannelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
        
        [weakself updateTeacherStatusWithModel: rolesInfoModel.teactherModel];

        weakself.studentListArray = rolesInfoModel.studentModels;
        [weakself.studentListView updateStudentArray:weakself.studentListArray];
        [weakself.studentVideoListView updateStudentArray:weakself.studentListArray];
        
        [weakself setAllStudentVideoRender];
    }];
}

-(void)updateTeacherStatusWithModel:(AETeactherModel*)model{
 
    if(model != nil){
        [self.teacherAttr modelWithTeactherModel:model];
        self.teacherVideoView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
        NSString *imageName = self.teacherAttr.audio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
        [self.teacherVideoView updateSpeakerImageName:imageName];
    }
}
 
- (void)setUpView {
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self addWhiteBoardViewToView:self.whiteboardBaseView];
    self.boardView.frame = self.whiteboardBaseView.bounds;
    self.chatTextFiled.contentTextFiled.delegate = self;
    self.studentListView.delegate = self;
    self.navigationView.delegate = self;
    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    [self.navigationView updateChannelName:self.channelName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if (![new isEqualToString:old]) {
        if ([keyPath isEqualToString:@"uid"]) {
            NSUInteger uid = [new integerValue];
            if (uid > 0 ) {
                AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
                canvas.uid = uid;
                canvas.view = self.teacherVideoView.videoRenderView;
                self.teacherVideoView.defaultImageView.hidden = YES;
                [self.rtcEngineKit setRemoteVideoStream:uid type:(AgoraVideoStreamTypeLow)];
                [self.rtcEngineKit setupRemoteVideo:canvas];
                [self.teacherVideoView updateUserName:self.teacherAttr.account];
            }else {
                [self.teacherVideoView updateUserName:@""];
                self.teacherVideoView.defaultImageView.hidden = NO;
            }
        }else if ([keyPath isEqualToString:@"whiteboard_uid"]) {
            if (change[@"new"]) {
                [self joinWhiteBoardRoomUUID:change[@"new"] disableDevice:false];
            }
        }else if ([keyPath isEqualToString:@"mute_chat"]) {
            if ([change[@"new"] boolValue]) {
                self.chatTextFiled.contentTextFiled.enabled = NO;
                self.chatTextFiled.contentTextFiled.placeholder = @"禁言中";
            }else {
                self.chatTextFiled.contentTextFiled.enabled = YES;
                self.chatTextFiled.contentTextFiled.placeholder = @"说点什么";
            }
        }else if ([keyPath isEqualToString:@"class_state"]) {
            if ([new boolValue] == YES) {
                [self.navigationView startTimer];
            }else {
                [self.navigationView stopTimer];
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

- (void)setAllStudentVideoRender {
    WEAK(self)
    [self.studentVideoListView setStudentVideoList:^(UIView * _Nullable imageView, NSIndexPath * _Nullable indexPath) {
        
        RolesStudentInfoModel *roleInfoModel = weakself.studentListArray[indexPath.row];
        NSString *uid = roleInfoModel.attrKey;
        
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        videoCanvas.uid = [uid integerValue];
        videoCanvas.view = imageView;
        if ([uid isEqualToString:weakself.userId]) {
            [weakself.rtcEngineKit setupLocalVideo:videoCanvas];
        }else {
            [weakself.rtcEngineKit setRemoteVideoStream:[uid integerValue] type:(AgoraVideoStreamTypeLow)];
            [weakself.rtcEngineKit setupRemoteVideo:videoCanvas];
        }
    }];
}
- (void)selectSegmentIndex {
    WEAK(self)
    [self.segmentedView setSelectIndex:^(NSInteger index) {
        if (index == 0) {
            weakself.messageView.hidden = NO;
            weakself.chatTextFiled.hidden = NO;
            weakself.studentListView.hidden = YES;
        }else {
            weakself.messageView.hidden = YES;
            weakself.chatTextFiled.hidden = YES;
            weakself.studentListView.hidden = NO;
        }

    }];
}

- (void)loadAgoraRtcEngine {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit startPreview];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    [self.rtcEngineKit enableDualStreamMode:YES];
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:nil];
}

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
        
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onSignalReceived:) name:NOTICE_KEY_ON_SIGNAL_RECEIVED object:nil];
}

- (void)onSignalReceived:(NSNotification *)notification{
    AEP2pMessageModel *messageModel = [notification object];
    
    AEStudentModel *currentStuModel = [SignalManager.shareManager.currentStuModel yy_modelCopy];

    switch (messageModel.cmd) {
        case RTMp2pTypeMuteAudio:
        {
            currentStuModel.audio = 0;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteAudio:
        {
            currentStuModel.audio = 1;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeMuteVideo:
        {
            currentStuModel.video = 0;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteVideo:
        {
            currentStuModel.video = 1;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeApply:
        case RTMp2pTypeReject:
        case RTMp2pTypeAccept:
        case RTMp2pTypeCancel:
            break;
        case RTMp2pTypeMuteChat:
        {
            self.chatTextFiled.contentTextFiled.placeholder = @" 禁言中";
            self.chatTextFiled.contentTextFiled.enabled = NO;
            
            currentStuModel.chat = 0;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteChat:
        {
            self.chatTextFiled.contentTextFiled.placeholder = @" 说点什么";
            self.chatTextFiled.contentTextFiled.enabled = YES;
            
            currentStuModel.chat = 1;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        default:
            break;
    }
}


- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.chatTextFiledBottomCon.constant = bottom;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.chatTextFiledBottomCon.constant = 0;
    self.chatTextFiledWidthCon.constant = 222;
}

- (IBAction)messageViewshowAndHide:(UIButton *)sender {
    self.infoManagerViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.roomManagerView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
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
    
    NSString *content = textField.text;
    if (content.length > 0) {
        [SignalManager.shareManager sendMessageWithValue:content];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)closeRoom {
    WEAK(self)
    [EEAlertView showAlertWithController:self title:@"是否退出房间?" sureHandler:^(UIAlertAction * _Nullable action) {
        
        [weakself.navigationView stopTimer];
        [weakself.rtcEngineKit leaveChannel:nil];
        [weakself.room disconnect:^{
        }];
        [weakself removeTeacherObserver];

        [SignalManager.shareManager leaveChannel];
        
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark --------------------- RTC Delegate -------------------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    
    if (uid == [self.teacherAttr.uid integerValue]) {
    
    } else if (uid == kWhiteBoardUid){
        [self addShareScreenVideoWithUid:uid];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    
    if (uid == self.teacherAttr.uid.integerValue) {
        [self.teacherVideoView updateUserName:@""];
        self.teacherVideoView.defaultImageView.hidden = NO;
    } else if (uid == kWhiteBoardUid) {
        [self removeShareScreen];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey != %d", uid];
        self.studentListArray = [self.studentListArray filteredArrayUsingPredicate:predicate];
        [self.studentListView updateStudentArray:self.studentListArray];
        [self.studentVideoListView updateStudentArray:self.studentListArray];
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

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"joinchannel success");
}

- (void)muteAudioStream:(BOOL)stream {
    [self.rtcEngineKit enableLocalAudio:!stream];

    AEStudentModel *currentStuModel = [SignalManager.shareManager.currentStuModel yy_modelCopy];
    currentStuModel.audio = !stream ? 1 : 0;
    NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}
- (void)muteVideoStream:(BOOL)stream {
    [self.rtcEngineKit enableLocalVideo:!stream];
    
    AEStudentModel *currentStuModel = [SignalManager.shareManager.currentStuModel yy_modelCopy];
    currentStuModel.video = !stream ? 1 : 0;
    NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"MCViewController dealloc");
}

#pragma mark SignalDelegate
- (void)onUpdateMessage:(AERoomMessageModel *_Nonnull)roomMessageModel {
    [self.messageView addMessageModel:roomMessageModel];
}
- (void)onUpdateTeactherAttribute:(AETeactherModel *_Nullable)teactherModel {
    [self updateTeacherStatusWithModel: teactherModel];
}
- (void)onUpdateStudentsAttribute:(NSArray<RolesStudentInfoModel *> *)studentInfoModels {
    self.studentListArray = studentInfoModels;
    
    [self.studentListView updateStudentArray:self.studentListArray];
    [self.studentVideoListView updateStudentArray:self.studentListArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", self.userId];
    NSArray<RolesStudentInfoModel *> *filteredArray = [self.studentListArray filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        AEStudentModel *canvasStudentModel = filteredArray.firstObject.studentModel;
        if([canvasStudentModel.uid isEqualToString:self.userId]){
            [self.rtcEngineKit enableLocalVideo:canvasStudentModel.video == 0 ? NO : YES];
            [self.rtcEngineKit enableLocalAudio:canvasStudentModel.audio == 0 ? NO : YES];
        }
    }
}
@end
