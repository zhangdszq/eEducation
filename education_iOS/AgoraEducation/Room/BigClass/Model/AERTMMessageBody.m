//
//  EEBCRoomDataManager.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "AERTMMessageBody.h"
#import "AgoraHttpRequest.h"


@interface AERTMMessageBody ()
@end

@implementation AERTMMessageBody
+ (NSString *)studentApplyLink {
    NSString *applyString = [AERTMMessageBody p2pMessageWithType:RTMp2pTypeApply];
    return applyString;
}

+ (NSString *)studentCancelLink {
    NSString *cancelString = [AERTMMessageBody p2pMessageWithType:RTMp2pTypeCancel];
    return cancelString;
}

+ (NSString *)muteVideoStream:(BOOL)stream {
    RTMp2pType type = stream ? RTMp2pTypeMuteVideo : RTMp2pTypeUnMuteVideo;
    NSString *message = [AERTMMessageBody p2pMessageWithType:type];
    return message;
}

+ (NSString *)muteAudioStream:(BOOL)stream {
    RTMp2pType type = stream ? RTMp2pTypeMuteAudio : RTMp2pTypeUnMuteAudio;
    NSString *message = [AERTMMessageBody p2pMessageWithType:type];
    return message;
}

+ (NSString *)muteChatContent:(BOOL)isMute {
    RTMp2pType type = isMute ? RTMp2pTypeMuteChat: RTMp2pTypeUnMuteChat;
    NSString *message = [AERTMMessageBody p2pMessageWithType:type];
    return message;
}

+ (NSString *)setAndUpdateStudentChannelAttrsWithName:(NSString *)name video:(BOOL)video audio:(BOOL)audio {
    NSDictionary *dict = @{@"account":name,@"video":@(video),@"audio":@(audio)};
    NSString *attrString = [DataTypeManager dictionaryToJson:dict];
    return attrString;
}

+ (NSString *)p2pMessageWithType:(RTMp2pType)type {
    NSDictionary *dict = @{@"cmd":@(type),@"text":@""};
    NSString *message = [DataTypeManager dictionaryToJson:dict];
    return message;
}
+ (NSDictionary *)paramsStudentWithUserId:(NSString *)userId name:(NSString *)name video:(BOOL)video audio:(BOOL)audio {
    NSDictionary *dict = @{@"account":name,@"userId": userId,@"video":@(video),@"audio":@(audio)};
    return dict;
}

+ (NSString *)sendP2PMessageWithName:(NSString *)name content:(NSString *)content {
    NSDictionary *dict = @{@"account":name,@"content":content,};
    NSString *message = [DataTypeManager dictionaryToJson:dict];
    return message;
}

@end
