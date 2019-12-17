//
//  SignalManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "SignalManager.h"
#import "AEP2pMessageModel.h"
#import "AERTMMessageBody.h"
#import "AERoomMessageModel.h"

NSString * const RoleTypeTeacther = @"teacher";
//NSString * const RoleTypeStudent = @"student";

@interface SignalManager()<AgoraRtmDelegate, AgoraRtmChannelDelegate>

@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, strong) NSString *channelName;

@end

static SignalManager *manager = nil;
@implementation SignalManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock {
    
    self.messageModel = model;
    self.agoraRtmKit = [[AgoraRtmKit alloc] initWithAppId:model.appId delegate:self];
    [self.agoraRtmKit loginByToken:model.token user:model.uid completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode == AgoraRtmLoginErrorOk) {
            NSLog(@"rtm login success");
            if(successBlock != nil){
                successBlock();
            }
            
        } else {
            if(failBlock != nil){
                failBlock();
            }
        }
    }];
}

- (void)queryGlobalStateWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block {
    
    WEAK(self)
    [self.agoraRtmKit getChannelAllAttributes:channelName completion:^(NSArray<AgoraRtmChannelAttribute *> * _Nullable attributes, AgoraRtmProcessAttributeErrorCode errorCode) {
        
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            
            if(block != nil){
                RolesInfoModel *rolesInfoModel = [weakself fixRolesInfoModelWithAttributes:attributes];
                block(rolesInfoModel);
                return;
            }
            
        } else {
            NSLog(@"get channel attributes error");
        }
        
        if(block != nil){
            RolesInfoModel *rolesInfoModel = [RolesInfoModel new];
            block(rolesInfoModel);
        }
    }];
    
}

- (RolesInfoModel *)fixRolesInfoModelWithAttributes:(NSArray<AgoraRtmChannelAttribute *> * _Nullable) attributes {
    
    AETeactherModel *teaModel;
    NSMutableArray<RolesStudentInfoModel*> *stuArray = [NSMutableArray array];

    for (AgoraRtmChannelAttribute *channelAttr in attributes) {
        
        NSDictionary *valueDict = [JsonAndStringConversions dictionaryWithJsonString:channelAttr.value];
        
        if ([channelAttr.key isEqualToString:RoleTypeTeacther]) {
            
            if(teaModel == nil){
                teaModel = [AETeactherModel new];
            }
            [teaModel modelWithDict:valueDict];
        
        } else {
            AEStudentModel *model = [AEStudentModel yy_modelWithDictionary:valueDict];
            
            RolesStudentInfoModel *infoModel = [RolesStudentInfoModel new];
            infoModel.studentModel = model;
            infoModel.attrKey = channelAttr.key;
            
            [stuArray addObject:infoModel];
            
            if([model.uid isEqualToString: self.messageModel.uid]) {
                self.currentStuModel = model;
            }
        }
    }
    
    self.currentTeaModel = teaModel;
    
    RolesInfoModel *rolesInfoModel = [RolesInfoModel new];
    rolesInfoModel.teactherModel = teaModel;
    rolesInfoModel.studentModels = stuArray;
    
    return rolesInfoModel;
}

-(void)initCurrentStuModel {
    self.currentStuModel = [AEStudentModel new];
    self.currentStuModel.uid = self.messageModel.uid;
    self.currentStuModel.account = self.messageModel.userName;
    self.currentStuModel.video = 1;
    self.currentStuModel.audio = 1;
    self.currentStuModel.chat = 1;
}

- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock {

    self.channelName = channelName;
    [self initCurrentStuModel];

    self.agoraRtmChannel = [self.agoraRtmKit createChannelWithId:channelName delegate:self];
    [self.agoraRtmChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
        
        if(errorCode == AgoraRtmJoinChannelErrorOk){
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock();
            }
        }
    }];
}


- (void)sendMessageWithValue:(NSString *)value {
    
    NSString *messageBody = [AERTMMessageBody sendP2PMessageWithName:self.messageModel.userName content:value];

    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:messageBody];
    
    WEAK(self)
    [self.agoraRtmChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            AERoomMessageModel *messageModel = [[AERoomMessageModel alloc] init];
            messageModel.content = value;
            messageModel.account = weakself.messageModel.userName;
            messageModel.isSelfSend = YES;
            
            if(weakself.messageDelegate != nil && [weakself.messageDelegate respondsToSelector:@selector(onUpdateMessage:)]){
                [weakself.messageDelegate onUpdateMessage:messageModel];
            }
        }
    }];
}

