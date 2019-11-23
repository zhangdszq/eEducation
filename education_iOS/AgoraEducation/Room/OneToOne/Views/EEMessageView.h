//
//  EEMessageView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEMessageView : UIView
- (void)addMessageModel:(RoomMessageModel *)model;
- (void)updateTableView;
@end

NS_ASSUME_NONNULL_END
