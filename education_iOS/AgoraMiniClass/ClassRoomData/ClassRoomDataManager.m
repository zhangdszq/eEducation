//
//  ClassRoomDataManager.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/6/29.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "ClassRoomDataManager.h"
#import "AgoraHttpRequest.h"


static ClassRoomDataManager *manager = nil;

@interface ClassRoomDataManager ()<AgoraRtmDelegate>
@end

@implementation ClassRoomDataManager
+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return manager;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return manager;
}

- (void)joinClassRoom {
    WEAK(self)
    if (weakself.className.length < 0 && weakself.userName.length < 0) {
        if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError:)]) {
            [self.classRoomManagerDelegate joinClassRoomError:(ClassRoomErrorCodeInvalidArgument)];
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(weakself.roomRole),@"role",weakself.userName,@"name",weakself.uid,@"streamId", nil];
    NSDictionary *argsInfo = [NSDictionary dictionaryWithObjectsAndKeys:weakself.className,@"channel",userInfo,@"userAttr", nil];
    NSDictionary  *requestInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Join",@"name",argsInfo,@"args", nil];
    NSString *requestStr =  [JsonAndStringConversions dictionaryToJson:requestInfo];
    AgoraRtmMessage *message = [[AgoraRtmMessage alloc] init];
    message.text = requestStr;
    [weakself.agoraRtmKit sendMessage:message toPeer:weakself.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        NSLog(@"%ld",(long)errorCode);
    }];
}

- (void)sendMessage:(NSString *)message completion:(AgoraRtmSendPeerMessageBlock _Nullable)completionBlock  {
    AgoraRtmMessage *videoMessage = [[AgoraRtmMessage alloc] initWithText:message];
    [self.agoraRtmKit sendMessage:videoMessage toPeer:self.serverRtmId completion:completionBlock];
}

- (void)removeClassRoomInfo {
    [self.studentArray removeAllObjects];
    [self.teactherArray removeAllObjects];
    [self.messageArray removeAllObjects];
    [self.memberInfo removeAllObjects];
}

- (void)UpdateChannelAttr {
    NSDictionary *channelAttr = [NSDictionary dictionaryWithObjectsAndKeys:self.uuid,@"whiteboardId", nil];
    NSDictionary *argsInfo = [NSDictionary dictionaryWithObjectsAndKeys:channelAttr,@"channelAttr", nil];
    NSDictionary  *requestInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"UpdateChannelAttr",@"name",argsInfo,@"args", nil];
    NSString *requestStr =  [JsonAndStringConversions dictionaryToJson:requestInfo];
    AgoraRtmMessage *message = [[AgoraRtmMessage alloc] initWithText:requestStr];
   [self.agoraRtmKit sendMessage:message toPeer:self.serverRtmId completion:nil];
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    if ([self.serverRtmId isEqualToString:peerId]) {
        NSString *messageStr = message.text;
        NSDictionary *messageDict  =  [JsonAndStringConversions dictionaryWithJsonString:messageStr];
        if ([[messageDict objectForKey:@"name"] isEqualToString:@"JoinSuccess"]) {
            [self receivedJoinSuccessMessageDict:messageDict[@"args"]];
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"JoinFailure"]) {
            if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError:)]) {
                [self.classRoomManagerDelegate joinClassRoomError:(ClassRoomErrorCodeInvalidServerRtmId)];
            }
        }else   if ([[messageDict objectForKey:@"name"] isEqualToString:@"MemberJoined"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            RoomUserModel *userModel = [RoomUserModel yy_modelWithDictionary:argsDict];
            if ([[argsDict objectForKey:@"role"] integerValue] == ClassRoomRoleTeacther) {
                [self.teactherArray addObject:userModel];
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(teactherJoinSuccess)]) {
                    [self.classRoomManagerDelegate teactherJoinSuccess];
                }
            }else if ([[argsDict objectForKey:@"role"] integerValue] == ClassRoomRoleStudent){
                [self.studentArray addObject:userModel];
                self.studentArray = self.studentArray;
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(updateStudentList)]) {
                    [self.classRoomManagerDelegate updateStudentList];
                }
            }
            [self.memberInfo setValue:userModel forKey:userModel.uid];
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"MemberLeft"]){
            NSDictionary *argsDict = messageDict[@"args"];
            NSMutableArray *temArray = self.studentArray;
            for (NSInteger i = 0; i < temArray.count; i++) {
                RoomUserModel *userModel = temArray[i];
                if ([argsDict[@"uid"] isEqualToString:userModel.uid]) {
                    [self.studentArray removeObjectAtIndex:i];
                    if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(updateStudentList)]) {
                        [self.classRoomManagerDelegate updateStudentList];
                    }
                }
                [self.memberInfo setValue:userModel forKey:userModel.uid];
            }
            if (self.teactherArray.count > 0) {
                RoomUserModel *model = self.teactherArray[0];
                if ([argsDict[@"uid"] isEqualToString:model.uid]) {
                    [self.teactherArray removeObjectAtIndex:0];
                    if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(teactherLeaveClassRoom)]) {
                        [self.classRoomManagerDelegate teactherLeaveClassRoom];
                    }
                }
            }
        }else if ([[messageDict objectForKey:@"name"] isEqualToString:@"ChannelMessage"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            NSString *uid = [argsDict objectForKey:@"uid"];
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            NSString *teactherUid = self.teactherArray.count > 0 ? self.teactherArray[0].uid : nil;
            messageModel.isTeacther = [uid isEqualToString:teactherUid] ? YES : NO;
            if (messageModel.isTeacther) {
                messageModel.name = self.teactherArray[0].name;
            }else {
                NSArray *memberArray = self.memberInfo.allValues;
                for (RoomUserModel *userModel in memberArray) {
                    messageModel.name = userModel.uid == uid ? userModel.name : nil;
                }
            }
            messageModel.content = [argsDict objectForKey:@"message"];
            [self.messageArray addObject:messageModel];
            if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(updateChatMessageList)]) {
                [self.classRoomManagerDelegate updateChatMessageList];
            }
        }else if ([[messageDict objectForKey:@"name"] isEqualToString:@"Muted"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            if ([argsDict[@"type"] isEqualToString:@"video"]) {
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(muteLoaclVideoStream:)]) {
                    [self.classRoomManagerDelegate muteLoaclVideoStream:YES];
                }
            }else if ([argsDict[@"type"] isEqualToString:@"audio"]) {
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(muteLoaclAudioStream:)]) {
                    [self.classRoomManagerDelegate muteLoaclAudioStream:YES];
                }
            }
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"Unmuted"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            if ([argsDict[@"type"] isEqualToString:@"video"]) {
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(muteLoaclVideoStream:)]) {
                    [self.classRoomManagerDelegate muteLoaclVideoStream:NO];
                }
            }else if ([argsDict[@"type"] isEqualToString:@"audio"]) {
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(muteLoaclAudioStream:)]) {
                    [self.classRoomManagerDelegate muteLoaclAudioStream:NO];
                }
            }
        }
    }
}

