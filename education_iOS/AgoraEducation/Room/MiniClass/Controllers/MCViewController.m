//
//  MCViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCViewController.h"
#import "EENavigationView.h"
#import "MCStudentVideoListView.h"
#import "MCTeacherVideoView.h"
#import "EEWhiteboardTool.h"
#import "EEColorShowView.h"
#import "EEPageControlView.h"
#import "TeacherModel.h"
#import "StudentModel.h"
#import "EEChatTextFiled.h"
#import "SignalRoomModel.h"
#import "EEMessageView.h"
#import "MCStudentListView.h"
#import "MCSegmentedView.h"
#import <Whiteboard/Whiteboard.h>
#import "GenerateSignalBody.h"
#import "HttpManager.h"

#import "SignalManager.h"
#import "SignalP2PModel.h"
#import "MCStudentVideoCell.h"
#import "KeyCenter.h"

#define kLandscapeViewWidth    222
@interface MCViewController ()<UITextFieldDelegate,RoomProtocol, SignalDelegate, RTCDelegate, EEPageControlDelegate, EEWhiteboardToolDelegate, WhitePlayDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *studentVideoListView;
@property (weak, nonatomic) IBOutlet MCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;
@property (weak, nonatomic) IBOutlet MCStudentListView *studentListView;
@property (weak, nonatomic) IBOutlet MCSegmentedView *segmentedView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

// white
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (nonatomic, weak) WhiteBoardView *boardView;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, assign) NSInteger sceneCount;

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;

@end

@implementation MCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
}

- (void)initData {
    
    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;
        
    WEAK(self);
    [self.colorShowView setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray = [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        [weakself.educationManager setWhiteStrokeColor:colorArray];
    }];
    
    self.chatTextFiled.contentTextFiled.delegate = self;
    self.studentListView.delegate = self;
    self.navigationView.delegate = self;
    [self.navigationView updateClassName:self.paramsModel.className];
    
    self.studentListView.userId = self.paramsModel.userId;
    
    [self.educationManager setSignalDelegate:self];
    [self.educationManager initSessionModel];
    
    [self setupRTC];
    [self setupSignal];
    
    [self initSelectSegmentBlock];
    [self initStudentRenderBlock];
}

- (void)setupRTC {
    
    [self.educationManager initRTCEngineKitWithAppid:[KeyCenter agoraAppid] clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    
    WEAK(self);
    [self.educationManager joinRTCChannelByToken:[KeyCenter agoraRTCToken] channelId:self.paramsModel.channelName info:nil uid:[self.paramsModel.userId integerValue] joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [weakself.educationManager.rtcUids addObject:uidStr];
        [weakself checkNeedRender];
        
    }];
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
            weakself.sceneCount = sceneCount;
            weakself.sceneIndex = sceneIndex;
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
            [weakself.educationManager moveWhiteToContainer:sceneIndex];
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)updateTeacherViews:(TeacherModel*)teacherModel {
    if(teacherModel == nil){
        return;
    }
    
    // update teacher views
    self.teacherVideoView.defaultImageView.hidden = teacherModel.video ? YES : NO;
    NSString *imageName = teacherModel.audio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
    [self.teacherVideoView updateSpeakerImageName: imageName];
    [self.teacherVideoView updateUserName:teacherModel.account];
}

- (void)updateChatViews {
    BOOL muteChat = self.educationManager.teacherModel != nil ? self.educationManager.teacherModel.mute_chat : NO;
    if(!muteChat) {
        muteChat = self.educationManager.studentModel.chat == 0 ? YES : NO;
    }
    self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
    self.chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
}

- (void)updateStudentViews:(StudentModel*)studentModel {
    if(studentModel == nil){
        return;
    }
    
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
    [self.whiteboardBaseView addSubview:boardView];
    self.boardView = boardView;
    boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardBaseView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
    
    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    
    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
}

- (void)initStudentRenderBlock {
    WEAK(self);
    [self.studentVideoListView setStudentVideoList:^(MCStudentVideoCell * _Nonnull cell, NSString * _Nullable currentUid) {

        if(currentUid == nil){
            return;
        }
               
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = currentUid.integerValue;
        model.videoView = cell.videoCanvasView;
        model.renderMode = RTCVideoRenderModeHidden;

        if ([currentUid isEqualToString:weakself.paramsModel.userId]) {
           model.canvasType = RTCVideoCanvasTypeLocal;
           [weakself.educationManager setupRTCVideoCanvas:model];
        } else {
           model.canvasType = RTCVideoCanvasTypeRemote;
           [weakself.educationManager setRTCRemoteStreamWithUid:model.uid type:RTCVideoStreamTypeLow];
           [weakself.educationManager setupRTCVideoCanvas:model];
        }
    }];
}

- (void)initSelectSegmentBlock {
    WEAK(self);
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

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.chatTextFiledBottomCon.constant = bottom;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
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
    
    [self reloadStudentViews];
}

