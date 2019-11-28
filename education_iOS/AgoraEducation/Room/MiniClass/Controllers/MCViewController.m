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
#import <WhiteSDK.h>
#import "AERTMMessageBody.h"
#import "AgoraHttpRequest.h"

#define kLandscapeViewWidth    222
@interface MCViewController ()<AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate,WhiteCommonCallbackDelegate,WhiteRoomCallbackDelegate,AEClassRoomProtocol,AgoraRtmDelegate>
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
@property (nonatomic, strong) NSMutableDictionary *studentListDict;
@property (nonatomic, strong) NSMutableArray *studentListArray;
@property (nonatomic, strong) NSMutableArray *studentUidArray;

@property (nonatomic, assign) BOOL isTeacherInRoom;
@property (nonatomic, assign) BOOL isMuteVideo;
@property (nonatomic, assign) BOOL isMuteAudio;
@property (nonatomic, assign) BOOL isChatTextFieldKeyboard;
@end

@implementation MCViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.studentListDict = [NSMutableDictionary dictionary];
    self.studentListArray = [NSMutableArray array];
    self.studentUidArray = [NSMutableArray array];
    self.studentListView.userId = self.userId;
    self.isMuteVideo = NO;
    self.isMuteAudio = NO;
    [self loadAgoraRtcEngine];
    [self setUpView];
    [self getRtmChannelAttrs];
    [self selectSegmentIndex];
    [self setWhiteBoardBrushColor];
    [self setAllStudentVideoRender];
    [self addTeacherObserver];
    [self addNotification];
    [self.rtmKit setAgoraRtmDelegate:self];
}

- (void)setStudentAttrs {
    self.ownAttrs = [[AEStudentModel alloc] initWithParams:[AERTMMessageBody paramsStudentWithUserId:self.userId name:self.userName video:YES audio:YES]];
    [self.studentListArray addObject:self.ownAttrs];
    [self.studentListDict setValue:self.ownAttrs forKeyPath:self.userId];
    [self.studentUidArray addObject:self.userId];
    [self.studentListView updateStudentArray:self.studentListArray];
    [self.studentVideoListView updateStudentArray:self.studentListArray];
    [self setChannelAttrsWithVideo:YES audio:YES];
}

- (void)getRtmChannelAttrs{
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingChannelAttr:attributes];
        [weakself setStudentAttrs];
    }];
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
        AEStudentModel *model = weakself.studentListArray[indexPath.row];
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        videoCanvas.uid = [model.userId integerValue];
        videoCanvas.view = imageView;
        if ([model.userId isEqualToString:weakself.userId]) {
            [weakself.rtcEngineKit setupLocalVideo:videoCanvas];
        }else {
            [weakself.rtcEngineKit setRemoteVideoStream:[model.userId integerValue] type:(AgoraVideoStreamTypeLow)];
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

- (void)parsingChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    for (AgoraRtmChannelAttribute *channelAttr in attributes) {
        NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
        if ([channelAttr.key isEqualToString:@"teacher"]) {
            if (!self.teacherAttr) {
                self.teacherAttr = [[AETeactherModel alloc] init];
            }
            [self.teacherAttr modelWithDict:valueDict];
            self.teacherUid = [self.teacherAttr.uid integerValue];
            self.teacherVideoView.defaultImageView.hidden = self.teacherAttr.video ? YES : NO;
            NSString *imageName = self.teacherAttr.audio ? @"icon-speaker3-max" : @"icon-speakeroff-dark";
            [self.teacherVideoView updateSpeakerImageName:imageName];
        }else {
            AEStudentModel *studentAttr = [AEStudentModel yy_modelWithJSON:valueDict];
            studentAttr.userId = channelAttr.key;
            [self.studentListDict setValue:studentAttr forKeyPath:channelAttr.key];
            if ([channelAttr.key isEqualToString:self.userId]) {
                self.ownAttrs = [AEStudentModel yy_modelWithDictionary:valueDict];
            }
        }
    }
    [self updateStudentModelArray];
}

- (BOOL)judgeUidArrayWithUid:(NSInteger)uid {
    for (NSInteger i = 0; i< self.studentUidArray.count; i++) {
        if ([self.studentUidArray[i] integerValue] ==uid) {
            return YES;
        }
    }
    return NO;
}

