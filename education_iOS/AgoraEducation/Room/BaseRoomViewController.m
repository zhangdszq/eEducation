//
//  AEViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "BaseRoomViewController.h"
#import "TeacherModel.h"
#import "EEPageControlView.h"
#import "EEColorShowView.h"
#import "EEWhiteboardTool.h"
#import "SignalP2PModel.h"
#import "GenerateSignalBody.h"
#import "SignalManager.h"

@interface BaseRoomViewController ()<EEPageControlDelegate, EEWhiteboardToolDelegate, SignalDelegate, WhitePlayDelegate>

@property (nonatomic, strong) TeacherModel *teacherAttr;

// white
@property (nonatomic, weak) EEPageControlView *pageControlView;
@property (nonatomic, weak) EEWhiteboardTool *whiteboardTool;
@property (nonatomic, weak) EEColorShowView *colorShowView;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, assign) NSInteger sceneCount;

@end

@implementation BaseRoomViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pageControlView.delegate = self;
    self.whiteboardTool.delegate = self;
    
    [self.educationManager setSignalDelegate:self];
    [self.educationManager initStudentWithUserName:self.paramsModel.userName];
    
    WEAK(self);
    [self.colorShowView setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray = [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        [weakself.educationManager setWhiteStrokeColor:colorArray];
    }];
}

- (void)joinWhiteBoardRoomUUID:(NSString *)uuid disableDevice:(BOOL)disableDevice {
    
    WEAK(self);
    [self.educationManager initWhiteSDK:self.boardView dataSourceDelegate:self];
    [self.educationManager joinWhiteRoomWithUuid:uuid completeSuccessBlock:^(WhiteRoom * _Nullable room) {
        
        CMTime cmTime = CMTimeMakeWithSeconds(0, 100);
        [weakself.educationManager seekWhiteToTime:cmTime completionHandler:^(BOOL finished) {
        }];
        [weakself.educationManager disableWhiteDeviceInputs:disableDevice];
        [weakself.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
            weakself.sceneCount = sceneCount;
            weakself.sceneIndex = sceneIndex;
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
            [weakself.educationManager moveWhiteToContainer:sceneIndex];
        }];
        
    } completeFailBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)handleSignalWithModel:(SignalP2PModel * _Nonnull)signalModel {
    
    StudentModel *currentStuModel = [self.educationManager.currentStuModel yy_modelCopy];
    
    switch (signalModel.cmd) {
        case SignalP2PTypeMuteAudio:
        {
            currentStuModel.audio = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteAudio:
        {
            currentStuModel.audio = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeMuteVideo:
        {
            currentStuModel.video = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteVideo:
        {
            currentStuModel.video = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue: currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeApply:
        case SignalP2PTypeReject:
        case SignalP2PTypeAccept:
        case SignalP2PTypeCancel:
            break;
        case SignalP2PTypeMuteChat:
        {
            currentStuModel.chat = 0;
            NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        case SignalP2PTypeUnMuteChat:
        {
            currentStuModel.chat = 1;
            NSString *value = [GenerateSignalBody channelAttrsWithValue:currentStuModel];
            [self.educationManager updateGlobalStateWithValue:value completeSuccessBlock:nil completeFailBlock:nil];
        }
            break;
        default:
            break;
    }
}

- (void)setBoardViewFrame:(CGRect)frame {
    self.boardView.frame = frame;
}

- (void)addWhiteBoardViewToView:(UIView *)view {
    self.boardView = [[WhiteBoardView alloc] init];
    [view addSubview:self.boardView];
}

- (void)addTeacherObserver {
    self.teacherAttr = [[TeacherModel alloc] init];
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

- (void)initWhiteBoardBrushColorBlock {
    WEAK(self);
    [self.colorShowView setSelectColor:^(NSString * _Nullable colorString) {
        NSArray *colorArray  =  [UIColor convertColorToRGB:[UIColor colorWithHexString:colorString]];
        [weakself.educationManager setWhiteStrokeColor:colorArray];
    }];
}

- (void)dealloc
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    NSLog(@"BaseRoomViewController is Dealloc");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark EEPageControlDelegate
- (void)previousPage {
    if (self.sceneIndex > 0) {
        self.sceneIndex--;
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        }];
    }
}

- (void)nextPage {
    if (self.sceneIndex < self.sceneCount - 1  && self.sceneCount > 0) {
        self.sceneIndex ++;
        
        WEAK(self);
        [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
            [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        }];
    }
}

- (void)lastPage {
    self.sceneIndex = self.sceneCount - 1;
    
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, (long)weakself.sceneCount]];
    }];
}

- (void)firstPage {
    self.sceneIndex = 0;
    WEAK(self);
    [self setWhiteSceneIndex:self.sceneIndex completionSuccessBlock:^{
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
    }];
}

-(void)setWhiteSceneIndex:(NSInteger)sceneIndex completionSuccessBlock:(void (^ _Nullable)(void ))successBlock {
    
    [self.educationManager setWhiteSceneIndex:sceneIndex completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            NSLog(@"设置场景Index失败：%@", error);
        }
    }];
}

#pragma mark EEWhiteboardToolDelegate
- (void)selectWhiteboardToolIndex:(NSInteger)index {
    
    NSArray<NSString *> *applianceNameArray = @[ApplianceSelector, AppliancePencil, ApplianceText, ApplianceEraser];
    if(index < applianceNameArray.count) {
        NSString *applianceName = [applianceNameArray objectAtIndex:index];
        if(applianceName != nil) {
            [self.educationManager setWhiteApplianceName:applianceName];
        }
    }
    
    BOOL bHidden = self.colorShowView.hidden;
    // select color
    if (index == 4) {
        self.colorShowView.hidden = !bHidden;
    } else if (!bHidden) {
        self.colorShowView.hidden = YES;
    }
}

#pragma mark WhitePlayDelegate
- (void)whiteRoomStateChanged {
    WEAK(self);
    [self.educationManager currentWhiteScene:^(NSInteger sceneCount, NSInteger sceneIndex) {
        weakself.sceneCount = sceneCount;
        weakself.sceneIndex = sceneIndex;
        [weakself.pageControlView.pageCountLabel setText:[NSString stringWithFormat:@"%ld/%ld", weakself.sceneIndex + 1, weakself.sceneCount]];
        [weakself.educationManager moveWhiteToContainer:sceneIndex];
    }];
}

@end