- (void)receivedJoinSuccessMessageDict:(NSDictionary *)dict {
    NSDictionary *argsDict = dict;
    NSArray *memberArray = argsDict[@"members"];
    self.studentArray = [NSMutableArray array];
    for (NSDictionary *memberDict in memberArray) {
        RoomUserModel *userModel = [RoomUserModel yy_modelWithDictionary:memberDict];
        if (userModel.role == ClassRoomRoleTeacther) {
            [self.teactherArray addObject:userModel];
        }else if (userModel.role == ClassRoomRoleStudent) {
            [self.studentArray addObject:userModel];
        }
        [self.memberInfo setValue:userModel forKey:userModel.uid];
    }
    NSDictionary *channelAttr = argsDict[@"channelAttr"];
    AgoraHttpRequest *request = [[AgoraHttpRequest alloc] init];
    WEAK(self)
    if ([channelAttr isEqual:[NSNull null]]) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.className,@"name",@"100",@"limit", nil];
        [request post:kGetWhiteBoardUuid params:params success:^(id responseObj) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
            if ([responseObject[@"code"] integerValue] == 200) {
                NSDictionary *roomDict = responseObject[@"msg"][@"room"];
                weakself.uuid = roomDict[@"uuid"];
                weakself.roomToken = responseObject[@"msg"][@"roomToken"];
                [weakself UpdateChannelAttr];
                if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomSuccess)]) {
                    [weakself.classRoomManagerDelegate joinClassRoomSuccess];
                }
            }else {
                if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError:)]) {
                    [weakself.classRoomManagerDelegate joinClassRoomError:(ClassRoomErrorCodeInvalidWhiteboard)];
                }
            }
        } failure:^(NSError *error) {
            if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError:)]) {
                [weakself.classRoomManagerDelegate joinClassRoomError:(ClassRoomErrorCodeNetDown)];
            }
        }];
    }else {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[channelAttr objectForKey:@"whiteboardId"],@"uuid", nil];
        self.uuid = [channelAttr objectForKey:@"whiteboardId"];
        [request post:kGetWhiteBoardRoomToken params:params success:^(id responseObj) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseObj options:0 error:nil];
            if ([responseObject[@"code"] integerValue] == 200) {
                weakself.roomToken = responseObject[@"msg"][@"roomToken"];
                if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomSuccess)]) {
                    [weakself.classRoomManagerDelegate joinClassRoomSuccess];
                }
            }else {
                if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError:)]) {
                    [weakself.classRoomManagerDelegate joinClassRoomError:ClassRoomErrorCodeInvalidWhiteboard];
                }
            }
        } failure:^(NSError *error) {
            if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError:)]) {
                [weakself.classRoomManagerDelegate joinClassRoomError:(ClassRoomErrorCodeNetDown)];
            }
        }];
    }
}

- (void)setClassName:(NSString *)className {
    _className = className;
    [self.messageArray removeAllObjects];
}

- (void)setAgoraRtmKit:(AgoraRtmKit *)agoraRtmKit {
    _agoraRtmKit = agoraRtmKit;
    agoraRtmKit.agoraRtmDelegate = self;
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

- (NSMutableArray *)studentArray {
    if (!_studentArray) {
        _studentArray = [NSMutableArray array];
    }
    return _studentArray;
}

- (NSMutableArray *)teactherArray {
    if (!_teactherArray) {
        _teactherArray = [NSMutableArray array];
    }
    return _teactherArray;
}
- (NSMutableDictionary *)memberInfo {
    if (!_memberInfo) {
        _memberInfo = [NSMutableDictionary dictionary];
    }
    return _memberInfo;
}
@end
