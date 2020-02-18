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
#import "GenerateSignalBody.h"
#import "EyeCareModeUtil.h"

#import "MinEducationManager.h"
#import "BigEducationManager.h"

#import "OneToOneViewController.h"
#import "MCViewController.h"
#import "BCViewController.h"

#import "NSString+MD5.h"
#import "KeyCenter.h"

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

@end

@implementation MainViewController

#pragma mark LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.uid = [self generateUserID];
    [self setupView];
    [self addTouchedRecognizer];
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
//    [self.educationManager setSignalDelegate:self];
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
//    [self.educationManager releaseResources];
}

#pragma mark Private Function
- (void)setupView {
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
    
    self.classNameTextFiled.delegate = self;
    self.userNameTextFiled.delegate = self;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textViewBottomCon.constant = bottom;
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.textViewBottomCon.constant = 261;
}

- (NSString *)generateUserID {
    NSDate *datenow = [NSDate date];
    long lTime = (long)([datenow timeIntervalSince1970] * 1000) % 1000000;
    NSString *uid = [NSString stringWithFormat:@"%ld", lTime];
    return uid;
}

- (BOOL)checkFieldText:(NSString *)text {
    
    int strlength = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    
    if(strlength <= 20){
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

    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0 || ![self checkFieldText:self.classNameTextFiled.text] || ![self checkFieldText:self.userNameTextFiled.text]) {
        
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"UserNameVerifyText", nil)];
        return;
    }

    NSString *className = self.classNameTextFiled.text;
    if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"OneToOneText", nil)]) {
        
        NSString *channelName = [NSString stringWithFormat:@"0%@", className.md5];
        [self join1V1RoomWithChannelName:channelName maxStudentCount:1 vcIdentifier:@"oneToOneRoom"];

    } else if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"SmallClassText", nil)]) {

        NSString *channelName = [NSString stringWithFormat:@"1%@", className.md5];
        [self joinMinRoomWithChannelName:channelName maxStudentCount:16 vcIdentifier:@"mcRoom"];
        
    } else if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"LargeClassText", nil)]) {

        NSString *channelName = [NSString stringWithFormat:@"2%@", className.md5];
        [self joinBigRoomWithChannelName:channelName vcIdentifier:@"bcroom"];
        
    } else {
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"RoomTypeVerifyText", nil)];
        return;
    }
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}


- (void)join1V1RoomWithChannelName:(NSString *)channelName maxStudentCount:(NSInteger)maxCount vcIdentifier:(NSString*)identifier {
        
    WEAK(self);
    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = self.uid;
    OneToOneEducationManager *educationManager = [OneToOneEducationManager new];
    [educationManager initSignalWithModel:model dataSourceDelegate:nil completeSuccessBlock:^{
        
        [weakself.activityIndicator startAnimating];
        [weakself.joinButton setEnabled:NO];
        
        [educationManager queryOnlineStudentCountWithChannelName:channelName maxCount:maxCount completeSuccessBlock:^(NSInteger count) {
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
            
            if (count < maxCount) {
                
                NSString *className = weakself.classNameTextFiled.text;
                NSString *userName = weakself.userNameTextFiled.text;
                
                VCParamsModel *paramsModel = [VCParamsModel new];
                paramsModel.className = className;
                paramsModel.userName = userName;
                paramsModel.userId = weakself.uid;
                paramsModel.channelName = channelName;
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
               OneToOneViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
               vc.modalPresentationStyle = UIModalPresentationFullScreen;
               vc.paramsModel = paramsModel;
               vc.educationManager = educationManager;
               [weakself presentViewController:vc animated:YES completion:nil];
                
            } else {
                [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"RoomCountVerifyText", nil)];
                
            }
            
        } completeFailBlock:^{
        
            [AlertViewUtil showAlertWithController:weakself title:NSLocalizedString(@"RequestFailedText", nil)];
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
        }];
        
        
    } completeFailBlock: nil];
}

- (void)joinMinRoomWithChannelName:(NSString *)channelName maxStudentCount:(NSInteger)maxCount vcIdentifier:(NSString*)identifier {
        
    WEAK(self);
    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = self.uid;
    MinEducationManager *educationManager = [MinEducationManager new];
    [educationManager initSignalWithModel:model dataSourceDelegate:nil completeSuccessBlock:^{
        
        [weakself.activityIndicator startAnimating];
        [weakself.joinButton setEnabled:NO];
        
        [educationManager queryOnlineStudentCountWithChannelName:channelName maxCount:maxCount completeSuccessBlock:^(NSInteger count) {
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
            
            if (count < maxCount) {
                
                NSString *className = weakself.classNameTextFiled.text;
                NSString *userName = weakself.userNameTextFiled.text;
                
                VCParamsModel *paramsModel = [VCParamsModel new];
                paramsModel.className = className;
                paramsModel.userName = userName;
                paramsModel.userId = weakself.uid;
                paramsModel.channelName = channelName;
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
                MCViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.paramsModel = paramsModel;
                vc.educationManager = educationManager;
                [weakself presentViewController:vc animated:YES completion:nil];
                
            } else {
                [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"RoomCountVerifyText", nil)];
                
            }
            
        } completeFailBlock:^{
            
            [AlertViewUtil showAlertWithController:weakself title:NSLocalizedString(@"RequestFailedText", nil)];
            
            [weakself.activityIndicator stopAnimating];
            [weakself.joinButton setEnabled:YES];
        }];
        
        
    } completeFailBlock: nil];
}

- (void)joinBigRoomWithChannelName:(NSString *)channelName vcIdentifier:(NSString*)identifier {
        
    WEAK(self);
    SignalModel *model = [SignalModel new];
    model.appId = [KeyCenter agoraAppid];
    model.token = [KeyCenter agoraRTMToken];
    model.uid = self.uid;
    BigEducationManager *educationManager = [BigEducationManager new];
    [educationManager initSignalWithModel:model dataSourceDelegate:nil completeSuccessBlock:^{
        
        NSString *className = weakself.classNameTextFiled.text;
        NSString *userName = weakself.userNameTextFiled.text;
        
        VCParamsModel *paramsModel = [VCParamsModel new];
        paramsModel.className = className;
        paramsModel.userName = userName;
        paramsModel.userId = weakself.uid;
        paramsModel.channelName = channelName;
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
        BCViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.paramsModel = paramsModel;
        vc.educationManager = educationManager;
        [weakself presentViewController:vc animated:YES completion:nil];
        
    } completeFailBlock: nil];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark EEClassRoomTypeDelegate
- (void)selectRoomTypeName:(NSString *)name {
    [self.roomType setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
}
@end
