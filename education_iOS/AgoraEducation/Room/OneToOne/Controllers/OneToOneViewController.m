//
//  OneToOneViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "OneToOneViewController.h"

#import "EENavigationView.h"
#import "EEWhiteboardTool.h"
#import "EEPageControlView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "EEColorShowView.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"

#import "GenerateSignalBody.h"
#import "TeacherModel.h"
#import "StudentModel.h"
#import "SignalRoomModel.h"
#import "SignalP2PModel.h"

@interface OneToOneViewController ()<UITextFieldDelegate, RoomProtocol, SignalDelegate, RTCDelegate>
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

@property (nonatomic, strong) TeacherModel *teacherModel;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;

@end

@implementation OneToOneViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupView];
    [self initData];
    [self addNotification];
}

- (void)initData {
    
    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    [self.navigationView updateClassName:self.paramsModel.className];
    
    self.teacherModel = [TeacherModel new];
    
    [self setupRTC];
    [self setupSignal];
}

- (void)setupView {
    
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardBaseView addSubview:boardView];
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
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
//    WEAK(self);
//    [self.educationManager queryGlobalStateWithChannelName:self.paramsModel.channelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
//        [weakself updateTeacherStatusWithModel:rolesInfoModel.teacherModel];
//    }];
}

- (void)updateTeacherStatusWithModel:(TeacherModel*)currentModel{
    
    if(currentModel == nil) {
        return;
    }
    
    if(self.teacherModel.whiteboard_uid != currentModel.whiteboard_uid) {
        [self joinWhiteBoardRoomUUID:currentModel.whiteboard_uid disableDevice:NO];
    }
    
    if(self.teacherModel.class_state != currentModel.class_state) {
        currentModel.class_state ? [self.navigationView startTimer] : [self.navigationView stopTimer];
    }
    
    // update teacher views
    self.teacherView.defaultImageView.hidden = currentModel.video ? YES : NO;
    [self.teacherView updateSpeakerEnabled:currentModel.audio];
    if (!currentModel.video) {
        [self.teacherView.defaultImageView setImage:[UIImage imageNamed:@"video-close"]];
    } else {
        [self.teacherView.defaultImageView setHidden:YES];
    }
    
    // reset value
    self.teacherModel = [currentModel yy_modelCopy];
}

- (void)updateStudentStatusWithModel:(NSArray<RolesStudentInfoModel *> *)studentInfoModels {

    if(studentInfoModels == nil) {
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", self.paramsModel.userId];
    NSArray<RolesStudentInfoModel *> *filteredArray = [studentInfoModels filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        
        StudentModel *canvasStudentModel = filteredArray.firstObject.studentModel;
        BOOL muteChat = self.teacherModel != nil ? self.teacherModel.mute_chat : NO;
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

- (void)setupSignal {
    WEAK(self);
    [self.educationManager joinSignalWithChannelName:self.paramsModel.channelName completeSuccessBlock:^{
        
        NSString *value = [GenerateSignalBody channelAttrsWithValue: weakself.educationManager.currentStuModel];
        [weakself.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
            
            [weakself getRtmChannelAttrs];
            
        } completeFailBlock:nil];
        
    } completeFailBlock:nil];
}

- (void)setupRTC {
    
    [self.educationManager initRTCEngineKitWithAppid:[KeyCenter agoraAppid] clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    
    WEAK(self);
    [self.educationManager joinRTCChannelByToken:[KeyCenter agoraRTCToken] channelId:self.paramsModel.channelName info:nil uid:[self.paramsModel.userId integerValue] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = uid;
        model.videoView = weakself.studentView.videoRenderView;
        model.renderMode = RTCVideoRenderModeHidden;
        model.canvasType = RTCVideoCanvasTypeLocal;
        [weakself.educationManager setupRTCVideoCanvas: model];
        
        weakself.studentView.defaultImageView.hidden = YES;
        [weakself.studentView updateUserName:weakself.paramsModel.userName];
    }];
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

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:@"是否退出房间？" sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)stream {
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.video = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (void)muteAudioStream:(BOOL)stream {
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.audio = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark SignalDelegate
- (void)signalDidReceived:(SignalP2PModel *)signalModel {
    [self handleSignalWithModel:signalModel];
}

- (void)signalDidUpdateMessage:(SignalRoomModel *_Nonnull)roomMessageModel {
    [self.messageListView addMessageModel:roomMessageModel];
}

- (void)signalDidUpdateGlobalState:(RolesInfoModel * _Nullable)infoModel {
    [self updateTeacherStatusWithModel:infoModel.teacherModel];
    [self updateStudentStatusWithModel: infoModel.studentModels];
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    
    if (uid == [self.educationManager.currentTeaModel.uid integerValue]) {
        
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = uid;
        model.videoView = self.teacherView.videoRenderView;
        model.renderMode = RTCVideoRenderModeHidden;
        model.canvasType = RTCVideoCanvasTypeRemote;
        [self.educationManager setupRTCVideoCanvas:model];

        self.teacherView.defaultImageView.hidden = YES;
        [self.teacherView updateUserName:self.educationManager.currentTeaModel.account];
        
    } else if(uid == kShareScreenUid){

        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = uid;
        model.videoView = self.shareScreenView;
        model.renderMode = RTCVideoRenderModeFit;
        model.canvasType = RTCVideoCanvasTypeRemote;
        [self.educationManager setupRTCVideoCanvas:model];
        
        self.shareScreenView.hidden = NO;
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    
    if (uid == [self.teacherModel.uid integerValue]) {
        
        self.teacherView.defaultImageView.hidden = NO;
        [self.teacherView updateUserName:@""];
        [self.teacherView updateSpeakerEnabled:NO];
        
    } else if (uid == kShareScreenUid) {
        
        self.shareScreenView.hidden = YES;
        
    } else {
        
        self.studentView.defaultImageView.hidden = NO;
        [self.studentView updateUserName:@""];
    }
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

#pragma mark UITextFieldDelegate
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
        [self.educationManager sendMessageWithContent:content userName:self.paramsModel.userName];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}
@end
