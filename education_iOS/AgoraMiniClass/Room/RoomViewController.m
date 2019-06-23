//
//  RoomViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "RoomViewController.h"
#import <White-SDK-iOS/WhiteSDK.h>
#import "WhiteBoardToolControl.h"
#import "RoomManageView.h"
#import "ChatTextView.h"
#import "MemberListView.h"
#import "MessageListView.h"
#import "StudentVideoListView.h"

@interface RoomViewController ()<WhiteCommonCallbackDelegate,AgoraRtcEngineDelegate>
@property (nonatomic, strong) WhiteSDK *writeSDK;
@property (nonatomic, strong) WhiteRoom *whiteRoom;
@property (nonatomic, strong) WhiteBoardView *whiteBoardView;
@property (nonatomic, strong)   NSMutableArray *remoteUserArray;
@property (weak, nonatomic) IBOutlet UIView *baseWhiteBoardView;
@property (weak, nonatomic) IBOutlet UIView *teactherVideoView;
@property (weak, nonatomic) IBOutlet WhiteBoardToolControl *whiteBoardTool;
@property (weak, nonatomic) IBOutlet UIButton *leaveRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *whiteBoardControlSizeButton;
@property (weak, nonatomic) IBOutlet RoomManageView *roomManagerView;
@property (weak, nonatomic) IBOutlet ChatTextView *chatTextView;
@property (weak, nonatomic) IBOutlet MemberListView *memberListView;
@property (weak, nonatomic) IBOutlet MessageListView *messageListView;
@property (weak, nonatomic) IBOutlet StudentVideoListView *studentListView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseWhiteBoardTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteBoardWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeftCon;

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.remoteUserArray = [NSMutableArray array];
    [self setUpView];
    [self addWhiteBoardKit];
    self.agoraKit.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    [self loadAgoraKit];

}

- (void)loadAgoraKit {
    AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
    canvas.uid  = 0;
    canvas.view = self.teactherVideoView;
    [self.agoraKit setupLocalVideo:canvas];
    self.studentListView.studentVideoList = ^(UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nullable indexPath) {
        if (self.remoteUserArray.count > 0) {
            AgoraRtcVideoCanvas *canvas = [[AgoraRtcVideoCanvas alloc] init];
            canvas.uid = [self.remoteUserArray[indexPath.row] integerValue];
            canvas.view = cell.contentView;
            [self.agoraKit setupRemoteVideo:canvas];
        }
    };
        [self.agoraKit joinChannelByToken:nil channelId:@"123321" info:nil uid:0 joinSuccess:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.textViewBottomCon.constant = frame.size.height;
    self.textViewLeftCon.constant = - (frame.size.width - self.roomManagerView.frame.size.width -40);
    [NSLayoutConstraint activateConstraints:@[self.textViewLeftCon]];

}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    // 获取键盘的高度
    self.textViewBottomCon.constant = 5;
    self.textViewLeftCon.constant = 5;
}

- (void)setUpView {
    [self.baseWhiteBoardView addSubview:self.whiteBoardView];
    [self.baseWhiteBoardView bringSubviewToFront:self.whiteBoardTool];
    [self.baseWhiteBoardView bringSubviewToFront:self.leaveRoomButton];
    [self.baseWhiteBoardView bringSubviewToFront:self.whiteBoardControlSizeButton];
}

