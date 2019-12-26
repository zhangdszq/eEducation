//
//  BigClassViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCViewController.h"
#import "BCSegmentedView.h"
#import "EEPageControlView.h"
#import "EEWhiteboardTool.h"
#import "EEChatTextFiled.h"
#import "BCStudentVideoView.h"
#import <Whiteboard/Whiteboard.h>
#import "HttpManager.h"
#import "MainViewController.h"
#import "GenerateSignalBody.h"
#import "SignalRoomModel.h"
#import "EEColorShowView.h"
#import "GenerateSignalBody.h"
#import "StudentModel.h"
#import "TeactherModel.h"
#import "EEMessageView.h"
#import "SignalP2PModel.h"

#import "SignalManager.h"

#define kLandscapeViewWidth    223
@interface BCViewController ()<BCSegmentedDelegate ,UITextFieldDelegate,RoomProtocol, SignalDelegate, RTCDelegate>
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareScreenTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareScreenRightCon;


@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic, weak) UIButton *closeButton;
@property (weak, nonatomic) IBOutlet EETeacherVideoView *teactherVideoView;
@property (weak, nonatomic) IBOutlet BCStudentVideoView *studentVideoView;
@property (weak, nonatomic) IBOutlet BCSegmentedView *segmentedView;
@property (nonatomic, assign) NSInteger segmentedIndex;
@property (weak, nonatomic) IBOutlet BCNavigationView *navigationView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;

@property (nonatomic, strong) NSArray<RolesStudentInfoModel*> *studentList;
@property (nonatomic, strong) TeactherModel *teacherAttr;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, assign) StudentLinkState linkState;
@property (nonatomic, strong) NSMutableArray *channelAttrs;

@property (nonatomic, assign) NSUInteger linkUserId;
@property (nonatomic, assign) BOOL teacherInRoom;
@property (nonatomic, strong) AgoraRtcVideoCanvas *studentCanvas;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isLandscape;
@end

@implementation BCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
    [self addTeacherObserver];
}

-(void)initData {
    
    self.segmentedView.delegate = self;
    self.studentVideoView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    self.studentList = [NSArray array];
    [self.navigationView updateClassName:self.paramsModel.className];
    
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
        
        StudentModel *currentStuModel = [weakself.educationManager.currentStuModel yy_modelCopy];
        currentStuModel.audio = 0;
        currentStuModel.video = 0;
        currentStuModel.chat = 1;
        NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
        [weakself.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
            
            [weakself getRtmChannelAttrs];
            
        } completeFailBlock:nil];
        
    } completeFailBlock:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    if (duration == UIDeviceOrientationLandscapeLeft || duration == UIDeviceOrientationLandscapeRight) {
        [self stateBarHidden:YES];
        [self landscapeScreenConstraints];
    }else {
        [self stateBarHidden:NO];
        [self verticalScreenConstraints];
    }
}

- (void)getRtmChannelAttrs{

//    WEAK(self);
//    [self.educationManager queryGlobalStateWithChannelName:self.paramsModel.channelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
//
//        [weakself updateTeacherStatusWithModel:rolesInfoModel.teactherModel];
//
//        weakself.studentList = rolesInfoModel.studentModels;
//    }];
}

-(void)updateTeacherStatusWithModel:(TeactherModel*)model{
 
    if(model != nil){
        [self.teacherAttr modelWithTeactherModel:model];
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = NO;
            self.pageControlView.hidden = NO;
        }
        [self.teactherVideoView updateSpeakerImageWithMuted:!self.teacherAttr.audio];
        self.teactherVideoView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
        [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
    }
}

- (void)setupView {
    [self addWhiteBoardViewToView:self.whiteboardView];
    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    self.handUpButton.layer.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"].CGColor;
    self.handUpButton.layer.cornerRadius = 6;

//    [GenerateSignalBody addShadowWithView:self.handUpButton alpha:0.1];
    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
//    [GenerateSignalBody addShadowWithView:self.tipLabel alpha:0.25];
}

