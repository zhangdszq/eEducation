//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MainViewController.h"
#import "AgoraHttpRequest.h"
#import "EyeCareModeUtil.h"
#import "SettingViewController.h"
#import "BCViewController.h"
#import "EEClassRoomTypeView.h"
#import "OneToOneViewController.h"
#import <Foundation/Foundation.h>
#import "AERTMMessageBody.h"
#import "MCViewController.h"
#import "AERoomViewController.h"
#import "AEStudentModel.h"
#import "RTMManager.h"

@interface MainViewController ()<AgoraRtmDelegate,AgoraRtmChannelDelegate,EEClassRoomTypeDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, copy)   NSString *serverRtmId;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, copy)   NSString  *className;
@property (nonatomic, copy)   NSString *userName;
@property (nonatomic, copy)   NSString *uid;
@property (nonatomic, strong) NSMutableArray *userArray;
@property (nonatomic, weak) EEClassRoomTypeView *classRoomTypeView;
@property (weak, nonatomic) IBOutlet UIButton *roomType;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic, assign) AgoraRtmConnectionState rtmConnectionState;
@end

@implementation MainViewController
#pragma mark ---------------------- System methods --------------------
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]) {
        [[EyeCareModeUtil sharedUtil] switchEyeCareMode:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uid = [self getUserID];
    [self joinRtm];
    [self setUpView];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)joinRtm {
    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:kAgoraAppid delegate:self];
    [self.agoraRtmKit loginByToken:nil user:self.uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode == AgoraRtmLoginErrorOk) {
            NSLog(@"rtm login success");
        }
    }];
}

- (void)joinRtmChannelCompletion:(AgoraRtmJoinChannelBlock _Nullable)completionBlock {
    self.agoraRtmChannel  =  [self.agoraRtmKit createChannelWithId:self.className delegate:self];
    [self.agoraRtmChannel joinWithCompletion:completionBlock];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textViewBottomCon.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textViewBottomCon.constant = 261;
}

- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
    self.classRoomTypeView.hidden  = YES;
}

- (void)setButtonStyle:(UIButton *)button {
    if (button.selected == YES) {
        [button setBackgroundColor:[UIColor colorWithHexString:@"006EDE"]];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16]];

    }else {
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.borderColor = [UIColor colorWithHexString:@"CCCCCC"].CGColor;
        button.layer.borderWidth = 1;
        [button setTitleColor:[UIColor colorWithHexString:@"CCCCCC"] forState:(UIControlStateNormal)];
    }
}

- (NSString *)getUserID{
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970])];
    NSString *uid =  [NSString stringWithFormat:@"%@",[timeSp substringFromIndex:4]];
    return uid;
}

- (IBAction)popupRoomType:(UIButton *)sender {
    self.classRoomTypeView.hidden = NO;
}

- (IBAction)joinRoom:(UIButton *)sender {
    [self.activityIndicator startAnimating];
    [sender setEnabled:NO];
    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0 || ![DataTypeManager judgeClassRoomText:self.classNameTextFiled.text] || ![DataTypeManager judgeClassRoomText:self.userNameTextFiled.text]) {
        [EEAlertView showAlertWithController:self title:@"用户名为11位及以内的数字或者英文字符"];
        [self.activityIndicator stopAnimating];
    }else {
        self.className = self.classNameTextFiled.text;
        self.userName = self.userNameTextFiled.text;
        if ([self.roomType.titleLabel.text isEqualToString:@"小班课"]) {
            [self presentMiniClassViewController];
        }else if ([self.roomType.titleLabel.text isEqualToString:@"大班课"]) {
            [self presentBigClassController];
        }else if ([self.roomType.titleLabel.text isEqualToString:@"一对一"]) {
            [self presentOneToOneViewController];
        }else {
            [EEAlertView showAlertWithController:self title:@"请选择房间类型"];
        }
    }
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)presentBigClassController {
    [self.activityIndicator stopAnimating];
    [self.joinButton setEnabled:YES];
    if (self.rtmConnectionState == AgoraRtmConnectionStateDisconnected) {
        [self joinRtm];
    }else {
        NSString *rtcChannelName = [NSString stringWithFormat:@"2%@",[DataTypeManager MD5WithString:self.className]];
        [self joinClassRoomWithIdentifier:@"bcroom"  rtmChannelName:rtcChannelName teacherUid:0];
    }
}

