//
//  AEViewController.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WhiteSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AERoomViewController : UIViewController
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, strong) AgoraRtmKit *rtmKit;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *rtmChannelName;
@property (nonatomic, strong) WhiteBoardView *boardView;

@property (nonatomic, strong) WhiteSDK *sdk;
@property (nonatomic, strong, nullable) WhiteRoom *room;
@property (nonatomic, assign) NSInteger sceneIndex;
@property (nonatomic, copy) NSString *sceneDirectory;
@property (nonatomic, strong) NSArray<WhiteScene *> *scenes;
- (void)joinWhiteBoardRoomUUID:(NSString *)uuid;
- (void)getWhiteboardSceneInfo;
- (void)addWhiteBoardViewToView:(UIView *)view;

- (void)addTeacherObserver;
- (void)removeTeacherObserver;
@end

NS_ASSUME_NONNULL_END