//- (void)addShadowWithView:(UIView *)view alpha:(CGFloat)alpha {
//    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:alpha].CGColor;
//    view.layer.shadowOffset = CGSizeMake(0,2);
//    view.layer.shadowOpacity = 2;
//    view.layer.shadowRadius = 4;
//    view.layer.masksToBounds = YES;
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if ([keyPath isEqualToString:@"uid"]) {
        NSUInteger uid = [change[@"new"] integerValue];
        if (uid > 0 ) {
            RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
            model.uid = uid;
            model.videoView = self.teactherVideoView.teacherRenderView;
            model.renderMode = RTCVideoRenderModeHidden;
            model.canvasType = RTCVideoCanvasTypeRemote;
            [self.educationManager setupRTCVideoCanvas: model];

            self.teacherInRoom = YES;
            self.teactherVideoView.defaultImageView.hidden = YES;
        }
    } else if ([keyPath isEqualToString:@"account"]) {
        [self.teactherVideoView updateAndsetTeacherName:self.teacherAttr.account];
    } else if ([keyPath isEqualToString:@"link_uid"]) {
        self.linkUserId = [new integerValue];
        if (self.linkUserId > 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", new];
            NSArray<RolesStudentInfoModel *> *filteredArray = [self.studentList filteredArrayUsingPredicate:predicate];
            if(filteredArray.count > 0){
//                StudentModel *studentModel = filteredArray.firstObject.studentModel;
//                [self.studentVideoView updateVideoImageWithMuted:NO];
//                [self.studentVideoView updateAudioImageWithMuted:NO];
                if (self.linkUserId == [self.paramsModel.userId integerValue]) {
                    [self.studentVideoView setButtonEnabled:YES];
                    [self addStudentVideoWithUid:self.linkUserId remoteVideo:NO];
                } else {
                    [self.studentVideoView setButtonEnabled:NO];
                    [self addStudentVideoWithUid:self.linkUserId remoteVideo:YES];
                }
            } else {
                [self removeStudentVideo];
            }
        }else {
            [self removeStudentVideo];
        }
    }

    if (![new isEqualToString:old]) {
        if ([keyPath isEqualToString:@"whiteboard_uid"]) {
            if (change[@"new"]) {
                [self joinWhiteBoardRoomUUID:change[@"new"] disableDevice:true];
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

- (void)addStudentVideoWithUid:(NSInteger)uid remoteVideo:(BOOL)remote {
    self.studentVideoView.hidden = NO;
    if (!self.studentCanvas || uid != self.studentCanvas.uid) {
        
        [self.educationManager setRTCClientRole:RTCClientRoleBroadcaster];
        
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = uid;
        model.videoView = self.studentVideoView.studentRenderView;
        model.renderMode = RTCVideoRenderModeHidden;
        model.canvasType = remote ? RTCVideoCanvasTypeRemote : RTCVideoCanvasTypeLocal;
        [self.educationManager setupRTCVideoCanvas: model];
        
        self.studentVideoView.defaultImageView.hidden = YES;
        [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup-x"] forState:(UIControlStateNormal)];
    }
}

- (void)removeStudentVideo {
    [self.educationManager setRTCClientRole:RTCClientRoleAudience];
    
    self.studentVideoView.defaultImageView.hidden = NO;
    self.studentVideoView.hidden = YES;
    self.studentCanvas = nil;
    [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
    [self.messageView updateTableView];
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self stateBarHidden:NO];
            [self verticalScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
        {
            [self stateBarHidden:YES];
            [self landscapeScreenConstraints];
            [self.view layoutIfNeeded];
            [self.educationManager refreshWhiteViewSize];
        }
            break;
        default:
            NSLog(@"设备方向无法辨识");
            break;
    }
}

- (void)stateBarHidden:(BOOL)hidden {
    self.statusBarHidden = hidden;
    [self setNeedsStatusBarAppearanceUpdate];
    self.isLandscape = hidden; // 横屏隐藏
}

- (IBAction)handUpEvent:(UIButton *)sender {
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
        [weakself removeStudentVideo];
    }];
}

- (void)teacherAcceptLink {
    WEAK(self);
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.audio = 1;
    currentStuModel.video = 1;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:^{
        
        weakself.linkState = StudentLinkStateAccept;
        
        weakself.tipLabel.hidden = NO;
        [weakself.tipLabel setText:[NSString stringWithFormat:@"%@接受了你的连麦申请!",self.teacherAttr.account]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakself.tipLabel.hidden = YES;
        });
        
    } completeFailBlock:nil];
}

- (void)landscapeScreenConstraints {
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
    self.whiteboardViewRightCon.constant = -kLandscapeViewWidth;
    self.shareScreenRightCon.constant = kLandscapeViewWidth;
    self.whiteboardViewTopCon.constant = 0;
    self.shareScreenTopCon.constant = 0;
    self.teacherVideoViewHeightCon.constant = 125;
    self.studentVideoViewLeftCon.constant = 66;
    self.studentViewHeightCon.constant = 85;
    self.studentViewWidthCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    CGFloat boardViewWidth = isIphoneX ? MAX(kScreenHeight, kScreenWidth) - 311 : MAX(kScreenHeight, kScreenWidth) - kLandscapeViewWidth;
    [self setBoardViewFrame:CGRectMake(0, 0,boardViewWidth , MIN(kScreenWidth, kScreenHeight) - 30)];
}