- (void)presentMiniClassViewController {
    WEAK(self)
    NSString *rtcChannelName = [NSString stringWithFormat:@"1%@",[DataTypeManager MD5WithString:self.className]];
    [self.agoraRtmKit getChannelAllAttributes:rtcChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            NSInteger studentCount = [self judgeStudentCountWithChannelAttribute:attributes];
            NSInteger teacherUid = [self getTeacherUidWithChannelAttribute:attributes];
            if (studentCount < 16) {
                [weakself joinClassRoomWithIdentifier:@"mcRoom"  rtmChannelName:rtcChannelName teacherUid:teacherUid];
            }else {
                [EEAlertView showAlertWithController:self title:@"人数已满,请换个房间"];
            }
        }else {
            [EEAlertView showAlertWithController:self title:@"获取频道属性失败"];
        }
    }];
}

- (void)presentOneToOneViewController {
    NSString *rtcChannelName = [NSString stringWithFormat:@"0%@",[DataTypeManager MD5WithString:self.className]];
    WEAK(self)
    [self.agoraRtmKit getChannelAllAttributes:rtcChannelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            NSInteger studentCount = [self judgeStudentCountWithChannelAttribute:attributes];
            NSInteger teacherUid = [self getTeacherUidWithChannelAttribute:attributes];
            if (studentCount < 1) {
                [weakself joinClassRoomWithIdentifier:@"oneToOneRoom"  rtmChannelName:rtcChannelName teacherUid:teacherUid];
            }else {
                [EEAlertView showAlertWithController:self title:@"人数已满,请换个房间"];
            }
        }else {
            [EEAlertView showAlertWithController:self title:@"获取频道属性失败"];
        }
    }];
}

- (NSInteger)judgeStudentCountWithChannelAttribute:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:attributes];
    for (AgoraRtmChannelAttribute *attr in attributes) {
        if ([attr.key isEqualToString:@"teacher"]) {
            [tempArray removeObject:attr];
        }else if ([attr.key isEqualToString:self.uid]) {
            [tempArray removeObject:attr];
        }
    }
    return tempArray.count;
}

- (NSInteger)getTeacherUidWithChannelAttribute:(NSArray<AgoraRtmChannelAttribute *> *)attributes {
    for (AgoraRtmChannelAttribute *attr in attributes) {
        NSDictionary *valueDict =   [DataTypeManager dictionaryWithJsonString:attr.value];
       if ([attr.key isEqualToString:@"teacher"]) {
           return [[valueDict objectForKey:@"uid"] integerValue];
       }
    }
    return 0;
}

- (void)joinClassRoomWithIdentifier:(NSString *)identifier  rtmChannelName:(NSString *)rtmChannelName teacherUid:(NSInteger)teacherUid {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
    AERoomViewController *viewController = [story instantiateViewControllerWithIdentifier:identifier];
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.params = @{
        @"channelName": self.className,
        @"rtmKit" : self.agoraRtmKit,
        @"userName": self.userName,
        @"userId" : self.uid,
        @"rtmChannelName":rtmChannelName,
    };
    viewController.teacherUid = teacherUid;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)joinClassRoomError {
    [self.activityIndicator stopAnimating];
    [EEAlertView showAlertWithController:self title:@"没有网络"];
}

#pragma MARK -----------------------  AgoraRtmDelegate -------------------------
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    NSLog(@"rtmConnectionState--- %ld",(long)state);
    self.rtmConnectionState = state;
}

- (void)selectRoomTypeName:(NSString *)name {
    [self.roomType setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
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
