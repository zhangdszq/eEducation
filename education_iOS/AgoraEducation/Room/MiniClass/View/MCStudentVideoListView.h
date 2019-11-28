//
//  MCStudentVideoListView.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AEStudentModel.h"

typedef void(^ StudentVideoList)(UIView * _Nullable imageView, NSIndexPath * _Nullable indexPath);

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentVideoListView : UIView
@property (nonatomic, copy) StudentVideoList studentVideoList;
- (void)updateStudentArray:(NSMutableArray *)studentArray;
@end

NS_ASSUME_NONNULL_END
