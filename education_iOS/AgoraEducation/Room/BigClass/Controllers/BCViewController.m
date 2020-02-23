
//
//  BigClassViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BCViewController.h"
#import "BCSegmentedView.h"
#import "EEChatTextFiled.h"
#import "BCStudentVideoView.h"
#import "EETeacherVideoView.h"
#import "BCNavigationView.h"

#import "GenerateSignalBody.h"
#import "SignalRoomModel.h"
#import "GenerateSignalBody.h"
#import "StudentModel.h"
#import "TeacherModel.h"
#import "EEMessageView.h"
#import "SignalP2PModel.h"

#import "SignalManager.h"

#import "KeyCenter.h"

#define kLandscapeViewWidth    223
@interface BCViewController ()<BCSegmentedDelegate, UITextFieldDelegate, RoomProtocol, SignalDelegate, RTCDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledRelativeTeacherViewLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;

@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet BCSegmentedView *segmentedView;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

// white
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, assign) NSInteger segmentedIndex;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) StudentLinkState linkState;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, assign) BOOL isLandscape;

@end

@implementation BCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
}

-(void)initData {
    
    self.segmentedView.delegate = self;
    self.studentVideoView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    [self.navigationView updateClassName:self.paramsModel.className];
    
    [self.educationManager initSessionModel];
    [self.educationManager setSignalDelegate:self];
    
    [self setupRTC];
    [self setupSignal];
}

- (void)setupRTC {
    
    [self.educationManager initRTCEngineKitWithAppid:[KeyCenter agoraAppid] clientRole:RTCClientRoleAudience dataSourceDelegate:self];
    [self.educationManager joinRTCChannelByToken:[KeyCenter agoraRTCToken] channelId:self.paramsModel.channelName info:nil uid:[self.paramsModel.userId integerValue] joinSuccess:nil];
}

- (void)setupSignal {
    
    WEAK(self);
    [self.educationManager joinSignalWithChannelName:self.paramsModel.channelName completeSuccessBlock:^{
        
        StudentModel *model = [StudentModel new];
        model.uid = weakself.paramsModel.userId;
        model.account = weakself.paramsModel.userName;
        model.video = 1;
        model.audio = 1;
        model.chat = 1;
        NSString *value = [GenerateSignalBody channelAttrsWithValue: model];
        [weakself.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
            
        } completeFailBlock:nil];
        
    } completeFailBlock:nil];
}

- (void)muteVideoStream:(BOOL)stream {
    StudentModel *currentStuModel = [self.educationManager.studentModel yy_modelCopy];
    currentStuModel.video = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (void)muteAudioStream:(BOOL)stream {
    StudentModel *currentStuModel = [self.educationManager.studentModel yy_modelCopy];
    currentStuModel.audio = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (void)checkNeedRender {
    
    NSString *teacherUid = self.educationManager.teacherModel.uid;
    if([self.educationManager.rtcUids containsObject:teacherUid]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", teacherUid.integerValue];
        NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
        if(filteredArray.count == 0){
            [self renderTeacherCanvas:teacherUid.integerValue];
        }
        [self updateTeacherViews:self.educationManager.teacherModel];
    } else {
        [self removeTeacherCanvas:teacherUid.integerValue];
    }
    
    NSString *studentUid = self.educationManager.teacherModel.link_uid;
    if([self.educationManager.rtcUids containsObject:studentUid]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uid == %d", studentUid.integerValue];
        NSArray<RTCVideoSessionModel *> *filteredArray = [self.educationManager.rtcVideoSessionModels filteredArrayUsingPredicate:predicate];
        
        BOOL remote = NO;
        if(filteredArray.count == 0){
            if (studentUid.integerValue == self.paramsModel.userId.integerValue) {
                [self renderStudentCanvas:studentUid.integerValue remoteVideo:remote];
            } else {
                remote = YES;
                [self renderStudentCanvas:studentUid.integerValue remoteVideo:remote];
            }
        }
        [self updateStudentViews:self.educationManager.renderStudentModel remoteVideo:remote];
    }
}


- (void)renderTeacherCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.teactherVideoView.teacherRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas: model];
}

- (void)removeTeacherCanvas:(NSUInteger)uid {
    
    self.teactherVideoView.defaultImageView.hidden = NO;
    [self.teactherVideoView updateAndsetTeacherName:@""];

    if (self.segmentedIndex == 0) {
        self.handUpButton.hidden = YES;
    }
    [self.teactherVideoView updateSpeakerImageWithMuted:YES];
    self.teactherVideoView.defaultImageView.hidden = NO;
    [self.teactherVideoView updateAndsetTeacherName:@""];
}

- (void)renderShareCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model];
    
    self.shareScreenView.hidden = NO;
}

- (void)removeShareCanvas:(NSUInteger)uid {
    self.shareScreenView.hidden = YES;
}

- (void)renderStudentCanvas:(NSUInteger)uid remoteVideo:(BOOL)remote {
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.studentVideoView.studentRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = remote ? RTCVideoCanvasTypeRemote : RTCVideoCanvasTypeLocal;
    [self.educationManager setupRTCVideoCanvas: model];

    [self.educationManager setRTCClientRole:RTCClientRoleBroadcaster];
}