- (void)setSignalWithValue:(NSString *)value toPeer:(NSString *)peerId completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock {
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:value];
    
    [self.agoraRtmKit sendMessage:rtmMessage toPeer:peerId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        if (errorCode == AgoraRtmSendPeerMessageErrorOk) {
            if(successBlock != nil){
                successBlock();
            }
        } else {
            if(failBlock != nil){
                failBlock();
            }
        }
    }];
    
}

-(void)leaveChannel {
    if(self.channelName != nil){
        
        SignalManager.shareManager.messageDelegate = nil;
        
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [self.agoraRtmKit deleteChannel:self.channelName AttributesByKeys:@[self.messageModel.uid] Options:options completion:nil];
        
        [self.agoraRtmChannel leaveWithCompletion:nil];
        
        self.currentStuModel = nil;
        self.currentTeaModel = nil;
        self.channelName = nil;
    }
}

#pragma mark AgoraRtmDelegate
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    NSLog(@"rtmConnectionState--- %ld",(long)state);
    
    // 状态丢失的时候，发出通知
    if(state == AgoraRtmConnectionStateDisconnected) {
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_ON_MESSAGE_DISCONNECT object:nil];
    }
}

#pragma mark AgoraRtmChannelDelegate
- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId {
    
    if (self.currentTeaModel && [peerId isEqualToString:self.currentTeaModel.uid]) {
        NSDictionary *dict = [JsonAndStringConversions dictionaryWithJsonString:message.text];
        AEP2pMessageModel *model = [AEP2pMessageModel yy_modelWithDictionary:dict];
        
        [NSNotificationCenter.defaultCenter postNotificationName:NOTICE_KEY_ON_SIGNAL_RECEIVED object:model];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member {
    NSDictionary *dict =  [JsonAndStringConversions dictionaryWithJsonString:message.text];
    AERoomMessageModel *messageModel = [AERoomMessageModel yy_modelWithDictionary:dict];
    messageModel.isSelfSend = NO;
    if(self.messageDelegate != nil && [self.messageDelegate respondsToSelector:@selector(onUpdateMessage:)]){
        [self.messageDelegate onUpdateMessage:messageModel];
    }
}

- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes {

    RolesInfoModel *rolesInfoModel = [self fixRolesInfoModelWithAttributes:attributes];
    if(self.messageDelegate != nil && [self.messageDelegate respondsToSelector:@selector(onUpdateTeactherAttribute:)]){
        
        NSLog(@"attributeUpdate teacher link_uid==>%@", rolesInfoModel.teactherModel.link_uid);
        
        [self.messageDelegate onUpdateTeactherAttribute:rolesInfoModel.teactherModel];
    }
    
    if(self.messageDelegate != nil && [self.messageDelegate respondsToSelector:@selector(onUpdateStudentsAttribute:)]){
        [self.messageDelegate onUpdateStudentsAttribute:rolesInfoModel.studentModels];
    }
}

- (void)channel:(AgoraRtmChannel *)channel memberLeft:(AgoraRtmMember *)member {
    if(self.messageDelegate != nil && [self.messageDelegate respondsToSelector:@selector(onMemberLeft:)]){
        [self.messageDelegate onMemberLeft: member.userId];
    }
}

- (void)updateGlobalStateWithValue:(NSString *)value completeSuccessBlock:(ManagerBlock _Nullable)successBlock completeFailBlock:(ManagerBlock _Nullable)failBlock {
    
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.messageModel.uid;
    setAttr.value = value;
    AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
    options.enableNotificationToChannelMembers = YES;
    NSArray *attrArray = [NSArray arrayWithObjects:setAttr, nil];
    
    [self.agoraRtmKit addOrUpdateChannel:self.channelName Attributes:attrArray Options:options completion:^(AgoraRtmProcessAttributeErrorCode errorCode) {
        if (errorCode == AgoraRtmAttributeOperationErrorOk) {
            NSLog(@"学生频道属性更新成功");
            if(successBlock != nil){
                successBlock();
            }
        }else {
            NSLog(@"学生频道属性更新失败");
            if(failBlock != nil){
                failBlock();
            }
        }
    }];
}

@end
