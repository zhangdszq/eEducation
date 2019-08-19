//
//  MessageListViewCell.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageListViewCell : UITableViewCell
@property (nonatomic, copy) RoomMessageModel *messageModel;
@end

NS_ASSUME_NONNULL_END