- (void)renderTeacherCanvas:(NSUInteger)uid {
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.teacherVideoView.videoRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setRTCRemoteStreamWithUid:model.uid type:RTCVideoStreamTypeLow];
    [self.educationManager setupRTCVideoCanvas: model];
}

- (void)removeTeacherCanvas:(NSUInteger)uid {
    self.teacherVideoView.defaultImageView.hidden = NO;
    [self.teacherVideoView updateUserName:@""];
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

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {
        
        [weakself.navigationView stopTimer];
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
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
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)reloadStudentViews {
    self.educationManager.studentListArray = [NSMutableArray array];
    for (RolesStudentInfoModel *studentInfoModel in self.educationManager.studentTotleListArray) {
        if([self.educationManager.rtcUids containsObject:studentInfoModel.attrKey]){
            [self.educationManager.studentListArray addObject:studentInfoModel];
        }
    }
    
    [self.studentListView updateStudentArray:self.educationManager.studentListArray];
    [self.studentVideoListView updateStudentArray:self.educationManager.studentListArray];
    
    [self updateStudentViews:self.educationManager.studentModel];
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
        case SignalP2PTypeAccept:
        case SignalP2PTypeCancel:
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
        case SignalP2PTypeMuteBoard:
        {
            currentStuModel.grant_board = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
            
            WEAK(self);
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
                weakself.tipLabel.hidden = NO;
                [weakself.tipLabel setText:NSLocalizedString(@"MuteBoardText", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakself.tipLabel.hidden = YES;
                });

            } completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteBoard:
        {
            currentStuModel.grant_board = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
            WEAK(self);
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
                
                weakself.tipLabel.hidden = NO;
                [weakself.tipLabel setText:NSLocalizedString(@"UnMuteBoardText", nil)];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakself.tipLabel.hidden = YES;
                });
                            
            } completeFailBlock:nil];
        }
            break;
        default:
            break;
    }
}
- (void)signalDidUpdateMessage:(SignalRoomModel *_Nonnull)roomMessageModel {
    [self.messageView addMessageModel:roomMessageModel];
}

-(void)signalDidUpdateGlobalStateWithSourceModel:(RolesInfoModel *)sourceInfoModel currentModel:(RolesInfoModel *)currentInfoModel {
    
    // teacher
    {
        TeacherModel *sourceModel = sourceInfoModel.teacherModel;
        TeacherModel *currentModel = currentInfoModel.teacherModel;
        
        if(![sourceModel.whiteboard_uid isEqualToString:currentModel.whiteboard_uid]) {
            
            [self joinWhiteBoardRoomWithUID:currentModel.whiteboard_uid disableDevice:!self.educationManager.studentModel.grant_board];
            
        } else if(currentModel.whiteboard_uid.length > 0){
            [self.educationManager disableWhiteDeviceInputs:!self.educationManager.studentModel.grant_board];
            [self.educationManager disableCameraTransform:currentModel.lock_board];
        }
        
        if(sourceModel.class_state != currentModel.class_state) {
            currentModel.class_state ? [self.navigationView startTimer] : [self.navigationView stopTimer];
        }
    }
    
    // student
    {
        self.educationManager.studentTotleListArray = currentInfoModel.studentModels;
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
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.educationManager.rtcUids removeObject: uidStr];
        [self reloadStudentViews];
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

#pragma mark EEPageControlDelegate
- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        }];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.sceneCount - 1  && self.sceneCount > 0) {
        self.sceneIndex ++;
        
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        }];
    }
}

- (void)lastPage {
    self.sceneIndex = self.sceneCount - 1;
    
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, (long)weakself.sceneCount]];
    }];
}

- (void)firstPage {
    self.sceneIndex = 0;
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
    }];
}

-(void)setWhiteSceneIndex:(NSInteger)sceneIndex completionSuccessBlock:(void (^ _Nullable)(void ))successBlock {
    
    [self.educationManager setWhiteSceneIndex:sceneIndex completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            NSLog(@"Set scene index err：%@", error);
        }
    }];
}

#pragma mark EEWhiteboardToolDelegate
- (void)selectWhiteboardToolIndex:(NSInteger)index {
    
    NSArray<NSString *> *applianceNameArray = @[ApplianceSelector, AppliancePencil, ApplianceText, ApplianceEraser];
    if(index < applianceNameArray.count) {
        NSString *applianceName = [applianceNameArray objectAtIndex:index];
        if(applianceName != nil) {
            [self.educationManager setWhiteApplianceName:applianceName];
        }
    }
    
    BOOL bHidden = self.colorShowView.hidden;
    // select color
    if (index == 4) {
        self.colorShowView.hidden = !bHidden;
    } else if (!bHidden) {
        self.colorShowView.hidden = YES;
    }
}

#pragma mark WhitePlayDelegate
- (void)whiteRoomStateChanged {
    WEAK(self);
    [self.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
        weakself.sceneCount = sceneCount;
        weakself.sceneIndex = sceneIndex;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        [weakself.educationManager moveWhiteToContainer:sceneIndex];
    }];
}
@end
