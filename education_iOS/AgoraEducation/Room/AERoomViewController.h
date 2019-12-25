//
//  AEViewController.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EducationManager.h"
#import "AEStudentModel.h"

@interface RoomParamsModel : NSObject

@property (nonatomic, copy) NSString * _Nonnull className;
@property (nonatomic, copy) NSString * _Nonnull userName;
@property (nonatomic, copy) NSString * _Nonnull userId;
@property (nonatomic, copy) NSString * _Nonnull channelName;

@end


NS_ASSUME_NONNULL_BEGIN

@interface AERoomViewController : UIViewController

@property (nonatomic, strong) RoomParamsModel *paramsModel;
@property (nonatomic, strong) EducationManager *educationManager;

@property (nonatomic, strong) WhiteBoardView *boardView;
- (void)joinWhiteBoardRoomUUID:(NSString *)uuid disableDevice:(BOOL)disableDevice;

- (void)addTeacherObserver;
- (void)removeTeacherObserver;

- (void)addWhiteBoardViewToView:(UIView *)view;
- (void)setBoardViewFrame:(CGRect)frame;


- (void)handleSignalWithModel:(AEP2pMessageModel * _Nonnull)signalModel;

@end

NS_ASSUME_NONNULL_END
