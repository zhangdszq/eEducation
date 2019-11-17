//
//  OneToOneViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "OneToOneViewController.h"
#import "EENavigationView.h"
#import "EEWhiteboardTool.h"
#import "EEPageControlView.h"
#import "EEChatTextFiled.h"
#import "RoomMessageModel.h"
#import "EEMessageView.h"
#import "EEBCTeactherAttrs.h"
#import "EEPublicMethodsManager.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "EEPublicMethodsManager.h"
#import "EEBCStudentAttrs.h"
#import <WhiteSDK.h>
#import "EEColorShowView.h"

@interface OneToOneViewController ()<EEPageControlDelegate,EEWhiteboardToolDelegate,UITextFieldDelegate,AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,WhiteCommonCallbackDelegate>
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

@property (nonatomic, strong) AgoraRtmChannel *rtmChannel;
@property (nonatomic, strong) EEBCTeactherAttrs *teacherAttr;
@property (nonatomic, strong) EEBCStudentAttrs *studentAttrs;

@property (nonatomic, strong) AgoraRtcEngineKit *rtcEngineKit;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) AgoraRtmKit *rtmKit;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;

@property (nonatomic, strong) WhiteBoardView *boardView;
@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong, nullable) WhiteRoom *room;

@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
@property (nonatomic, strong) UIColor *pencilColor;
@property (nonatomic, strong) WhiteMemberState *memberState;
@property (nonatomic, assign) BOOL isMuteVideo;
@property (nonatomic, assign) BOOL isMuteAudio;

@end

@implementation OneToOneViewController
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

- (void)getRtmChannelAttrs{
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingTheChannelAttr:attributes];
        if (weakself.teacherAttr) {
           [weakself joinWhiteBoardRoomUUID:weakself.teacherAttr.whiteboard_uid];
        }
        self.isMuteVideo = YES;
        self.isMuteAudio = YES;
        [weakself updateChannelAttrs];
    }];
}

- (void)updateChannelAttrs {
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.userId;
    setAttr.value = [EEPublicMethodsManager setAndUpdateStudentChannelAttrsWithName:self.userName video:self.isMuteVideo audio:self.isMuteAudio];
    AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
    options.enableNotificationToChannelMembers = YES;
    NSArray *attrArray = [NSArray arrayWithObjects:setAttr, nil];
    [self.rtmKit addOrUpdateChannel:self.rtmChannelName Attributes:attrArray Options:options completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
       if (errorCode == AgoraRtmAttributeOperationErrorOk) {
           NSLog(@"更新成功");
       }else {
           NSLog(@"更新失败");
       }
    }];
}

- (void)parsingTheChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    if (attributes.count > 0) {
        for (AgoraRtmChannelAttribute *channelAttr in attributes) {
           NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
           if ([channelAttr.key isEqualToString:@"teacher"]) {
               self.teacherAttr = [EEBCTeactherAttrs yy_modelWithDictionary:valueDict];
               if (!self.teacherAttr.video) {
                   [self.teacherView.defaultImageView setImage:[UIImage imageNamed:@"video-close"]];
               }else {
                   [self.teacherView.defaultImageView setHidden:YES];
               }
               [self.teacherView updateSpeakerEnabled:self.teacherAttr.audio volume:0.f];

           }else {
               self.studentAttrs = [EEBCStudentAttrs yy_modelWithJSON:valueDict];
               self.studentAttrs.userId = channelAttr.key;
           }
        }
    }
}

