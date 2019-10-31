//
//  EEChannelAttr.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EEChannelAttr : NSObject
- (NSString *)teactherAttrVideo:(BOOL)video audio:(BOOL)audio screen:(BOOL)screen whiteboard:(BOOL)whiteboard chatroom:(BOOL)chatroom connect_state:(NSString *)state link_state:(NSString *)linkstate;
@end

NS_ASSUME_NONNULL_END
