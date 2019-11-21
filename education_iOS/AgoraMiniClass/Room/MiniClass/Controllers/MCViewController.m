//
//  MCViewController.m
//  AgoraMiniClass
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
#import "EEBCTeactherAttrs.h"
#import "EEBCStudentAttrs.h"
#import "EEChatTextFiled.h"
#import "RoomMessageModel.h"
#import "EEMessageView.h"
#import "MCStudentListView.h"
#import "MCSegmentedView.h"
#import <WhiteSDK.h>
#import "EERTMMessageProtocol.h"

#define kLandscapeViewWidth    222
@interface MCViewController ()<AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate,EEWhiteboardToolDelegate,EEPageControlDelegate,WhiteCommonCallbackDelegate,WhiteRoomCallbackDelegate,MCStudentViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;


@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *studentVideoListView;
@property (weak, nonatomic) IBOutlet MCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;
@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;
@property (weak, nonatomic) IBOutlet UIButton *showAndHideButton;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;
@property (weak, nonatomic) IBOutlet MCStudentListView *studentListView;
@property (weak, nonatomic) IBOutlet MCSegmentedView *segmentedView;

@property (nonatomic, strong) WhiteBoardView *boardView;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong, nullable) WhiteRoom *room;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
@property (nonatomic, strong) UIColor *pencilColor;
@property (nonatomic, strong) WhiteMemberState *memberState;


@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) AgoraRtmKit *rtmKit;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;
@property (nonatomic, strong) AgoraRtmChannel *rtmChannel;


@property (nonatomic, strong) EEBCTeactherAttrs *teacherAttrs;
@property (nonatomic, strong) NSMutableDictionary *studentList;
@property (nonatomic, strong) NSMutableArray *studentListArray;
@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;

@property (nonatomic, assign) BOOL isTeacherInRoom;
@property (nonatomic, assign) BOOL isMuteVideo;
@property (nonatomic, assign) BOOL isMuteAudio;
@end

@implementation MCViewController
- (void)setParams:(NSDictionary *)params {
    _params = params;
    if (params[@"rtmKit"]) {
        self.rtmKit = params[@"rtmKit"];
        self.channelName = params[@"channelName"];
        self.userName = params[@"userName"];
        self.userId = params[@"userId"];
        self.rtmChannelName = params[@"rtmChannelName"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationView.closeButton addTarget:self action:@selector(closeRoom:) forControlEvents:(UIControlEventTouchUpInside)];
    self.studentList = [NSMutableDictionary dictionary];
    self.studentListArray = [NSMutableArray array];
    self.studentListView.userId = self.userId;
    self.isMuteVideo = NO;
    self.isMuteAudio = NO;
    [self loadAgoraRtcEngine];
    [self joinRtmChannnel];
    [self setUpView];
    [self loadBlock];
    [self addNotification];

    [self getRtmChannelAttrs];
  EEBCStudentAttrs *studentAttrs = [[EEBCStudentAttrs alloc] initWithParams:[EERTMMessageProtocol paramsStudentWithUserId:self.userId name:self.userName video:YES audio:YES]];
  [self.studentListArray addObject:studentAttrs];
  [self.studentList setValue:studentAttrs forKey:self.userId];
  [self.studentListView updateStudentArray:self.studentListArray];
  [self.studentVideoListView updateStudentArray:self.studentListArray];
    WEAK(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself setChannelAttrsWithVideo:YES audio:YES];
    });
}

- (void)getRtmChannelAttrs{
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingTheChannelAttr:attributes];
    }];
}
- (void)setUpView {
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardBaseView addSubview:self.boardView];
    self.boardView.frame = self.whiteboardBaseView.bounds;
    self.chatTextFiled.contentTextFiled.delegate = self;
    self.whiteboardTool.delegate = self;
    self.pageControlView.delegate = self;
    self.studentListView.delegate = self;
    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;
    [self.navigationView updateChannelName:self.channelName];
}