- (void)removeStudentCanvas:(NSUInteger)uid {
    
    NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
    [self.educationManager.rtcUids removeObject: uidStr];
    
    [self.educationManager setRTCClientRole:RTCClientRoleAudience];
    [self.educationManager removeRTCVideoCanvas: uid];
    self.studentVideoView.defaultImageView.hidden = NO;
    self.studentVideoView.hidden = YES;
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
}


- (void)updateTeacherViews:(TeacherModel*)teacherModel {
    
    if(teacherModel == nil){
        return;
    }
    
    // update teacher views
    if (self.segmentedIndex == 0) {
        self.handUpButton.hidden = NO;
    }
    [self.teactherVideoView updateSpeakerImageWithMuted:!teacherModel.audio];
    self.teactherVideoView.defaultImageView.hidden = teacherModel.video ? YES : NO;
    [self.teactherVideoView updateAndsetTeacherName: teacherModel.account];
}

- (void)updateChatViews {
    BOOL muteChat = self.educationManager.teacherModel != nil ? self.educationManager.teacherModel.mute_chat : NO;
    if(self.educationManager.studentModel != nil){
        if(!muteChat) {
            muteChat = self.educationManager.studentModel.chat == 0 ? YES : NO;
        }
    }
    
    self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
    self.chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
}

- (void)updateStudentViews:(StudentModel *)studentModel remoteVideo:(BOOL)remote {
    
    if(studentModel == nil){
        return;
    }
    
    self.studentVideoView.hidden = NO;
    
    [self.studentVideoView setButtonEnabled:!remote];
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];

    [self.studentVideoView updateVideoImageWithMuted:studentModel.video == 0 ? YES : NO];
    [self.studentVideoView updateAudioImageWithMuted:studentModel.audio == 0 ? YES : NO];

    [self.educationManager enableRTCLocalVideo:studentModel.video == 0 ? NO : YES];
    [self.educationManager enableRTCLocalAudio:studentModel.audio == 0 ? NO : YES];
}

- (void)setupView {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
        
    WhiteBoardView *boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardView addSubview:boardView];
    self.boardView = boardView;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];

    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification{

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self verticalScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self landscapeScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        default:
            break;
    }
}

- (void)stateBarHidden:(BOOL)hidden {
    [self setNeedsStatusBarAppearanceUpdate];
    self.isLandscape = hidden;
}

- (IBAction)handUpEvent:(UIButton *)sender {
    
    NSInteger link_uid = self.educationManager.teacherModel.link_uid.integerValue;
    if(link_uid > 0 && link_uid != self.paramsModel.userId.integerValue) {
        return;
    }
    
    switch (self.linkState) {
        case StudentLinkStateIdle:
            [self studentApplyLink];
            break;
        case StudentLinkStateAccept:
            [self studentCancelLink];
            break;
        case StudentLinkStateApply:
            [self studentApplyLink];
            break;
        case StudentLinkStateReject:
            [self studentApplyLink];
            break;
        default:
            break;
    }
}

- (void)studentApplyLink {
    WEAK(self);
    [self.educationManager setSignalWithType:SignalP2PTypeApply completeSuccessBlock:^{
        weakself.linkState = StudentLinkStateApply;
    }];
}

- (void)studentCancelLink {
    WEAK(self);
    [self.educationManager setSignalWithType:SignalP2PTypeCancel completeSuccessBlock:^{
        weakself.linkState = StudentLinkStateIdle;
        [weakself removeStudentCanvas: weakself.educationManager.teacherModel.link_uid.integerValue];
    }];
}

- (void)teacherAcceptLink {
    WEAK(self);
    StudentModel *currentStuModel = [self.educationManager.studentModel yy_modelCopy];
    currentStuModel.audio = 1;
    currentStuModel.video = 1;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
        
        weakself.linkState = StudentLinkStateAccept;
        
        weakself.tipLabel.hidden = NO;
        
        [weakself.tipLabel setText: NSLocalizedString(@"AcceptRequestText", nil)];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakself.tipLabel.hidden = YES;
        });
        
    } completeFailBlock:nil];
}

- (void)landscapeScreenConstraints {
    [self stateBarHidden:YES];
    self.handUpButton.hidden = self.educationManager.teacherModel.uid.integerValue > 0 ? NO : YES;
    self.chatTextFiled.hidden = NO;
    self.messageView.hidden = NO;
}

- (void)verticalScreenConstraints {
    [self stateBarHidden:NO];
    self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.messageView.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.handUpButton.hidden = self.educationManager.teacherModel.uid.integerValue > 0 ? NO : YES;
}

#pragma mark Notification
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        self.chatTextFiledRelativeTeacherViewLeftCon.active = NO;
        
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.textFiledBottomConstraint.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledRelativeTeacherViewLeftCon.active = YES;
    self.textFiledBottomConstraint.constant = 0;
}