- (void)addWhiteBoardKit {
    self.writeSDK = [[WhiteSDK alloc] initWithWhiteBoardView:self.whiteBoardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
    //当前步骤，新增代码
    [self creatNewRoomRequestWithResult:^(BOOL success, id response) {
        if (success) {
            //RoomToken，以及UUID获取，根据您后台服务器返回结构不同，获取方式会有所不同
            NSString *roomToken = response[@"msg"][@"roomToken"];
            NSString *uuid = response[@"msg"][@"room"][@"uuid"];
            [self.writeSDK joinRoomWithRoomUuid:uuid roomToken:roomToken callbacks:(id<WhiteRoomCallbackDelegate>)self completionHandler:^(BOOL success, WhiteRoom *room, NSError *error) {
                if (success) {
                    self.title = NSLocalizedString(@"我的白板", nil);
                    self.whiteRoom = room;
                    WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
                    //白板初始状态时，教具默认为画笔pencil。
                    memberState.currentApplianceName = AppliancePencil;
                    [self.whiteRoom setMemberState:memberState];
                } else {
                    self.title = NSLocalizedString(@"加入失败", nil);
                    //TODO: error
                }
            }];
        } else {
            // 获取RoomToken，以及RoomUUID失败
            NSLog(@"dasjkhdahasdlkhsd");
        }
    }];
    self.whiteBoardTool.selectAppliance = ^(WhiteBoardAppliance applicate) {
        switch (applicate) {
            case WhiteBoardAppliancePencil:
            {
                WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
                //白板初始状态时，教具默认为 pencil
                memberState.currentApplianceName = AppliancePencil;
                  [self.whiteRoom setMemberState:memberState];
            }
                break;
            case WhiteBoardApplianceSelector:
            {
                WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
                //白板初始状态时，教具默认为 pencil
                memberState.currentApplianceName = ApplianceSelector;
                [self.whiteRoom setMemberState:memberState];
            }
                break;
            case WhiteBoardApplianceRectangle:
            {
                WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
                //白板初始状态时，教具默认为 pencil
                memberState.currentApplianceName =  ApplianceRectangle;
                [self.whiteRoom setMemberState:memberState];
            }
                break;
            case WhiteBoardApplianceEraser:
            {
                WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
                //白板初始状态时，教具默认为 pencil
                memberState.currentApplianceName =  ApplianceEraser;
                [self.whiteRoom setMemberState:memberState];
            }
                break;
            case WhiteBoardApplianceText:
            {
                WhiteMemberState *memberState = [[WhiteMemberState alloc] init];
                //白板初始状态时，教具默认为 pencil
                memberState.currentApplianceName =  ApplianceText;
                [self.whiteRoom setMemberState:memberState];
            }
                break;

            default:
                break;
        }
    };
}
- (void)creatNewRoomRequestWithResult:(void (^) (BOOL success, id response))result;
{
    // self.token 为字符串，具体的获取，请参考 https://developer.herewhite.com/#/concept
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://cloudcapiv4.herewhite.com/room?token=%@",kHereWriteToken]]];
    NSMutableURLRequest *modifyRequest = [request mutableCopy];
    [modifyRequest setHTTPMethod:@"POST"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [modifyRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //@"mode": @"historied" 为可回放房间，默认为持久化房间。
    NSDictionary *params = @{@"name": @"test", @"limit": @110, @"mode": @"historied"};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    [modifyRequest setHTTPBody:postData];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:modifyRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error && result) {
                result(NO, nil);
            } else if (result) {
                NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                result(YES, responseObject);
            }
        });
    }];
    [task resume];
}

- (WhiteBoardView *)whiteBoardView {
    if (!_whiteBoardView) {
        _whiteBoardView = [[WhiteBoardView alloc] init];
        _whiteBoardView.frame = self.baseWhiteBoardView.bounds;
        _whiteBoardView.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
    }
    return _whiteBoardView;
}

- (IBAction)leaveRoom:(UIButton *)sender {
    [self.agoraKit leaveChannel:nil];
    UIViewController * presentingViewController = self.presentingViewController;
    while (presentingViewController.presentingViewController) {
        presentingViewController = presentingViewController.presentingViewController;
    }
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)whiteBoardZoom:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        self.baseWhiteBoardTopCon.constant = 10;
        [NSLayoutConstraint deactivateConstraints:@[self.whiteBoardWidthCon]];
        self.whiteBoardWidthCon = [NSLayoutConstraint constraintWithItem:self.baseWhiteBoardView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.roomManagerView attribute:NSLayoutAttributeWidth multiplier:63 constant:0];
        [NSLayoutConstraint activateConstraints:@[self.whiteBoardWidthCon]];
        [sender setImage:[UIImage imageNamed:@"whiteBoardMin"] forState:(UIControlStateNormal)];
        self.roomManagerView.hidden = YES;
        [self.view bringSubviewToFront:self.teactherVideoView];
    }else {
        self.baseWhiteBoardTopCon.constant = 105;
        self.roomManagerView.hidden = NO;
        [NSLayoutConstraint deactivateConstraints:@[self.whiteBoardWidthCon]];
        self.whiteBoardWidthCon = [NSLayoutConstraint constraintWithItem:self.baseWhiteBoardView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.roomManagerView attribute:NSLayoutAttributeWidth multiplier:2 constant:0];
        [NSLayoutConstraint activateConstraints:@[self.whiteBoardWidthCon]];
        [sender setImage:[UIImage imageNamed:@"whiteBoardMax"] forState:(UIControlStateNormal)];
    }
}
#pragma mark ---------- Agora Delegate -----------
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    [self.remoteUserArray addObject:@(uid)];
    [self.studentListView addUserId:uid];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    [self.remoteUserArray removeObject:@(uid)];
    [self.studentListView removeUserId:uid];

}

#pragma mark  --------  Mandatory landscape -------
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)dealloc
{
    NSLog(@"TestRoomViewController dealloc");
}
@end
