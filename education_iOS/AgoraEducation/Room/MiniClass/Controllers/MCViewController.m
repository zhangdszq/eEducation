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
#import "TeactherModel.h"
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

#define kLandscapeViewWidth    222
@interface MCViewController ()<UITextFieldDelegate,RoomProtocol, SignalDelegate, RTCDelegate>
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

@property (nonatomic, strong) TeactherModel *teacherAttr;

@property (nonatomic, strong) NSArray<RolesStudentInfoModel*> *studentTotleListArray;
@property (nonatomic, strong) NSMutableArray<RolesStudentInfoModel*> *studentListArray;
@property (nonatomic, strong) NSMutableArray<NSString*> *studentId;

@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@end

@implementation MCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addTeacherObserver];
    [self addNotification];
}

- (void)initData {
    
    self.chatTextFiled.contentTextFiled.delegate = self;
    self.studentListView.delegate = self;
    self.navigationView.delegate = self;
    [self.navigationView updateClassName:self.paramsModel.className];
    
    self.studentListArray = [NSMutableArray array];
    self.studentId = [NSMutableArray array];
    [self.studentId addObject: self.paramsModel.userId];
    
    self.studentListView.userId = self.paramsModel.userId;
    
    [self setupRTC];
    [self setupSignal];
    
    [self initSelectSegmentBlock];
    [self initStudentRenderBlock];
}

