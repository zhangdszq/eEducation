//
//  MCSegmentedView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^SelectSegmentViewIndex)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface MCSegmentedView : UIView
@property (nonatomic, copy) SelectSegmentViewIndex selectIndex;
- (void)showBadgeWithCount:(NSInteger)count;
- (void)hiddeBadge;
@end

NS_ASSUME_NONNULL_END
