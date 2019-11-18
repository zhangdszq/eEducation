//
//  EESegmentedView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  EESegmentedDelegate <NSObject>

- (void)selectedItemIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface EESegmentedView : UIView
@property (nonatomic, weak) id<EESegmentedDelegate> delegate;
- (void)showBadgeWithCount:(NSInteger)count;
- (void)hiddeBadge;
@end

NS_ASSUME_NONNULL_END
