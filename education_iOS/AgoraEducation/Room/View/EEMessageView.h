//
//  EEMessageView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignalRoomModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EEMessageView : UIView

- (void)addMessageModel:(SignalRoomModel *)model;
- (void)updateTableView;
@end

NS_ASSUME_NONNULL_END
