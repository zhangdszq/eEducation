//
//  MessageManager.m
//  AgoraEducation
//
//  Created by SRS on 2019/12/6.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MessageManager.h"
#import "AEP2pMessageModel.h"
#import "AERTMMessageBody.h"
#import "AERoomMessageModel.h"

NSString * const RoleTypeTeacther = @"teacher";
//NSString * const RoleTypeStudent = @"student";

@interface MessageManager()<AgoraRtmDelegate, AgoraRtmChannelDelegate>

@property (nonatomic, strong) MessageModel *messageModel;

@property (nonatomic, strong) AgoraRtmKit *agoraRtmKit;
@property (nonatomic, strong) AgoraRtmChannel *agoraRtmChannel;
@property (nonatomic, strong) NSString *channelName;

@end

static MessageManager *manager = nil;
@implementation MessageManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (void)initWithMessageModel:(MessageModel*)model completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock {
    
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
    
    
    self.currentStuModel = [[AEStudentModel alloc] initWithParams:[AERTMMessageBody paramsStudentWithUserId:model.uid name:model.userName video:YES audio:YES]];
}

- (void)queryRolesInfoWithChannelName:(NSString *)channelName completeBlock:(QueryRolesInfoBlock _Nonnull)block {
    
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
            
            if([model.userId isEqualToString: self.messageModel.uid]) {
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

- (void)joinChannelWithName:(NSString *)channelName completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock {

    self.channelName = channelName;
    
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


- (void)sendMessageWithText:(NSString *)messageText {
    
    NSString *messageBody = [AERTMMessageBody sendP2PMessageWithName:self.messageModel.userName content:messageText];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:messageBody];
    
    WEAK(self)
    [self.agoraRtmChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        
        if (errorCode == AgoraRtmSendChannelMessageErrorOk) {
            AERoomMessageModel *messageModel = [[AERoomMessageModel alloc] init];
            messageModel.content = messageText;
            messageModel.account = weakself.messageModel.userName;
            messageModel.isSelfSend = YES;
            
            if(weakself.messageDelegate != nil && [weakself.messageDelegate respondsToSelector:@selector(onUpdateMessage:)]){
                [weakself.messageDelegate onUpdateMessage:messageModel];
            }
        }
        
    }];
}

- (void)sendMessageWithText:(NSString *)messageText toPeer:(NSString *)peerId completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock {
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:messageText];
    
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
        
        AgoraRtmChannelAttributeOptions *options = [[AgoraRtmChannelAttributeOptions alloc] init];
        options.enableNotificationToChannelMembers = YES;
        [self.agoraRtmKit deleteChannel:self.channelName AttributesByKeys:@[self.messageModel.uid] Options:options completion:nil];
        
        [self.agoraRtmChannel leaveWithCompletion:nil];
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

- (void)updateStudentChannelAttrsWithVideoVisble:(BOOL)video audioVisble:(BOOL)audio completeSuccessBlock:(MessageManagerBlock _Nullable)successBlock completeFailBlock:(MessageManagerBlock _Nullable)failBlock {
    
    AgoraRtmChannelAttribute *setAttr = [[AgoraRtmChannelAttribute alloc] init];
    setAttr.key = self.currentStuModel.userId;
    setAttr.value = [AERTMMessageBody setAndUpdateStudentChannelAttrsWithName:self.messageModel.userName video:video audio:audio];
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