- (void)loadBlock {
    WEAK(self)
    self.segmentedView.selectIndex = ^(NSInteger index) {
        if (index == 0) {
            weakself.messageView.hidden = NO;
            weakself.chatTextFiled.hidden = NO;
            weakself.studentListView.hidden = YES;
        }else {
            weakself.messageView.hidden = YES;
            weakself.chatTextFiled.hidden = YES;
            weakself.studentListView.hidden = NO;
        }
    };
    self.colorShowView.selectColor = ^(NSString *colorString) {
        NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        weakself.memberState.strokeColor = colorArray;
        [weakself.room setMemberState:weakself.memberState];
    };

   self.studentVideoListView.studentVideoList = ^(UIView * _Nullable imageView, NSIndexPath * _Nullable indexPath) {
               EEBCStudentAttrs *model = weakself.studentListArray[indexPath.row];
               AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
               videoCanvas.uid = [model.userId integerValue];
               videoCanvas.view = imageView;
               if ([model.userId isEqualToString:weakself.userId]) {
                   [weakself.rtcEngineKit setupLocalVideo:videoCanvas];
               }else {
                   NSLog(@"AgoraRtcVideoCanvas---- %@ ------- %@ ------- %@ ----- %@",model.account,model.userId,weakself.userId,weakself.rtcEngineKit);
                   [weakself.rtcEngineKit setupRemoteVideo:videoCanvas];
               }
           };
}

- (void)joinRtmChannnel {
    self.rtmChannel  =  [self.rtmKit createChannelWithId:self.rtmChannelName delegate:self];
    [self.rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if (errorCode == AgoraRtmJoinChannelErrorOk) {
            NSLog(@"频道加入成功");
        }
    }];
}

- (void)getWhiteboardSceneInfo {
    WEAK(self)
    [self.room getSceneStateWithResult:^(WhiteSceneState * _Nonnull state) {
        weakself.scenes = [NSArray arrayWithArray:state.scenes];
        weakself.sceneDirectory = @"/";
        weakself.sceneIndex = 1;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",weakself.sceneIndex,weakself.scenes.count]];
    }];
}

- (void)joinWhiteBoardRoomUUID:(NSString *)uuid {
    self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
    WEAK(self)
    [EERTMMessageProtocol parseWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        [weakself.sdk joinRoomWithConfig:roomConfig callbacks:weakself completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
            weakself.room = room;
            [weakself getWhiteboardSceneInfo];
        }];
    } failure:^(NSString * _Nonnull msg) {
        NSLog(@"获取失败 %@",msg);
    }];
}

- (void)setChannelAttrsWithVideo:(BOOL)video audio:(BOOL)audio {
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.userId;
    setAttr.value = [EERTMMessageProtocol setAndUpdateStudentChannelAttrsWithName:self.userName video:video audio:audio];
    AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
    options.enableNotificationToChannelMembers = YES;
    NSArray *attrArray = [NSArray arrayWithObjects:setAttr, nil];
    [self.rtmKit addOrUpdateChannel:self.rtmChannelName Attributes:attrArray Options:options completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            NSLog(@"更新成功");
        }else {
            NSLog(@"更新失败 %ld",errorCode);
        }
    }];
}

- (void)parsingTheChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    NSLog(@"attrr------ %ld",attributes.count);
    for (AgoraRtmChannelAttribute *channelAttr in attributes) {
        NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
        if ([channelAttr.key isEqualToString:@"teacher"]) {
            self.teacherAttrs = [EEBCTeactherAttrs yy_modelWithDictionary:valueDict];
            if (!self.isTeacherInRoom) {
                [self joinWhiteBoardRoomUUID:self.teacherAttrs.whiteboard_uid];
            }
            self.isTeacherInRoom = YES;
            [self.navigationView startTimer];
        }else {
            EEBCStudentAttrs *studentAttr = [EEBCStudentAttrs yy_modelWithJSON:valueDict];
            studentAttr.userId = channelAttr.key;
            if (![self.studentList objectForKey:channelAttr.key]) {
                [self.studentListArray addObject:studentAttr];
                [self.studentList setValue:studentAttr forKey:channelAttr.key];
            }else {
                for (NSInteger i = 0 ; i < self.studentListArray.count; i++) {
                    EEBCStudentAttrs *studentModel =  self.studentListArray[i];
                    if ([studentModel.userId isEqualToString:channelAttr.key]) {
                        [self.studentListArray replaceObjectAtIndex:i withObject:studentAttr];
                    }
                }
            }
        }
        [self.studentListView updateStudentArray:self.studentListArray];
        [self.studentVideoListView updateStudentArray:self.studentListArray];
    }
}

