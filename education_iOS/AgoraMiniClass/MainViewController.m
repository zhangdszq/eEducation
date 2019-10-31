//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MainViewController.h"
#import "AgoraHttpRequest.h"
#import "RoomViewController.h"
#import "RoomUserModel.h"
#import "ClassRoomDataManager.h"
#import "NetworkViewController.h"
#import "EyeCareModeUtil.h"
#import "SettingViewController.h"
#import "BCViewController.h"
#import "EEClassRoomTypeView.h"
#import "OneToOneViewController.h"
#import "NSString+RTMMessage.h"

@interface MainViewController ()<AgoraRtmDelegate,AgoraRtmChannelDelegate,ClassRoomDataManagerDelegate,EEClassRoomTypeDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
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
@property (nonatomic, weak) EEClassRoomTypeView *classRoomTypeView;
@property (weak, nonatomic) IBOutlet UIButton *roomType;
@property (nonatomic, assign) AgoraRtmConnectionState rtmConnectionState;
@property (nonatomic, strong) AFNetworkReachabilityManager *mageger;
@end

@implementation MainViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.roomDataManager.classRoomManagerDelegate = self;
    if ([[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]) {
        [[EyeCareModeUtil sharedUtil] switchEyeCareMode:YES];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomDataManager = [ClassRoomDataManager shareManager];
    self.uid = [NSString setRTMUser];
    self.roomDataManager.uid = self.uid;
    [self joinRtm];
    [self setUpView];
    [self addTouchedRecognizer];
    [self addKeyboardNotification];
//    [self reachability];

}

- (void)setUpView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;

    self.classRoomRole = ClassRoomRoleStudent;
    self.roomDataManager.roomRole = ClassRoomRoleStudent;

    EEClassRoomTypeView *classRoomTypeView = [EEClassRoomTypeView initWithXib:CGRectMake(30, kScreenHeight - 300, kScreenWidth - 60, 150)];
    [self.view addSubview:classRoomTypeView];
    self.classRoomTypeView = classRoomTypeView;
    classRoomTypeView.hidden = YES;
    classRoomTypeView.delegate = self;
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
        if (errorCode == AgoraRtmLoginErrorOk) {
            weakself.roomDataManager.agoraRtmKit = weakself.agoraRtmKit;
        }
    }];
}

- (void)joinRtmChannelCompletion:(AgoraRtmJoinChannelBlock _Nullable)completionBlock {
    self.agoraRtmChannel  =  [self.agoraRtmKit createChannelWithId:self.className delegate:self];
    [self.agoraRtmChannel joinWithCompletion:completionBlock];
    self.roomDataManager.agoraRtmChannel = self.agoraRtmChannel;
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

    self.classRoomTypeView.hidden  = YES;
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

- (IBAction)popupRoomType:(UIButton *)sender {
    self.classRoomTypeView.hidden = NO;
}

- (IBAction)joinRoom:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0 || ![self judgeClassRoomText:self.classNameTextFiled.text] || ![self judgeClassRoomText:self.userNameTextFiled.text]) {
        UIAlertController *alterVC = [UIAlertController alertControllerWithTitle:@"请检查房间号和用户名符合规格" message:@"11位及以内的数字或者英文字符" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alterVC addAction:sure];
        [self presentViewController:alterVC animated:YES completion:nil];
        [self.activityIndicator stopAnimating];
    }else {
        self.roomDataManager.className = self.className;
        self.roomDataManager.userName = self.userName;
        if ([self.roomType.titleLabel.text isEqualToString:@"小班课"]) {
            self.className = self.classNameTextFiled.text;
            self.userName = self.userNameTextFiled.text;
            [self getServerRtmId];
            [self joinRtmChannelCompletion:nil];
        }else if ([self.roomType.titleLabel.text isEqualToString:@"大班课"]) {
            [self presentBigClassController];
        }else if ([self.roomType.titleLabel.text isEqualToString:@"一对一"]) {
            [self presentOneToOneViewController];
        }else {
            [self presentAlterViewTitile:@"join error" message:@"请选择房间类型" cancelActionTitle:@"取消" confirmActionTitle:nil];
        }
    }
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)presentBigClassController {
    if (self.rtmConnectionState == AgoraRtmConnectionStateDisconnected) {
        [self joinRtm];
    }else if (self.rtmConnectionState == AgoraRtmConnectionStateConnecting) {
        [self presentAlterViewTitile:@"error" message:@"create channel error" cancelActionTitle:@"cancel" confirmActionTitle:nil];
    }else {
        [self joinRtmChannelCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
            if (errorCode == AgoraRtmJoinChannelErrorTimeout) {
                 [self presentAlterViewTitile:@"error" message:@"create channel error" cancelActionTitle:@"cancel" confirmActionTitle:nil];
            }
        }];
        [self.activityIndicator stopAnimating];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        BCViewController *roomVC = [story instantiateViewControllerWithIdentifier:@"bcroom"];
        roomVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:roomVC animated:YES completion:nil];
    }
}
- (void)presentMiniClassViewController {
    [self.activityIndicator stopAnimating];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NetworkViewController *networkVC = [story instantiateViewControllerWithIdentifier:@"network"];
    networkVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:networkVC animated:YES completion:nil];
}

- (void)presentOneToOneViewController {
    OneToOneViewController *oneToOneVC = [[OneToOneViewController alloc] init];
    [self.navigationController pushViewController:oneToOneVC animated:YES];
}

- (void)presentAlterViewTitile:(NSString *)title message:(NSString *)message cancelActionTitle:(NSString *)cancelTitle confirmActionTitle:(NSString *)confirmTitle {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
        if (cancelTitle) {
         [alertVC addAction:cancel];
    }

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:confirmTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    if (confirmTitle) {
        [alertVC addAction:confirm];
    }
    alertVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (BOOL)judgeClassRoomText:(NSString *)text {
    NSString *regex = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:text] && text.length < 11) {
        return YES;
    } else {
        return NO;
    }
}

- (void)joinClassRoomError {
    [self.activityIndicator stopAnimating];
    [self presentAlterViewTitile:@"join classRoom error" message:@"no network" cancelActionTitle:@"取消" confirmActionTitle:nil];
}

#pragma MARK -----------------------  AgoraRtmDelegate -------------------------
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    self.rtmConnectionState = state;
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberJoined:(AgoraRtmMember * _Nonnull)member {
    NSLog(@"%@----- %@",member.userId,member.channelId);
}

- (void)selectRoomTypeName:(NSString *)name {
    [self.roomType setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
}

- (void)getServerRtmId {
    WEAK(self)
    [AgoraHttpRequest get:kGetServerRtmIdUrl params:nil success:^(id responseObj) {
        [weakself.activityIndicator stopAnimating];
        NSString * str  =[[NSString alloc] initWithData:responseObj encoding:NSUTF8StringEncoding];
        weakself.roomDataManager.serverRtmId = str;
        weakself.serverRtmId = str;
        [weakself presentMiniClassViewController];
    } failure:^(NSError *error) {
        [weakself.activityIndicator stopAnimating];
        [weakself joinClassRoomError];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