- (void)joinWhiteBoardRoomUUID:(NSString *)uuid {
     self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
        WEAK(self)
//     AgoraHttpRequest *request = [[AgoraHttpRequest alloc] init];

//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.channelName,@"name",@"100",@"limit", nil];
//    [request post:kGetWhiteBoardUuid params:params success:^(id responseObj) {
//               NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
//               if ([responseObject[@"code"] integerValue] == 200) {
//                   NSDictionary *roomDict = responseObject[@"msg"][@"room"];
//                    WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:roomDict[@"uuid"] roomToken:responseObject[@"msg"][@"roomToken"]];
//                   [weakself.sdk joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
//                       weakself.room = room;
//                       [weakself getWhiteboardSceneInfo];
////                       [weakself.room disableDeviceInputs:YES];
//                 }];
//               }
//           } failure:^(NSError *error) {

//           }];

    [EEPublicMethodsManager parseWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        [weakself.sdk joinRoomWithConfig:roomConfig callbacks:nil completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
            weakself.room = room;
            [weakself getWhiteboardSceneInfo];
        }];
    } failure:^(NSString * _Nonnull msg) {
        NSLog(@"获取失败 %@",msg);
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpView];
    [self addNotification];
    [self loadAgoraEngine];
    [self getRtmChannelAttrs];
    self.rtmChannel  =  [self.rtmKit createChannelWithId:self.rtmChannelName delegate:self];
    [self.rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {

    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.boardView.frame = self.whiteboardView.bounds;

}
- (void)setUpView {
    if (@available(iOS 11, *)) {
       } else {
           self.automaticallyAdjustsScrollViewInsets = NO;
       }
    self.boardView = [[WhiteBoardView alloc] init];
    [self.whiteboardView addSubview:self.boardView];



    self.whiteboardTool.delegate = self;
    self.pageControlView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    [self.navigationView.closeButton addTarget:self action:@selector(closeRoom:) forControlEvents:(UIControlEventTouchUpInside)];
    WEAK(self)
    self.studentView.muteVideo = ^(BOOL isMute) {
        [weakself.rtcEngineKit muteLocalVideoStream:isMute];
        weakself.isMuteVideo = isMute;
        [weakself updateChannelAttrs];
    };
    self.studentView.muteMic = ^(BOOL isMute) {
        [weakself.rtcEngineKit muteLocalAudioStream:isMute];
        weakself.isMuteAudio = isMute;
        [weakself updateChannelAttrs];
    };
    self.colorShowView.selectColor = ^(NSString *colorString) {
       NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
       weakself.memberState.strokeColor = colorArray;
       [weakself.room setMemberState:weakself.memberState];
    };
    [self joinWhiteBoardRoomUUID:@"f988fb64078e48baa410058bd728009b"];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textFiledWidthCon.constant = kScreenWidth - 44;
    self.textFiledBottomCon.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textFiledWidthCon.constant = 222;
    self.textFiledBottomCon.constant = 0;
}

- (void)loadAgoraEngine {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit enableVideo];
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid = 0;
    canvas.view = self.studentView;
    [self.rtcEngineKit setupLocalVideo:canvas];
    [self.rtcEngineKit startPreview];

    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:nil];

}

- (void)closeRoom:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)hideAndShowChatRoomView:(UIButton *)sender {
    self.chatRoomViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.textFiledRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.chatRoomView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
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
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    __block NSString *content = textField.text;
    WEAK(self)
    [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:textField.text] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            messageModel.content = content;
            messageModel.name = weakself.userName;
            messageModel.isSelfSend = YES;
            [weakself.messageListView addMessageModel:messageModel];
        }
    }];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraErrorCode)errorCode {

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {

}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {

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

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {
    [self parsingTheChannelAttr:attributes];
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    if ([peerId isEqualToString:self.teacherAttr.uid]) {
        NSDictionary *dict = [JsonAndStringConversions dictionaryWithJsonString:message.text];
        if ([dict[@"type"] isEqualToString:@"mute"]) {
            if ([dict[@"resource"] isEqualToString:@"video"]) {
                [self.rtcEngineKit muteLocalVideoStream:YES];
                self.isMuteVideo = YES;
            }else if([dict[@"resource"] isEqualToString:@"audio"]) {
                [self.rtcEngineKit muteLocalAudioStream:YES];
                self.isMuteAudio = YES;
            }
        }else if([dict[@"type"] isEqualToString:@"unmute"]){
            if ([dict[@"resource"] isEqualToString:@"video"]) {
                [self.rtcEngineKit muteLocalVideoStream:NO];
                self.isMuteVideo = NO;
            }else if([dict[@"resource"] isEqualToString:@"audio"]) {
                [self.rtcEngineKit muteLocalAudioStream:NO];
                self.isMuteAudio = NO;
            }
        }
        [self updateChannelAttrs];
    }
}

#pragma mark ----------------------------------- PageControl Delegate ---------------------------
- (void)previousPage {
    if (self.sceneIndex > 1) {
        self.sceneIndex = self.sceneIndex -1;
       [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
       [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.scenes.count) {
        self.sceneIndex = self.sceneIndex + 1;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
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

@end