- (void)joinWhiteBoardRoomWithUID:(NSString *)uuid disableDevice:(BOOL)disableDevice {
    
    WEAK(self);
    [self.educationManager releaseWhiteResources];
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];
    [self.educationManager joinWhiteRoomWithUuid:uuid completeSuccessBlock:^(WhiteRoom * _Nullable room) {
        
        CMTime cmTime = CMTimeMakeWithSeconds(0, 100);
        [weakself.educationManager seekWhiteToTime:cmTime completionHandler:^(BOOL finished) {
        }];
        [weakself.educationManager disableWhiteDeviceInputs:disableDevice];
        [weakself.educationManager disableCameraTransform:weakself.educationManager.teacherModel.lock_board];
        [weakself.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
            [weakself.educationManager moveWhiteToContainer:sceneIndex];
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark BCSegmentedDelegate
- (void)selectedItemIndex:(NSInteger)index {

    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.handUpButton.hidden = self.educationManager.teacherModel.uid.integerValue > 0 ? NO: YES;
    }else {
        self.segmentedIndex = 1;
        self.messageView.hidden = NO;
        self.chatTextFiled.hidden = NO;
        self.handUpButton.hidden = YES;
        self.unreadMessageCount = 0;
        [self.segmentedView hiddeBadge];
    }
}

#pragma mark RoomProtocol
- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
        
        if (weakself.linkState == StudentLinkStateAccept) {
            [weakself.educationManager setSignalWithType:SignalP2PTypeCancel completeSuccessBlock:nil];
        }
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (BOOL)prefersStatusBarHidden {
    return self.isLandscape;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark SignalDelegate
- (void)signalDidReceived:(SignalP2PModel *)signalModel {

    StudentModel *currentStuModel = [self.educationManager.studentModel yy_modelCopy];
    
    switch (signalModel.cmd) {
        case SignalP2PTypeMuteAudio:
        {
            currentStuModel.audio = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteAudio:
        {
            currentStuModel.audio = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeMuteVideo:
        {
            currentStuModel.video = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteVideo:
        {
            currentStuModel.video = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeApply:
        case SignalP2PTypeReject:
        {
            self.linkState = StudentLinkStateReject;
        }
            break;
        case SignalP2PTypeAccept:
        {
            [self teacherAcceptLink];
        }
            break;
        case SignalP2PTypeCancel:
        {
            self.linkState = StudentLinkStateIdle;
            [self removeStudentCanvas: self.educationManager.teacherModel.link_uid.integerValue];
            [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
            
            self.tipLabel.hidden = NO;
            [self.tipLabel setText: NSLocalizedString(@"AcceptRequestText", nil)];
            WEAK(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakself.tipLabel.hidden = YES;
            });
        }
            break;
        case SignalP2PTypeMuteChat:
        {
            currentStuModel.chat = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteChat:
        {
            currentStuModel.chat = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        default:
            break;
    }
}

- (void)signalDidUpdateMessage:(SignalRoomModel *)messageModel {
    
    [self.messageView addMessageModel:messageModel];
    if (self.messageView.hidden == YES) {
        self.unreadMessageCount = self.unreadMessageCount + 1;
        [self.segmentedView showBadgeWithCount:(self.unreadMessageCount)];
    }
}

-(void)signalDidUpdateGlobalStateWithSourceModel:(RolesInfoModel *)sourceInfoModel currentModel:(RolesInfoModel *)currentInfoModel {
    
    // teacher
    {
        TeacherModel *sourceModel = sourceInfoModel.teacherModel;
        TeacherModel *currentModel = currentInfoModel.teacherModel;
        if(![sourceModel.whiteboard_uid isEqualToString:currentModel.whiteboard_uid]) {
            
            [self joinWhiteBoardRoomWithUID:currentModel.whiteboard_uid disableDevice:YES];
            
        } else if(currentModel.whiteboard_uid.length > 0){
                   
            [self.educationManager disableCameraTransform:currentModel.lock_board];
        }
    }
    
    // student
    {
        NSInteger sourceLink_uid = sourceInfoModel.teacherModel.link_uid.integerValue;
        NSInteger currentLink_uid = currentInfoModel.teacherModel.link_uid.integerValue;
        if(sourceLink_uid != currentLink_uid) {
            if(currentLink_uid > 0){
                
                NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)currentLink_uid];
                [self.educationManager.rtcUids addObject:uidStr];
                
            } else if(sourceLink_uid > 0) {
                [self removeStudentCanvas:sourceLink_uid];
            }
        }
    }
        
    [self updateChatViews];
    [self checkNeedRender];
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {

    if(uid == kShareScreenUid) {
        [self renderShareCanvas: uid];
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids addObject:uidStr];
        [self checkNeedRender];
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    
    if (uid == kShareScreenUid) {
        [self removeShareCanvas: uid];
    } else if (uid == [self.educationManager.teacherModel.uid integerValue]) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids removeObject:uidStr];
        [self removeTeacherCanvas: uid];
    } else {
        [self removeStudentCanvas: uid];
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
            [self.navigationView updateSignalImageName:@"icon-signal1"];
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
