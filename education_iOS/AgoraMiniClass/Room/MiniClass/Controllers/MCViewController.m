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

@interface MCViewController ()<AgoraRtmChannelDelegate,AgoraRtcEngineDelegate,UITextFieldDelegate>
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
    [self setUpView];
    [self addNotification];
    [self joinRtmChannnel];
    [self getRtmChannelAttrs];
    [self loadAgoraRtcEngine];

}

- (void)setUpView {
    self.chatTextFiled.contentTextFiled.delegate = self;
}

- (void)joinRtmChannnel {
    self.rtmChannel  =  [self.rtmKit createChannelWithId:self.rtmChannelName delegate:self];
    [self.rtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
       if (errorCode == AgoraRtmJoinChannelErrorOk) {
           NSLog(@"频道加入成功");
       }
    }];
}

- (void)getRtmChannelAttrs{
    WEAK(self)
    [self.rtmKit getChannelAllAttributes:self.rtmChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself parsingTheChannelAttr:attributes];
    }];
}

- (void)parsingTheChannelAttr:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    if (attributes.count > 0) {
        for (AgoraRtmChannelAttribute *channelAttr in attributes) {
           NSDictionary *valueDict =   [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
           if ([channelAttr.key isEqualToString:@"teacher"]) {
               self.teacherAttrs = [EEBCTeactherAttrs yy_modelWithDictionary:valueDict];
           }else {
               EEBCStudentAttrs *studentAttr = [EEBCStudentAttrs yy_modelWithJSON:valueDict];
               studentAttr.userId = channelAttr.key;
               if (![_studentList objectForKey:studentAttr.userId]) {
                   [self.studentListArray addObject:studentAttr];
               }
               [self.studentList setValue:studentAttr forKey:channelAttr.key];

           }
        }
    }
}


- (void)loadAgoraRtcEngine {
    self.rtcEngineKit = [AgoraRtcEngineKit sharedEngineWithAppId:kAgoraAppid delegate:self];
    [self.rtcEngineKit setChannelProfile:(AgoraChannelProfileLiveBroadcasting)];
    [self.rtcEngineKit setClientRole:(AgoraClientRoleBroadcaster)];
    [self.rtcEngineKit enableVideo];

//    [self.rtcEngineKit joinChannelByToken:nil channelId:self.rtmChannelName info:nil uid:[self.userId integerValue] joinSuccess:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showAndHide:(UIButton *)sender {
    self.infoManagerViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.roomManagerView.hidden = sender.isSelected ? NO : YES;
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
    NSLog(@"MCViewController dealloc");
}
@end
