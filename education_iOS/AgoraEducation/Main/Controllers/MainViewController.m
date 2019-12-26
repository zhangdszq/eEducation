//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "EEClassRoomTypeView.h"
#import "SettingViewController.h"
#import "BaseRoomViewController.h"
#import "GenerateSignalBody.h"
#import "EyeCareModeUtil.h"
#import "EducationManager.h"

#import "NSString+MD5.h"
#import "KeyCenter.h"

typedef NS_ENUM(NSUInteger, SceneMode) {
    SceneMode1V1 = 1,
    SceneModeSmall = 2,
    SceneModeBig = 3,
};

@interface MainViewController ()<EEClassRoomTypeDelegate, SignalDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet UIButton *roomType;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic, weak) EEClassRoomTypeView *classRoomTypeView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong) EducationManager *educationManager;

@end

@implementation MainViewController

#pragma mark LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.uid = [self generateUserID];
    self.educationManager = [EducationManager new];
    
    [self setupGlobalState];
    [self setUpView];
    [self addTouchedRecognizer];
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.educationManager setSignalDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]) {
        [[EyeCareModeUtil sharedUtil] switchEyeCareMode:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.educationManager releaseResources];
}

#pragma mark Private Function
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
- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
    self.classRoomTypeView.hidden  = YES;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onMessageDisconnect) name:NOTICE_KEY_ON_MESSAGE_DISCONNECT object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textViewBottomCon.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textViewBottomCon.constant = 261;
}

- (void)setupGlobalState {

    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = self.uid;
    [self.educationManager initSignalWithModel:model dataSourceDelegate:self completeSuccessBlock:nil completeFailBlock:nil];
}

- (NSString *)generateUserID {
    NSDate *datenow = [NSDate date];
    long lTime = (long)([datenow timeIntervalSince1970] * 1000) % 1000000;
    NSString *uid = [NSString stringWithFormat:@"%ld", lTime];
    return uid;
}

- (BOOL)checkClassRoomText:(NSString *)text {
    NSString *regex = @"^[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:text] && text.length <= 11) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Click Event
- (IBAction)popupRoomType:(UIButton *)sender {
    self.classRoomTypeView.hidden = NO;
}

- (IBAction)joinRoom:(UIButton *)sender {
    
    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0 || ![self checkClassRoomText:self.classNameTextFiled.text] || ![self checkClassRoomText:self.userNameTextFiled.text]) {
        
        [AlertViewUtil showAlertWithController:self title:@"用户名为11位及以内的数字或者英文字符"];
        return;
    }
    
    SceneMode mode = SceneMode1V1;
    if ([self.roomType.titleLabel.text isEqualToString:@"一对一"]) {
        mode = SceneMode1V1;
    } else if ([self.roomType.titleLabel.text isEqualToString:@"小班课"]) {
        mode = SceneModeSmall;
    } else if ([self.roomType.titleLabel.text isEqualToString:@"大班课"]) {
        mode = SceneModeBig;
    } else {
        [AlertViewUtil showAlertWithController:self title:@"请选择房间类型"];
        return;
    }
    
    [self joinClassRoomWithMode:mode];
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)joinClassRoomWithMode:(SceneMode)sceneMode {
            
    NSString *className = self.classNameTextFiled.text;
    NSString *userName = self.userNameTextFiled.text;
    
    NSString *channelName = @"";
    NSInteger maxUserCount = 0;
    NSString *vcIdentifier = @"";
    
    switch (sceneMode) {
        case SceneMode1V1:
        {
            channelName = [NSString stringWithFormat:@"0%@", className.md5];
            maxUserCount = 1;
            vcIdentifier = @"oneToOneRoom";
        }
            break;
        case SceneModeSmall:
        {
            channelName = [NSString stringWithFormat:@"1%@", className.md5];
            maxUserCount = 16;
            vcIdentifier = @"mcRoom";
        }
            break;
        case SceneModeBig:
        {
            channelName = [NSString stringWithFormat:@"2%@", className.md5];
            maxUserCount = NSIntegerMax;
            vcIdentifier = @"bcroom";
        }
            break;
        default:
            break;
    }
    
    RoomParamsModel *paramsModel = [RoomParamsModel new];
    paramsModel.className = className;
    paramsModel.userName = userName;
    paramsModel.userId = self.uid;
    paramsModel.channelName = channelName;
    if(maxUserCount == NSIntegerMax) {
        [self joinRoomVCWithModel: paramsModel vcIdentifier: vcIdentifier];
        return;
    }

    [self.activityIndicator startAnimating];
    [self.joinButton setEnabled:NO];
    
    WEAK(self);
    [self.educationManager queryOnlineStudentCountWithChannelName:channelName maxCount:maxUserCount completeSuccessBlock:^(NSInteger count) {
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
        
        if (count < maxUserCount) {
            [weakself joinRoomVCWithModel: paramsModel vcIdentifier: vcIdentifier];
            
        } else {
            [AlertViewUtil showAlertWithController:self title:@"人数已满,请换个房间"];
        }
        
    } completeFailBlock:^{
        
        [AlertViewUtil showAlertWithController:self title:@"请求失败"];
        
        [weakself.activityIndicator stopAnimating];
        [weakself.joinButton setEnabled:YES];
    }];
}

- (void)joinRoomVCWithModel:(RoomParamsModel *)paramsModel vcIdentifier:(NSString *) identifier {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
    BaseRoomViewController *viewController = [story instantiateViewControllerWithIdentifier:identifier];
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.paramsModel = paramsModel;
    viewController.educationManager = self.educationManager;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark EEClassRoomTypeDelegate
- (void)selectRoomTypeName:(NSString *)name {
    [self.roomType setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
}

#pragma mark Notification
-(void)onMessageDisconnect{
    [self setupGlobalState];
}

@end
