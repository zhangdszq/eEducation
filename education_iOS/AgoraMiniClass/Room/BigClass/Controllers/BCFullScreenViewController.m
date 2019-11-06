//
//  BCFullScreenViewController.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "BCFullScreenViewController.h"
#import "EENavigationView.h"
#import "EEPageControlView.h"
#import "EEWhiteboardTool.h"
#import "EEChatContentTableView.h"
#import "EETeactherVideoView.h"

#import "BCViewController.h"
#import "EEChatTextFiled.h"
#import "EEColorShowView.h"


@interface BCFullScreenViewController ()<EEPageControlDelegate,EEWhiteboardToolDelegate,UITextFieldDelegate,AgoraRtmDelegate,AgoraRtmChannelDelegate,AgoraRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *whiteboardView;
@property (weak, nonatomic) IBOutlet EEChatContentTableView *chatContentTableView;
@property (weak, nonatomic) IBOutlet EEPageControlView *pageControlView;

@property (weak, nonatomic) IBOutlet EEWhiteboardTool *whiteboardTool;
@property (weak, nonatomic) IBOutlet UIButton *handUpButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextfiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
@property (nonatomic, strong) WhiteMemberState *memberState;

@property (weak, nonatomic) IBOutlet EEColorShowView *colorShowView;


@end

@implementation BCFullScreenViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self prefersStatusBarHidden];
    self.baseWhiteboardView.frame = self.whiteboardView.bounds;
    self.rtmKit.agoraRtmDelegate = self;
    self.rtmChannel.channelDelegate = self;
    self.rtcEngineKit.delegate = self;
    [self.chatContentTableView.messageArray addObjectsFromArray:self.messageArray.mutableCopy];
}

- (void)getWhiteboardSceneInfo {
    WEAK(self)
    [self.whiteRoom getSceneStateWithResult:^(WhiteSceneState * _Nonnull state) {
        weakself.scenes = [NSArray arrayWithArray:state.scenes];
        weakself.sceneDirectory = @"/";
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",weakself.sceneIndex,weakself.scenes.count]];
   }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11, *)) {
       } else {
           self.automaticallyAdjustsScrollViewInsets = NO;
       }
    [self.whiteboardView addSubview:self.baseWhiteboardView];

    self.navigationView.titleLabelBottomConstraint.constant = 5;
    self.navigationView.closeButtonBottomConstraint.constant = 5;
    self.navigationView.wifiSignalImage.hidden = NO;
    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;
    self.chatTextfiled.contentTextFiled.delegate = self;

     [self.navigationView.closeButton addTarget:self action:@selector(closeRoom:) forControlEvents:(UIControlEventTouchUpInside)];
    self.tipLabel.hidden = YES;

    self.handUpButton.layer.borderWidth = 1.f;
    self.handUpButton.layer.borderColor = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:229/255.0 alpha:1.0].CGColor;

    self.handUpButton.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.handUpButton.layer.cornerRadius = 6;
    self.handUpButton.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    self.handUpButton.layer.shadowOffset = CGSizeMake(0,2);
    self.handUpButton.layer.shadowOpacity = 2;
    self.handUpButton.layer.shadowRadius = 4;
    self.handUpButton.layer.masksToBounds = YES;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    self.tipLabel.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.25].CGColor;
    self.tipLabel.layer.shadowOffset = CGSizeMake(0,2);
    self.tipLabel.layer.shadowOpacity = 2;
    self.tipLabel.layer.shadowRadius = 4;
    self.tipLabel.layer.masksToBounds = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceOrientationChange:)
    name:UIDeviceOrientationDidChangeNotification object:nil];
    [self addKeyboardNotification];
    self.colorShowView.hidden = YES;
       WEAK(self)
    self.colorShowView.selectColor = ^(NSString *colorString) {
        NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        weakself.memberState.strokeColor = colorArray;
        [weakself.whiteRoom setMemberState:weakself.memberState];
    };
    self.navigationView.titleLabel.text = self.channelName;
}

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.chatTextFiledBottomCon.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.chatTextFiledBottomCon.constant = 0;
}

//设备方向改变的处理
- (void)handleDeviceOrientationChange:(NSNotification *)notification{
//    if (self.baseView.rotatingState != RotatingStateLandscape) {
//        return;
//    }
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
        {
            [self dismissViewControllerAnimated:YES completion:^{
               
            }];
        }
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}

- (void)closeRoom:(UIButton *)sender {
    NSLog(@"closeroom");
    [self.rtcEngineKit leaveChannel:nil];
    UIViewController *vc =self.presentingViewController;
    while ([vc isKindOfClass:[BCViewController class]]) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:NO completion:nil];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    WEAK(self)
    __block NSString *content = textField.text;
    [self.rtmChannel sendMessage:[[AgoraRtmMessage alloc] initWithText:textField.text] completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            messageModel.content = content;
            messageModel.name = self.selfAttrs.account;
            messageModel.isSelfSend = YES;
            [weakself.chatContentTableView.messageArray addObject:messageModel];
            [weakself.chatContentTableView reloadData];
        }
    }];
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

- (void)selectWhiteboardToolIndex:(NSInteger)index {
   self.memberState = [[WhiteMemberState alloc] init];
    switch (index) {
        case 0:
            self.memberState.currentApplianceName = ApplianceSelector;
            [self.whiteRoom setMemberState:self.memberState];
            break;
        case 1:
            self.memberState.currentApplianceName = AppliancePencil;
            [self.whiteRoom setMemberState:self.memberState];
        break;
        case 2:
            self.memberState.currentApplianceName = ApplianceText;
            [self.whiteRoom setMemberState:self.memberState];
        break;
        case 3:
            self.memberState.currentApplianceName = ApplianceEraser;
            [self.whiteRoom setMemberState:self.memberState];
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

- (void)previousPage {
    if (self.sceneIndex > 1) {
        self.sceneIndex = self.sceneIndex -1;
       [self.whiteRoom setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
       [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.scenes.count) {
        self.sceneIndex = self.sceneIndex + 1;
        [self.whiteRoom setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
    }
}

- (void)lastPage {
    self.sceneIndex = self.scenes.count;
    [self.whiteRoom setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex-1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
}

- (void)firstPage {
    self.sceneIndex = 1;
    [self.whiteRoom setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex-1].name]];
      [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld",self.sceneIndex,self.scenes.count]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"BCFullScreenViewController is dealloc");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
