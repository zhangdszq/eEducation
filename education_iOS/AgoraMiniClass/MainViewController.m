//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MainViewController.h"
#import "CameraMicTestViewController.h"
#import "AgoraHttpRequest.h"
#import "RoomViewController.h"
#import "RoomUserModel.h"
#import "ClassRoomDataManager.h"
#import "NetworkViewController.h"


@interface MainViewController ()<AgoraRtmDelegate,AgoraRtmChannelDelegate,ClassRoomDataManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *teactherButton;
@property (weak, nonatomic) IBOutlet UIButton *studentButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;
@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, copy)   NSString *serverRtmId;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, copy)   NSString  *className;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, assign) ClassRoomRole classRoomRole;
@property (nonatomic, copy)   NSString *uid;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, strong) ClassRoomDataManager *roomDataManager;
@end

@implementation MainViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.roomDataManager.classRoomManagerDelegate = self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomDataManager = [ClassRoomDataManager shareManager];
    self.uid = [self getJoinChannelUid];
    self.roomDataManager.uid = self.uid;
    [self joinRtm];
    [self setUpView];
    [self setAllButtonStyle];
    [self addTouchedRecognizer];
    [self addKeyboardNotification];
}

- (void)setUpView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;

    self.baseView.layer.cornerRadius = 12;

    self.studentButton.selected = YES;
    [self setButtonStyle:self.studentButton];
    self.classRoomRole = ClassRoomRoleStudent;
    self.roomDataManager.roomRole = ClassRoomRoleStudent;
}

- (void)setAllButtonStyle {
    [self setButtonStyle:self.teactherButton];
    [self setButtonStyle:self.studentButton];
    [self setButtonStyle:self.audienceButton];
}

- (void)addTouchedRecognizer {
    UITapGestureRecognizer *touchedControl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBegan:)];
    [self.baseView addGestureRecognizer:touchedControl];
}

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)joinRtm {
    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:kAgoraAppid delegate:self];
    WEAK(self)
    [self.agoraRtmKit loginByToken:nil user:self.uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        weakself.roomDataManager.agoraRtmKit = weakself.agoraRtmKit;
    }];
}

- (void)joinRtmChannel {
    self.agoraRtmChannel  =  [self.agoraRtmKit createChannelWithId:self.className delegate:self];
    WEAK(self)
    [self.agoraRtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        NSLog(@"---------------  %ld",(long)errorCode);
        weakself.roomDataManager.agoraRtmChannel = weakself.agoraRtmChannel;
    }];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height - 208;
    self.textViewBottomConstraint.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textViewBottomConstraint.constant = 48;
}

- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
}

- (void)setButtonStyle:(UIButton *)button {
    if (button.selected == YES) {
        [button setBackgroundColor:RCColorWithValue(0x006EDE, 1)];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];

    }else {
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.borderColor = RCColorWithValue(0xCCCCCC, 1).CGColor;
        button.layer.borderWidth = 1;
        [button setTitleColor:RCColorWithValue(0xCCCCCC,1) forState:(UIControlStateNormal)];
    }
}

- (IBAction)selectRole:(UIButton *)sender {
    if (sender == self.teactherButton) {
        self.teactherButton.selected = YES;
        self.studentButton.selected = NO;
        self.audienceButton.selected = NO;
    }else if (sender == self.studentButton) {
        self.teactherButton.selected = NO;
        self.studentButton.selected = YES;
        self.audienceButton.selected = NO;
    }else {
        self.teactherButton.selected = NO;
        self.studentButton.selected = NO;
        self.audienceButton.selected = YES;
    }
    self.classRoomRole = sender.tag;
    self.roomDataManager.roomRole = self.classRoomRole;
    [self setAllButtonStyle];
}

- (IBAction)joinRoom:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0) {
        [self.activityIndicator stopAnimating];
    }else {
        if (self.teactherButton.selected || self.studentButton.selected || self.audienceButton.selected) {
            self.className = self.classNameTextFiled.text;
            self.userName = self.userNameTextFiled.text;
            self.roomDataManager.className = self.className;
            self.roomDataManager.userName = self.userName;
            [self joinRtmChannel];
            [self getServerRtmId];
        }else {
            [self.activityIndicator stopAnimating];
        }
    }
}

- (void)presentNextViewController {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NetworkViewController *roomVC = [story instantiateViewControllerWithIdentifier:@"network"];
    [self presentViewController:roomVC animated:YES completion:nil];
}

#pragma MARK -----------------------  AgoraRtmDelegate -------------------------
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {

}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberJoined:(AgoraRtmMember * _Nonnull)member {
    NSLog(@"%@----- %@",member.userId,member.channelId);
}

#pragma mark -------------------- ClassRoomDelegate -----------
- (void)joinClassRoomError {
    [self.activityIndicator stopAnimating];
}

- (void)joinClassRoomSuccess {
    [self.activityIndicator stopAnimating];
    [self presentNextViewController];
}

#pragma mark --------------------- GET ---------------------
- (NSString *)getJoinChannelUid{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970])];
    NSString *uid =  [timeSp substringFromIndex:3];
    return uid;
}

- (void)getServerRtmId {
    WEAK(self)
    [AgoraHttpRequest get:kGetServerRtmIdUrl params:nil success:^(id responseObj) {
        NSString * str  =[[NSString alloc] initWithData:responseObj encoding:NSUTF8StringEncoding];
        weakself.roomDataManager.serverRtmId = str;
        weakself.serverRtmId = str;
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(weakself.classRoomRole),@"role",weakself.userName,@"name",weakself.uid,@"streamId", nil];
        NSDictionary *argsInfo = [NSDictionary dictionaryWithObjectsAndKeys:weakself.className,@"channel",userInfo,@"userAttr", nil];
        NSDictionary  *requestInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Join",@"name",argsInfo,@"args", nil];
        NSString *requestStr =  [JsonAndStringConversions dictionaryToJson:requestInfo];
        AgoraRtmMessage *message = [[AgoraRtmMessage alloc] init];
        message.text = requestStr;
        [weakself.agoraRtmKit sendMessage:message toPeer:weakself.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
            NSLog(@"%ld",(long)errorCode);
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