- (void)updateStudentModelArray {
    NSInteger studentCount = self.studentUidArray.count;
    for (NSInteger i = 0; i < studentCount; i++) {
        if ([self.studentListDict valueForKeyPath:[NSString stringWithFormat:@"%@",self.studentUidArray[i]]]) {
            AEStudentModel *model = [self.studentListDict valueForKeyPath:[NSString stringWithFormat:@"%@",self.studentUidArray[i]]];
            if (![self queryStudentListArrayContainsStudentModel:model]) {
                [self.studentListArray addObject:model];
            }else {
                [self updateStudentListArrayStudentModel:model];
            }
        }
    }
    [self.studentListView updateStudentArray:self.studentListArray];
    [self.studentVideoListView updateStudentArray:self.studentListArray];
}

- (BOOL)judgeStudentArrayWithModel:(AEStudentModel *)model {
    for (NSInteger j = 0; j < self.studentListArray.count; j++) {
        AEStudentModel *tempModel = self.studentListArray[j];
        if ([tempModel.userId isEqualToString:model.userId]) {
            return YES;
            break;
        }
    }
    return NO;
}

- (BOOL)queryStudentListArrayContainsStudentModel:(AEStudentModel *)model {
    for (NSInteger i = 0; i < self.studentListArray.count; i++) {
        AEStudentModel *studentModel = self.studentListArray[i];
        if ([studentModel.userId isEqualToString:model.userId]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateStudentListArrayStudentModel:(AEStudentModel *)model {
    for (NSInteger i = 0; i < self.studentListArray.count; i++) {
        AEStudentModel *studentModel = self.studentListArray[i];
        if ([studentModel.userId isEqualToString:model.userId]) {
            [self.studentListArray replaceObjectAtIndex:i withObject:model];
        }
    }
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
    WEAK(self)
    __block NSString *content = textField.text;
    [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:[AERTMMessageBody sendP2PMessageWithName:self.userName content:content]] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            AERoomMessageModel *messageModel = [[AERoomMessageModel alloc] init];
            messageModel.content = content;
            messageModel.account = weakself.userName;
            messageModel.isSelfSend = YES;
            [weakself.messageView addMessageModel:messageModel];
        }
    }];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)closeRoom {
    WEAK(self)
    [EEAlertView showAlertWithController:self title:@"是否退出房间?" sureHandler:^(UIAlertAction * _Nullable action) {
        [[NSNotificationCenter defaultCenter] removeObserver:weakself];
        [weakself.navigationView stopTimer];
        [weakself.rtcEngineKit leaveChannel:nil];
        [weakself.room disconnect:^{

        }];
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [weakself.rtmKit deleteChannel:weakself.rtmChannelName AttributesByKeys:@[weakself.userId] Options:options completion:nil];
        [weakself.rtmChannel leaveWithCompletion:nil];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark --------------------- RTC Delegate -------------------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if (self.teacherUid == uid) {
    
    }else if (uid == kWhiteBoardUid){
        [self addShareScreenVideoWithUid:uid];

    }else {
        if (![self judgeUidArrayWithUid:uid]) {
            [self.studentUidArray addObject:@(uid)];
            [self updateStudentModelArray];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid == self.teacherUid) {
        self.teacherAttr.uid = [NSString stringWithFormat:@"0"];
        self.teacherUid = 0;
    }else if (uid == kWhiteBoardUid) {
        [self removeShareScreen];
    }else {
        AEStudentModel *model =  [self.studentListDict valueForKeyPath:[NSString stringWithFormat:@"%zd",uid]];
        [self.studentListArray removeObject:model];
        [self.studentUidArray removeObject:@(uid)];
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

#pragma mark --------------- RTM Delegate -----------
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    NSDictionary *dict =  [JsonAndStringConversions dictionaryWithJsonString:message.text];
    AERoomMessageModel *messageModel = [AERoomMessageModel yy_modelWithDictionary:dict];
    messageModel.isSelfSend = NO;
    [self.messageView addMessageModel:messageModel];
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingChannelAttr:attributes];
}

- (void)muteAudioStream:(BOOL)stream {
    [self.rtcEngineKit muteLocalAudioStream:stream];
    [self setChannelAttrsWithVideo:!self.isMuteVideo audio:!stream];
    self.isMuteAudio = stream;
}
- (void)muteVideoStream:(BOOL)stream {
    [self.rtcEngineKit muteLocalVideoStream:stream];
    [self setChannelAttrsWithVideo:!stream audio:!self.isMuteAudio];
    self.isMuteVideo = stream;
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
@end
