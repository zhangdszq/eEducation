//
//  AEViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "AERoomViewController.h"
#import "AETeactherModel.h"
#import "AgoraHttpRequest.h"
#import "EEPageControlView.h"
#import "EEWhiteboardTool.h"
#import "EEColorShowView.h"
#import "EEWhiteboardTool.h"
#import "AEP2pMessageModel.h"
#import "AERTMMessageBody.h"
#import "EEChatTextFiled.h"

#import "MessageManager.h"

@interface AERoomViewController ()<WhiteCommonCallbackDelegate,WhiteRoomCallbackDelegate,EEPageControlDelegate,EEWhiteboardToolDelegate, MessageDataSourceDelegate>
@property (nonatomic, strong) AETeactherModel *teacherAttr;
@property (nonatomic, weak) EEPageControlView *pageControlView;
@property (nonatomic, weak) EEWhiteboardTool *whiteboardTool;
@property (nonatomic, weak) EEColorShowView *colorShowView;
@property (nonatomic, weak) UIView *shareScreenView;
@property (nonatomic, weak) EEChatTextFiled *chatTextFiled;
@end

@implementation AERoomViewController
- (void)setParams:(NSDictionary *)params {
    _params = params;
 
    self.channelName = params[@"channelName"];
    self.userName = params[@"userName"];
    self.userId = params[@"userId"];
    self.rtmChannelName = params[@"rtmChannelName"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;
}

- (void)joinWhiteBoardRoomUUID:(NSString *)uuid disableDevice:(BOOL)disableDevice {
    self.sdk = [[WhiteSDK alloc] initWithWhiteBoardView:self.boardView config:[WhiteSdkConfiguration defaultConfig] commonCallbackDelegate:self];
    if (self.room) {
        [self.room disconnect:^{
        }];
    }
    WEAK(self)
    [AgoraHttpRequest POSTWhiteBoardRoomWithUuid:uuid token:^(NSString * _Nonnull token) {
        WhiteRoomConfig *roomConfig = [[WhiteRoomConfig alloc] initWithUuid:uuid roomToken:token];
        [weakself.sdk joinRoomWithConfig:roomConfig callbacks:self completionHandler:^(BOOL success, WhiteRoom * _Nullable room, NSError * _Nullable error) {
            weakself.room = room;
            [weakself getWhiteboardSceneInfo];
            [room refreshViewSize];
            [room disableCameraTransform:NO];
            [weakself.room disableDeviceInputs:disableDevice];
            [weakself.room moveCameraToContainer:[[WhiteRectangleConfig alloc] initWithInitialPosition:720 height:720]];
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
        weakself.sceneIndex = state.index;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%zd",(long)weakself.sceneIndex+1,weakself.scenes.count]];
    }];
}

- (void)addWhiteBoardViewToView:(UIView *)view {
    self.boardView = [[WhiteBoardView alloc] init];
    [view addSubview:self.boardView];
}

- (void)addTeacherObserver {
    self.teacherAttr = [[AETeactherModel alloc] init];
    [self.teacherAttr addObserver:self forKeyPath:@"shared_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"whiteboard_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"mute_chat" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"account" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"link_uid" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.teacherAttr addObserver:self forKeyPath:@"class_state" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)removeTeacherObserver {
    [self.teacherAttr removeObserver:self forKeyPath:@"shared_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"whiteboard_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"mute_chat"];
    [self.teacherAttr removeObserver:self forKeyPath:@"account"];
    [self.teacherAttr removeObserver:self forKeyPath:@"link_uid"];
    [self.teacherAttr removeObserver:self forKeyPath:@"class_state"];
}

- (void)addShareScreenVideoWithUid:(NSInteger)uid {
    self.shareScreenView.hidden = NO;
    self.shareScreenCanvas = [[AgoraRtcVideoCanvas alloc] init];
    self.shareScreenCanvas.uid = uid;
    self.shareScreenCanvas.view = self.shareScreenView;
    self.shareScreenCanvas.renderMode = AgoraVideoRenderModeFit;
    [self.rtcEngineKit setupRemoteVideo:self.shareScreenCanvas];
}

- (void)removeShareScreen {
    self.shareScreenView.hidden = YES;
    self.shareScreenCanvas = nil;
}

- (void)setWhiteBoardBrushColor {
    WEAK(self)
    [self.colorShowView setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        weakself.memberState.strokeColor = colorArray;
        [weakself.room setMemberState:weakself.memberState];
    }];
}

- (void)teacherMuteStudentVideo:(BOOL)mute {

}

- (void)teacherMuteStudentAudio:(BOOL)mute {
    
}
#pragma mark ---------------------------------------- Delegate ----------------------------------------
- (void)fireRoomStateChanged:(WhiteRoomState *)modifyState {
    self.sceneIndex = modifyState.sceneState.index;
    if (modifyState.sceneState && modifyState.sceneState.scenes.count > self.scenes.count) {
        self.scenes = [NSArray arrayWithArray:modifyState.sceneState.scenes];
        self.sceneDirectory = @"/";
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
    }
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%zd",(long)self.sceneIndex+1,self.scenes.count]];
}

- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%zd",(long)self.sceneIndex+1,self.scenes.count]];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.scenes.count - 1  && self.scenes.count > 0) {
        self.sceneIndex ++;
        [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex].name]];
        [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%zd",(long)self.sceneIndex+1,self.scenes.count]];
    }
}

- (void)lastPage {
    self.sceneIndex = self.scenes.count;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[self.sceneIndex - 1].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%zd/%zd",self.scenes.count,self.scenes.count]];
}

- (void)firstPage {
    self.sceneIndex = 0;
    [self.room setScenePath:[NSString stringWithFormat:@"/%@",self.scenes[0].name]];
    [self.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"1/%zd",self.scenes.count]];
}

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

- (void)dealloc
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    NSLog(@"AERoomViewController is Dealloc");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