- (void)loadAgoraRtcEngine {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    [self.rtcEngineKit enableVideo];
    [self.rtcEngineKit startPreview];
    [self.rtcEngineKit enableWebSdkInteroperability:YES];
    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:nil];
}

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.chatTextFiledBottomCon.constant = bottom;
    self.chatTextFiledWidthCon.constant = kScreenWidth;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.chatTextFiledBottomCon.constant = 0;
    self.chatTextFiledWidthCon.constant = 222;
}

- (void)closeRoom:(UIButton *)sender {
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

- (IBAction)showAndHide:(UIButton *)sender {
    self.infoManagerViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.roomManagerView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    WEAK(self)
    __block NSString *content = textField.text;
    [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:textField.text] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            messageModel.content = content;
            messageModel.name = weakself.userName;
            messageModel.isSelfSend = YES;
            [weakself.messageView addMessageModel:messageModel];
        }
    }];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
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

#pragma mark ----------------------------------- PageControl Delegate ---------------------------
- (void)previousPage {
    if (self.sceneIndex > 1) {
        self.sceneIndex = self.sceneIndex - 1;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex - 1].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.scenes.count) {
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        self.sceneIndex = self.sceneIndex + 1;
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)lastPage {
    self.sceneIndex = self.scenes.count;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex-1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
}

- (void)firstPage {
    self.sceneIndex = 1;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex-1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = uid;
    if (uid == [self.teacherAttrs.uid integerValue]) {
        canvas.view = self.teacherVideoView.videoRenderView;
        self.teacherVideoView.defaultImageView.hidden = YES;
    }else if (uid == [self.teacherAttrs.shared_uid integerValue]) {
        self.shareScreenView.hidden = NO;
        canvas.view = self.shareScreenView;
    }
    [self.teacherVideoView updateUserName:self.teacherAttrs.account];
    [self.rtcEngineKit setupRemoteVideo:canvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if (uid == [self.teacherAttrs.shared_uid integerValue]) {
        self.shareScreenView.hidden = YES;
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
#pragma mark ------------------------- whiteboard Delegate ---------------------------
- (void)fireRoomStateChanged:(WhiteRoomState *)modifyState {
    if (modifyState.sceneState && modifyState.sceneState.scenes.count > self.scenes.count) {
        self.scenes = [NSArray arrayWithArray:modifyState.sceneState.scenes];
        self.sceneDirectory = @"/";
        self.sceneIndex = self.sceneIndex+1;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex - 1].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.scenes.count,self.scenes.count]];
    }
}

#pragma mark --------------- RTM Delegate -----------
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    NSString *userName = nil;
    if ([member.userId isEqualToString: self.teacherAttrs.uid]) {
        userName = self.teacherAttrs.account;
    }else {
        EEBCStudentAttrs *attrs = self.studentList[member.userId];
        userName = attrs.account;
    }
    RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
    messageModel.content = message.text;
    messageModel.name = userName;
    messageModel.isSelfSend = NO;
    [self.messageView addMessageModel:messageModel];
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {

}


- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    if (state == AgoraRtmConnectionStateAborted) {
    }
}

- (void)channel:(AgoraRtmChannel *)channel memberLeft:(AgoraRtmMember *)member {
    if ([member.userId isEqualToString:self.teacherAttrs.uid]) {
        self.teacherVideoView.defaultImageView.hidden = NO;
        [self.teacherVideoView updateUserName:@""];
        [self.teacherVideoView updateSpeakerImageName:@"icon-speakeroff-dark"];
        self.teacherAttrs = nil;
    }else {
        EEBCStudentAttrs *studentModel = [self.studentList objectForKey:member.userId];
        [self.studentListArray removeObject:studentModel];
        [self.studentListView updateStudentArray:self.studentListArray];
        [self.studentVideoListView removeStudentModel:studentModel];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingTheChannelAttr:attributes];
    if (self.teacherAttrs) {
        self.teacherVideoView.defaultImageView.hidden = self.teacherAttrs.video ? YES : NO;
        NSString *imageName = self.teacherAttrs.audio ? @"mic-speaker3" : @"speaker-close";
        [self.teacherVideoView updateSpeakerImageName:imageName];
    }
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"MCViewController dealloc");
}
@end