- (void)setupRTC {
    
    [self.educationManager initRTCEngineKitWithAppid:[KeyCenter agoraAppid] clientRole:RTCClientRoleBroadcaster dataSourceDelegate:self];
    [self.educationManager joinRTCChannelByToken:[KeyCenter agoraRTCToken] channelId:self.paramsModel.channelName info:nil uid:[self.paramsModel.userId integerValue] joinSuccess:nil];
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

- (void)getRtmChannelAttrs {
    
//    WEAK(self);
//    [self.educationManager queryGlobalStateWithChannelName:self.paramsModel.channelName completeBlock:^(RolesInfoModel * _Nullable rolesInfoModel) {
//
//        [weakself updateTeacherStatusWithModel:rolesInfoModel.teactherModel];
//
//        weakself.studentListArray = rolesInfoModel.studentModels;
//        [weakself.studentListView updateStudentArray:weakself.studentListArray];
//        [weakself.studentVideoListView updateStudentArray:weakself.studentListArray];
//    }];
}

-(void)updateTeacherStatusWithModel:(TeactherModel*)model{
 
    if(model != nil){
        [self.teacherAttr modelWithTeactherModel:model];
        self.teacherVideoView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
        NSString *imageName = self.teacherAttr.audio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
        [self.teacherVideoView updateSpeakerImageName:imageName];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setBoardViewFrame:self.whiteboardBaseView.bounds];
}
 
- (void)setupView {
    [self addWhiteBoardViewToView:self.whiteboardBaseView];
    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *new = [NSString stringWithFormat:@"%@",change[@"new"]];
    NSString *old = [NSString stringWithFormat:@"%@",change[@"old"]];
    if (![new isEqualToString:old]) {
        if ([keyPath isEqualToString:@"uid"]) {
            NSUInteger uid = [new integerValue];
            if (uid > 0 ) {
                
                RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
                model.uid = uid;
                model.videoView = self.teacherVideoView.videoRenderView;
                model.renderMode = RTCVideoRenderModeHidden;
                model.canvasType = RTCVideoCanvasTypeRemote;
                [self.educationManager setRTCRemoteStreamWithUid:model.uid type:RTCVideoStreamTypeLow];
                [self.educationManager setupRTCVideoCanvas: model];
 
                self.teacherVideoView.defaultImageView.hidden = YES;
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
//            if ([change[@"new"] boolValue]) {
//                self.chatTextFiled.contentTextFiled.enabled = NO;
//                self.chatTextFiled.contentTextFiled.placeholder = @"禁言中";
//            }else {
//                self.chatTextFiled.contentTextFiled.enabled = YES;
//                self.chatTextFiled.contentTextFiled.placeholder = @"说点什么";
//            }
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
    
    RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
    model.uid = uid;
    model.videoView = self.shareScreenView;
    model.renderMode = RTCVideoRenderModeFit;
    model.canvasType = RTCVideoCanvasTypeRemote;
    [self.educationManager setupRTCVideoCanvas:model];
}

- (void)initStudentRenderBlock {
    WEAK(self);
    [self.studentVideoListView setStudentVideoList:^(UIView * _Nullable imageView, NSIndexPath * _Nullable indexPath) {
        
        RolesStudentInfoModel *roleInfoModel = weakself.studentListArray[indexPath.row];
        
        RTCVideoCanvasModel *model = [RTCVideoCanvasModel new];
        model.uid = roleInfoModel.attrKey.integerValue;
        model.videoView = imageView;
        model.renderMode = RTCVideoRenderModeHidden;
        
        if ([roleInfoModel.attrKey isEqualToString:weakself.paramsModel.userId]) {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
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
        [self.educationManager sendMessageWithContent:content userName:self.paramsModel.userName];
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:@"是否退出房间?" sureHandler:^(UIAlertAction * _Nullable action) {
        
        [weakself.navigationView stopTimer];
        [weakself removeTeacherObserver];
        [weakself.educationManager releaseResources];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteAudioStream:(BOOL)stream {
    [self.educationManager enableRTCLocalAudio:!stream];

    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.audio = !stream ? 1 : 0;
    NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
    [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
}
- (void)muteVideoStream:(BOOL)stream {
    [self.educationManager enableRTCLocalVideo:!stream];
    
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    currentStuModel.video = !stream ? 1 : 0;
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
    NSLog(@"MCViewController dealloc");
}

- (void)ergodicStudentListArray {
    self.studentListArray = [NSMutableArray array];
    for (RolesStudentInfoModel *studentInfoModel in self.studentTotleListArray) {
        if([self.studentId containsObject:studentInfoModel.attrKey]){
            [self.studentListArray addObject:studentInfoModel];
        }
    }
}

#pragma mark SignalDelegate
- (void)signalDidReceived:(SignalP2PModel *)signalModel {
    [self handleSignalWithModel:signalModel];
}
- (void)signalDidUpdateMessage:(SignalRoomModel *_Nonnull)roomMessageModel {
    [self.messageView addMessageModel:roomMessageModel];
}
- (void)signalDidUpdateGlobalState:(RolesInfoModel * _Nullable)infoModel {
    TeactherModel *teactherModel = infoModel.teactherModel;
    NSArray<RolesStudentInfoModel *> *studentInfoModels = infoModel.studentModels;
    
    [self updateTeacherStatusWithModel: teactherModel];
    
    self.studentTotleListArray = studentInfoModels;
    [self ergodicStudentListArray];
    [self.studentListView updateStudentArray:self.studentListArray];
    [self.studentVideoListView updateStudentArray:self.studentListArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"attrKey == %@", self.paramsModel.userId];
    NSArray<RolesStudentInfoModel *> *filteredArray = [self.studentListArray filteredArrayUsingPredicate:predicate];
    if(filteredArray.count > 0){
        
        StudentModel *canvasStudentModel = filteredArray.firstObject.studentModel;
        BOOL muteChat = teactherModel != nil ? teactherModel.mute_chat : NO;
        if(!muteChat) {
            muteChat = canvasStudentModel.chat == 0 ? YES : NO;
        }
        self.chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
        self.chatTextFiled.contentTextFiled.placeholder = muteChat ? @" 禁言中" : @" 说点什么";
        
        [self.educationManager enableRTCLocalVideo:canvasStudentModel.video == 0 ? NO : YES];
        [self.educationManager enableRTCLocalAudio:canvasStudentModel.audio == 0 ? NO : YES];
    }
}

#pragma mark RTCDelegate
- (void)rtcDidJoinedOfUid:(NSUInteger)uid {
    
    if (uid == [self.teacherAttr.uid integerValue]) {
    
    } else if (uid == kWhiteBoardUid){
        [self addShareScreenVideoWithUid:uid];
        
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.studentId addObject: uidStr];
        
        [self ergodicStudentListArray];
        [self.studentListView updateStudentArray:self.studentListArray];
        [self.studentVideoListView updateStudentArray:self.studentListArray];
    }
}

- (void)rtcDidOfflineOfUid:(NSUInteger)uid {
    if (uid == self.teacherAttr.uid.integerValue) {
        [self.teacherVideoView updateUserName:@""];
        self.teacherVideoView.defaultImageView.hidden = NO;
    } else if (uid == kWhiteBoardUid) {
         self.shareScreenView.hidden = YES;
    } else {
        NSString *uidStr = [NSString stringWithFormat:@"%lu", (unsigned long)uid];
        [self.studentId removeObject: uidStr];
        
        [self ergodicStudentListArray];
        [self.studentListView updateStudentArray:self.studentListArray];
        [self.studentVideoListView updateStudentArray:self.studentListArray];
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
