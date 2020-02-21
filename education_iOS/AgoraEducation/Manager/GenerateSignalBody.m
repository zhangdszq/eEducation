//
//  GenerateSignalBody.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/31.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "GenerateSignalBody.h"
#import "SignalP2PModel.h"
#import "JsonParseUtil.h"

@implementation GenerateSignalBody
+ (NSString *)studentApplyLink {
    NSDictionary *dict = @{@"cmd":@(SignalP2PTypeApply),@"text":@"co-video"};
    NSString *applyString = [JsonParseUtil dictionaryToJson:dict];
    return applyString;
}

+ (NSString *)studentCancelLink {
    NSDictionary *dict = @{@"cmd":@(SignalP2PTypeCancel),@"text":@""};
    NSString *applyString = [JsonParseUtil dictionaryToJson:dict];
    return applyString;
}

+ (NSString *)muteVideoStream:(BOOL)stream {
    NSNumber *type = stream ? @(SignalP2PTypeMuteVideo) : @(SignalP2PTypeUnMuteVideo);
    NSDictionary *dict = @{@"cmd":type,@"resource":@""};
    NSString *message = [JsonParseUtil dictionaryToJson:dict];
    return message;
}

+ (NSString *)muteAudioStream:(BOOL)stream {
    NSNumber *type = stream ? @(SignalP2PTypeMuteAudio) : @(SignalP2PTypeUnMuteAudio);
    NSDictionary *dict = @{@"cmd":type,@"text":@""};
    NSString *message = [JsonParseUtil dictionaryToJson:dict];
    return message;
}

+ (NSString *)muteChatContent:(BOOL)isMute {
    NSNumber *type = isMute ? @(SignalP2PTypeMuteChat): @(SignalP2PTypeUnMuteChat);
    NSDictionary *dict = @{@"cmd":type,@"text":@""};
    NSString *message = [JsonParseUtil dictionaryToJson:dict];
    return message;
}

+ (NSString *)messageWithName:(NSString *)name content:(NSString *)content {
    NSDictionary *dict = @{@"account":name,@"content":content,};
    NSString *message = [JsonParseUtil dictionaryToJson:dict];
    return message;
}

+ (NSString *)channelAttrsWithValue:(StudentModel *)model {
    NSDictionary *dict = @{@"uid": model.uid,
                           @"account": model.account,
                           @"video": @(model.video),
                           @"audio": @(model.audio),
                           @"chat": @(model.chat),
                           @"grant_board": @(model.grant_board)};
    NSString *attrString = [JsonParseUtil dictionaryToJson:dict];
    return attrString;
}

@end