- (void)verticalScreenConstraints {
    self.chatTextFiled.hidden = self.segmentedIndex == 0 ? YES : NO;
    self.messageView.hidden = self.segmentedIndex == 0 ? YES : NO;
//    self.whiteboardView.hidden = self.segmentedIndex == 0 ? NO : YES;
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
    self.shareScreenRightCon.constant = 0;
    self.whiteboardViewTopCon.constant = 257;
    self.shareScreenTopCon.constant = 257;
    self.teacherVideoViewHeightCon.constant = 213;
    self.studentVideoViewLeftCon.constant = kScreenWidth - 100;
    self.studentViewWidthCon.constant = 85;
    self.studentViewHeightCon.constant = 120;
    [self.view bringSubviewToFront:self.studentVideoView];
    [self setBoardViewFrame:CGRectMake(0, 0, MIN(kScreenWidth, kScreenHeight), MAX(kScreenHeight, kScreenWidth) - 257 - navigationBarHeight)];
}
#pragma mark ---------------------------- Notification ----------------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = (isIphoneX && self.isLandscape) ? kScreenWidth - 44 : kScreenWidth;
        self.textFiledBottomConstraint.constant = bottom;
    }
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textFiledBottomConstraint.constant = 0;
    self.chatTextFiledWidthCon.constant = self.isLandscape ? kLandscapeViewWidth : MIN(kScreenHeight, kScreenWidth);
}

#pragma mark ---------------------------- Delegate ----------------------------
- (void)selectedItemIndex:(NSInteger)index {
    if (self.colorShowView.hidden == NO) {
        self.colorShowView.hidden = YES;
    }
    if (index == 0) {
        self.segmentedIndex = 0;
        self.messageView.hidden = YES;
        self.chatTextFiled.hidden = YES;
        self.pageControlView.hidden = self.teacherInRoom ? NO: YES;
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

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:@"是否退出房间?" sureHandler:^(UIAlertAction * _Nullable action) {
        
        if (weakself.linkState == StudentLinkStateAccept) {
            [weakself.educationManager setSignalWithType:SignalP2PTypeCancel completeSuccessBlock:nil];
        }
        [weakself removeTeacherObserver];
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

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

- (void)muteVideoStream:(BOOL)stream {
    [self.educationManager enableRTCLocalVideo:!stream];
    
    self.studentVideoView.defaultImageView.hidden = stream ? NO : YES;
    
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.video = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (void)muteAudioStream:(BOOL)stream {
    
    [self.educationManager enableRTCLocalAudio:!stream];
    
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.audio = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)dealloc {
    NSLog(@"BCViewController is Dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark SignalDelegate
- (void)signalDidReceived:(SignalP2PModel *)signalModel {

    [self handleSignalWithModel:signalModel];
    
    switch (signalModel.cmd) {
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
            self.whiteboardTool.hidden = YES;
            self.linkState = StudentLinkStateIdle;
            [self removeStudentVideo];
            [self.handUpButton setBackgroundImage:[UIImage imageNamed:@"icon-handup"] forState:(UIControlStateNormal)];
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
- (void)signalDidUpdateGlobalState:(RolesInfoModel * _Nullable)infoModel {
    TeactherModel *teactherModel = infoModel.teactherModel;
    NSArray<RolesStudentInfoModel *> *studentInfoModels = infoModel.studentModels;

    [self updateTeacherStatusWithModel:teactherModel];
    
    self.studentList = studentInfoModels;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", self.paramsModel.userId];
    NSArray<RolesStudentInfoModel *> *filteredArray = [self.studentList filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        
        StudentModel *canvasStudentModel = filteredArray.firstObject.studentModel;
        BOOL muteChat = teactherModel != nil ? teactherModel.mute_chat : NO;
        if(!muteChat) {
            muteChat = canvasStudentModel.chat == 0 ? YES : NO;
        }
        self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
        self.chatTextFiled.contentTextFiled.placeholder = muteChat ? @" 禁言中" : @" 说点什么";
        
        [self.studentVideoView updateVideoImageWithMuted:canvasStudentModel.video == 0 ? YES : NO];
        [self.studentVideoView updateAudioImageWithMuted:canvasStudentModel.audio == 0 ? YES : NO];

        [self.educationManager enableRTCLocalVideo:canvasStudentModel.video == 0 ? NO : YES];
        [self.educationManager enableRTCLocalAudio:canvasStudentModel.audio == 0 ? NO : YES];
    }
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    
    if (uid == [self.teacherAttr.uid integerValue]) {
        
    } else if (uid == kWhiteBoardUid) {
        [self addShareScreenVideoWithUid:uid];
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

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    if (uid == self.teacherAttr.uid.integerValue) {
        self.teacherInRoom = NO;
        self.teactherVideoView.defaultImageView.hidden = NO;
        [self.teactherVideoView updateAndsetTeacherName:@""];
        
        if (self.segmentedIndex == 0) {
            self.handUpButton.hidden = YES;
            self.pageControlView.hidden = YES;
        }
        [self.teactherVideoView updateSpeakerImageWithMuted:YES];
        self.teactherVideoView.defaultImageView.hidden = NO;
        [self.teactherVideoView updateAndsetTeacherName:@""];
        
    } else if (uid == kWhiteBoardUid) {
        self.shareScreenView.hidden = YES;
    } else {
        if(self.studentCanvas != nil && self.studentCanvas.uid == uid) {
            [self removeStudentVideo];
        }
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
