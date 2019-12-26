//
//  OneToOneViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//
// 1V1 注意分享屏幕就可以

#import "OneToOneViewController.h"
#import "EENavigationView.h"
#import "EEWhiteboardTool.h"
#import "EEPageControlView.h"
#import "EEChatTextFiled.h"
#import "SignalRoomModel.h"
#import "EEMessageView.h"
#import "TeactherModel.h"
#import "GenerateSignalBody.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "GenerateSignalBody.h"
#import "StudentModel.h"
#import <Whiteboard/Whiteboard.h>
#import "EEColorShowView.h"
#import "HttpManager.h"

#import "SignalManager.h"
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

@property (nonatomic, strong) TeactherModel *teacherAttr;

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@end

@implementation OneToOneViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setupView];
    [self initData];
    [self addTeacherObserver];
    [self addNotification];
}

- (void)initData {
    
    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    [self.navigationView updateClassName:self.paramsModel.className];
    [self.studentView updateUserName:self.paramsModel.userName];
    
    [self setupRTC];
    [self setupSignal];
}

- (void)setupView {
    [self addWhiteBoardViewToView:self.whiteboardView];

    self.boardView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *boardViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *boardViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.boardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.whiteboardBaseView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.whiteboardView addConstraints:@[boardViewTopConstraint, boardViewLeftConstraint, boardViewRightConstraint, boardViewBottomConstraint]];
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
//        [weakself updateTeacherStatusWithModel:rolesInfoModel.teactherModel];
//    }];
}

-(void)updateTeacherStatusWithModel:(TeactherModel*)model{
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
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = 0;
    model.videoView = self.studentView.videoRenderView;
    model.renderMode = RTCVideoRenderModeHidden;
    model.canvasType = RTCVideoCanvasTypeLocal;
    [self.educationManager setupRTCVideoCanvas: model];
    
    [self.educationManager joinRTCChannelByToken:[KeyCenter agoraRTCToken] channelId:self.paramsModel.channelName info:nil uid:[self.paramsModel.userId integerValue] joinSuccess:nil];
    
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

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:@"是否退出房间？" sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [weakself removeTeacherObserver];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"OneToOneViewController is dealloc");
}

#pragma mark SignalDelegate
- (void)signalDidReceived:(SignalP2PModel *)signalModel {
    [self handleSignalWithModel:signalModel];
}
- (void)signalDidUpdateMessage:(SignalRoomModel *_Nonnull)roomMessageModel {
    [self.messageListView addMessageModel:roomMessageModel];
}
- (void)signalDidUpdateGlobalState:(RolesInfoModel * _Nullable)infoModel {
    TeactherModel *teactherModel = infoModel.teactherModel;
    NSArray<RolesStudentInfoModel *> *studentInfoModels = infoModel.studentModels;

    [self updateTeacherStatusWithModel:teactherModel];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", self.paramsModel.userId];
    NSArray<RolesStudentInfoModel *> *filteredArray = [studentInfoModels filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        
        StudentModel *canvasStudentModel = filteredArray.firstObject.studentModel;
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
