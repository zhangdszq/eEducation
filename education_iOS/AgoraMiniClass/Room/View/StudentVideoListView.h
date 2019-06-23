//
//  StudentVideoListView.h
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/16.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ StudentVideoList)(UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nullable indexPath);


NS_ASSUME_NONNULL_BEGIN

@interface StudentVideoListView : UIView
- (void)addUserId:(NSInteger)object;
- (void)removeUserId:(NSInteger)object;

@property (nonatomic, copy) StudentVideoList studentVideoList;

@end

NS_ASSUME_NONNULL_END
