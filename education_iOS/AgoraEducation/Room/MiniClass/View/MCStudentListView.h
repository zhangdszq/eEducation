//
//  MCStudentListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEStudentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentListView : UIView
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, weak)id<AEClassRoomProtocol> delegate;
- (void)updateStudentArray:(NSMutableArray *)array;
@end

NS_ASSUME_NONNULL_END
