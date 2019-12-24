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
#import <Whiteboard/Whiteboard.h>
#import "EEColorShowView.h"
#import "AgoraHttpRequest.h"

#import "SignalManager.h"
#import "AEP2pMessageModel.h"

@interface OneToOneViewController ()<UITextFieldDelegate, AEClassRoomProtocol, SignalDelegate, RTCDelegate>
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

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@end

@implementation OneToOneViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setUpView];
    [self setWhiteBoardBrushColor];
    [self addTeacherObserver];
    [self addNotification];
    [self loadAgoraEngine];
    
    [self.studentView updateUserName:self.userName];
    
    WEAK(self)
    SignalManager.shareManager.messageDelegate = self;
    [SignalManager.shareManager joinChannelWithName:self.rtmChannelName completeSuccessBlock:^{
            
        NSString *value = [AERTMMessageBody setChannelAttrsWithValue: SignalManager.shareManager.currentStuModel];
        [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
            
            [weakself getRtmChannelAttrs];
            
        } completeFailBlock:nil];
        
    } completeFailBlock:nil];
}

- (void)onSignalReceived:(NSNotification *)notification{
    AEP2pMessageModel *messageModel = [notification object];
    
    AEStudentModel *currentStuModel = [SignalManager.shareManager.currentStuModel yy_modelCopy];

    WEAK(self)
    switch (messageModel.cmd) {
        case RTMp2pTypeMuteAudio:
        {
            currentStuModel.audio = 0;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue: currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
                
//                [weakself teacherMuteStudentAudio:YES];

            } completeFailBlock:nil];
            
        }
            break;
        case RTMp2pTypeUnMuteAudio:
        {
            currentStuModel.audio = 1;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue: currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
                
//                [weakself teacherMuteStudentAudio:NO];

            } completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeMuteVideo:
        {
            currentStuModel.video = 0;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue: currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
//                 [weakself teacherMuteStudentVideo:YES];
            } completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteVideo:
        {
            currentStuModel.video = 1;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue: currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:^{
//                 [weakself teacherMuteStudentVideo:NO];
            } completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeApply:
        case RTMp2pTypeReject:
        case RTMp2pTypeAccept:
        case RTMp2pTypeCancel:
            break;
        case RTMp2pTypeMuteChat:
        {
            currentStuModel.chat = 0;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case RTMp2pTypeUnMuteChat:
        {
            currentStuModel.chat = 1;
            NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
            [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        default:
            break;
    }
}

- (void)setUpView {
    [self addWhiteBoardViewToView:self.whiteboardView];

    self.boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];

    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    [self.navigationView updateChannelName:self.channelName];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onSignalReceived:) name:NOTICE_KEY_ON_SIGNAL_RECEIVED object:nil];
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
    [SignalManager.shareManager queryGlobalStateWithChannelName:self.rtmChannelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
        
        [weakself updateTeacherStatusWithModel:rolesInfoModel.teactherModel];
    }];
}

-(void)updateTeacherStatusWithModel:(AETeactherModel*)model{
    if(model != nil){
        [self.teacherAttr modelWithTeactherModel:model];
        self.teacherView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
        [self.teacherView updateSpeakerEnabled:self.teacherAttr.audio];
        [self.teacherView updateUserName:self.teacherAttr.account];
        if (!self.teacherAttr.video) {
            [self.teacherView.defaultImageView setImage:[UIImage imageNamed:@"video-close"]];
        }else {
            [self.teacherView.defaultImageView setHidden:YES];
        }
    }
}

- (void)loadAgoraEngine {
    
    [self.educationManager initRTCEngineKitWithAppid:kAgoraAppid clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = 0;
    model.videoView = self.studentView.videoRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeLocal;
    [self.educationManager setupRTCVideoCanvas: model];
    
    [self.educationManager joinRTCChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:nil];
    
    self.studentView.defaultImageView.hidden = YES;
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
//            if ([change[@"new"] boolValue]) {
//                self.chatTextFiled.contentTextFiled.enabled = NO;
//                self.chatTextFiled.contentTextFiled.placeholder = @" 禁言中";
//            }else {
//                self.chatTextFiled.contentTextFiled.enabled = YES;
//                self.chatTextFiled.contentTextFiled.placeholder = @" 说点什么";
//            }
        }
    }
}

- (void)addShareScreenVideoWithUid:(NSInteger)uid {
    self.shareScreenView.hidden = NO;
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model];
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

