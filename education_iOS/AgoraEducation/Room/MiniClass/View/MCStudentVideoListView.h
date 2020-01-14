//
//  MCStudentVideoListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RolesInfoModel.h"
#import "MCStudentVideoCell.h"

typedef void(^ StudentVideoList)(MCStudentVideoCell * _Nonnull cell, NSString * _Nullable currentUid);

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentVideoListView : UIView
@property (nonatomic, copy) StudentVideoList studentVideoList;
- (void)updateStudentArray:(NSArray<RolesStudentInfoModel*> *)array;
@end

NS_ASSUME_NONNULL_END
