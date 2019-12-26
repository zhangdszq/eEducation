//
//  MCStudentListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomProtocol.h"
#import "RolesInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentListView : UIView
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, weak)id<RoomProtocol> delegate;
- (void)updateStudentArray:(NSArray<RolesStudentInfoModel*> *)array;
@end

NS_ASSUME_NONNULL_END