//- (void)teacherMuteStudentVideo:(BOOL)mute {
//    [self.educationManager enableRTCLocalVideo:!mute];
//
//    self.studentView.defaultImageView.hidden = mute ? NO : YES;
//    [self.studentView updateCameraImageWithLocalVideoMute:mute];
//}
//
//- (void)teacherMuteStudentAudio:(BOOL)mute {
//    [self.educationManager enableRTCLocalAudio:!mute];
//
//    [self.studentView updateMicImageWithLocalVideoMute:mute];
//}

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
    [EEAlertView showAlertWithController:self title:@"是否退出房间？" sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [weakself removeTeacherObserver];
        [weakself.educationManager releaseResources];
        [SignalManager.shareManager leaveChannel];
        
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)stream {
//    [self.educationManager enableRTCLocalVideo:!stream];
//    self.studentView.defaultImageView.hidden = stream ? NO : YES;
    
    AEStudentModel *currentStuModel = [SignalManager.shareManager.currentStuModel yy_modelCopy];
    currentStuModel.video = !stream ? 1 : 0;
    NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (void)muteAudioStream:(BOOL)stream {
//    [self.educationManager enableRTCLocalAudio:!stream];
    
    AEStudentModel *currentStuModel = [SignalManager.shareManager.currentStuModel yy_modelCopy];
    currentStuModel.audio = !stream ? 1 : 0;
    NSString *value = [AERTMMessageBody setChannelAttrsWithValue:currentStuModel];
    [SignalManager.shareManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
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

#pragma mark SignalDelegate 
- (void)onUpdateMessage:(AERoomMessageModel *_Nonnull)roomMessageModel {
    [self.messageListView addMessageModel:roomMessageModel];
}
- (void)onUpdateTeactherAttribute:(AETeactherModel *_Nullable)teactherModel studentsAttribute:(NSArray<RolesStudentInfoModel *> *_Nullable)studentInfoModels {
    
    [self updateTeacherStatusWithModel:teactherModel];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", self.userId];
    NSArray<RolesStudentInfoModel *> *filteredArray = [studentInfoModels filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        
        AEStudentModel *canvasStudentModel = filteredArray.firstObject.studentModel;
        BOOL muteChat = teactherModel != nil ? teactherModel.mute_chat : NO;
        if(!muteChat) {
            muteChat = canvasStudentModel.chat == 0 ? YES : NO;
        }
        self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
        self.chatTextFiled.contentTextFiled.placeholder = muteChat ? @" 禁言中" : @" 说点什么";
        
        self.studentView.defaultImageView.hidden = canvasStudentModel.video == 0 ? NO : YES;
        [self.studentView updateCameraImageWithLocalVideoMute:canvasStudentModel.video == 0 ? YES : NO];
        [self.studentView updateMicImageWithLocalVideoMute:canvasStudentModel.audio == 0 ? YES : NO];
        
        [self.educationManager enableRTCLocalVideo:canvasStudentModel.video == 0 ? NO : YES];
        [self.educationManager enableRTCLocalAudio:canvasStudentModel.audio == 0 ? NO : YES];
    }
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    
    if (uid == [self.teacherAttr.uid integerValue]) {
        
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = uid;
        model.videoView = self.teacherView.videoRenderView;
        model.renderMode = RTCVideoRenderModeHidden;
        model.canvasType = RTCVideoCanvasTypeRemote;
        [self.educationManager setupRTCVideoCanvas:model];

        self.teacherView.defaultImageView.hidden = YES;
        [self.teacherView updateUserName:self.teacherAttr.account];
    }else if(uid == kWhiteBoardUid){
        [self addShareScreenVideoWithUid:uid];
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
//    if (uid == [self.teacherAttr.shared_uid integerValue]) {
    if (uid == kWhiteBoardUid) {
        self.shareScreenView.hidden = YES;
    } else if (uid == [self.teacherAttr.uid integerValue]) {
        self.teacherView.defaultImageView.hidden = NO;
        [self.teacherView updateUserName:@""];
        [self.teacherView updateSpeakerEnabled:NO];
    } else {
        self.studentView.defaultImageView.hidden = NO;
        [self.studentView updateUserName:@""];
    }
    
    [self.educationManager removeRTCVideoCanvas:uid];
}
- (void)rtcNetworkTypeGrade:(RTCNetworkGrade)grade {
    
    switch (grade) {
        case RTCNetworkGradeHigh:
            [self.navigationView updateSignalImageName:@"icon-signal3"];
            break;
        case RTCNetworkGradeMiddle:
            [self.navigationView updateSignalImageName:@"icon-signal2"];
            break;
        case RTCNetworkGradeLow:
            [self.navigationView updateSignalImageName:@"icon-signal1"];
            break;
        default:
            break;
    }
}
@end
