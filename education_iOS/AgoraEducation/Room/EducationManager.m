//
//  EducationManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EducationManager.h"
#import "AERTMMessageBody.h"
#import "SignalManager.h"

@interface EducationManager()

@property (nonatomic, strong) SignalManager *signalManager;


@end

static EducationManager *manager = nil;

@implementation EducationManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock {
    
    self.signalManager = [SignalManager alloc];
    
//    self.messageModel = model;
//    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:model.appId delegate:self];
//    [self.agoraRtmKit loginByToken:model.token user:model.uid completion:^(AgoraRtmLoginErrorCode errorCode) {
//        if (errorCode == AgoraRtmLoginErrorOk) {
//            NSLog(@"rtm login success");
//            if(successBlock != nil){
//                successBlock();
//            }
//
//        } else {
//            if(failBlock != nil){
//                failBlock();
//            }
//        }
//    }];
}

- (void)sendMessageWithValue:(NSString *)value {
//    SignalManager.shareManager.currentStuModel =
//
//
//    NSString *value = [AERTMMessageBody sendP2PMessageWithName:self.userName content:content];
//    [SignalManager.shareManager sendMessageWithValue:value];
}

@end
