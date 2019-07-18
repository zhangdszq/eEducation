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

- (void)setClassName:(NSString *)className {
    _className = className;
    [self.messageArray removeAllObjects];
}

- (void)setAgoraRtmKit:(AgoraRtmKit *)agoraRtmKit {
    _agoraRtmKit = agoraRtmKit;
    agoraRtmKit.agoraRtmDelegate = self;
}

- (void)sendMessage:(NSString *)message  {
    AgoraRtmMessage *videoMessage = [[AgoraRtmMessage alloc] initWithText:message];
    [self.agoraRtmKit sendMessage:videoMessage toPeer:self.serverRtmId completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {

    }];
}

- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId {
    if ([self.serverRtmId isEqualToString:peerId]) {
        NSString *messageStr = message.text;
        NSDictionary *messageDict  =  [JsonAndStringConversions dictionaryWithJsonString:messageStr];
        if ([[messageDict objectForKey:@"name"] isEqualToString:@"JoinSuccess"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            NSArray *memberArray = argsDict[@"members"];
            self.studentArray = [NSMutableArray array];
            for (NSDictionary *memberDict in memberArray) {
                RoomUserModel *userModel = [RoomUserModel yy_modelWithDictionary:memberDict];
                if (userModel.role == ClassRoomRoleTeacther) {
                    self.teactherModel = userModel;
                }else if (userModel.role == ClassRoomRoleStudent) {
                    [self.studentArray addObject:userModel];
                }
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
                        if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomSuccess)]) {
                            [weakself.classRoomManagerDelegate joinClassRoomSuccess];
                        }
                    }
                } failure:^(NSError *error) {
                    if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError)]) {
                        [weakself.classRoomManagerDelegate joinClassRoomError];
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
                    }
                } failure:^(NSError *error) {
                    if (weakself.classRoomManagerDelegate && [weakself.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError)]) {
                        [weakself.classRoomManagerDelegate joinClassRoomError];
                    }
                }];
            }
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"JoinFailure"]) {
            if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(joinClassRoomError)]) {
                [self.classRoomManagerDelegate joinClassRoomError];
            }
        }else   if ([[messageDict objectForKey:@"name"] isEqualToString:@"MemberJoined"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            if ([[argsDict objectForKey:@"role"] integerValue] == ClassRoomRoleTeacther) {
                self.teactherModel = [RoomUserModel yy_modelWithDictionary:argsDict];
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(teactherJoinSuccess)]) {
                    [self.classRoomManagerDelegate teactherJoinSuccess];
                }
            }else if ([[argsDict objectForKey:@"role"] integerValue] == ClassRoomRoleStudent){
                RoomUserModel *userModel = [RoomUserModel yy_modelWithDictionary:argsDict];
                [self.studentArray addObject:userModel];
                self.studentArray = self.studentArray;
                if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(updateStudentList)]) {
                    [self.classRoomManagerDelegate updateStudentList];
                }
            }else {
            }
        }else if([[messageDict objectForKey:@"name"] isEqualToString:@"MemberLeft"]){
            NSDictionary *argsDict = messageDict[@"args"];
            NSMutableArray *temArray = self.studentArray;
            for (NSInteger i = 0; i < temArray.count; i++) {
                RoomUserModel *userModel = temArray[i];
                if ([argsDict[@"uid"] isEqualToString:userModel.uid]) {
                    [self.studentArray removeObjectAtIndex:i];
                }
            }
            if (self.classRoomManagerDelegate && [self.classRoomManagerDelegate respondsToSelector:@selector(updateStudentList)]) {
                [self.classRoomManagerDelegate updateStudentList];
            }
        }else if ([[messageDict objectForKey:@"name"] isEqualToString:@"ChannelMessage"]) {
            NSDictionary *argsDict = messageDict[@"args"];
            NSString *uid = [argsDict objectForKey:@"uid"];
            RoomMessageModel *messageModel = [[RoomMessageModel alloc] init];
            messageModel.isTeacther = [uid isEqualToString:self.teactherModel.uid] ? YES : NO;
            messageModel.content = [argsDict objectForKey:@"message"];
            messageModel.name = [argsDict objectForKey:@"uid"];
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
@end
