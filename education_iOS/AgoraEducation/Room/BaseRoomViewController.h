//
//  AEViewController.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/23.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"

#import "EducationManager.h"
#import "StudentModel.h"
#import "RoomParamsModel.h"
#import "KeyCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseRoomViewController : UIViewController

@property (nonatomic, strong) RoomParamsModel *paramsModel;
@property (nonatomic, strong) EducationManager *educationManager;

@property (nonatomic, strong) WhiteBoardView *boardView;
- (void)joinWhiteBoardRoomUUID:(NSString *)uuid disableDevice:(BOOL)disableDevice;

- (void)addTeacherObserver;
- (void)removeTeacherObserver;

- (void)addWhiteBoardViewToView:(UIView *)view;
- (void)setBoardViewFrame:(CGRect)frame;

- (void)handleSignalWithModel:(SignalP2PModel * _Nonnull)signalModel;

@end

NS_ASSUME_NONNULL_END
