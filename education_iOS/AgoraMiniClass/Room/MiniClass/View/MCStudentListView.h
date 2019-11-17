//
//  MCStudentListView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEBCStudentAttrs.h"

@protocol MCStudentViewDelegate  <NSObject>
@optional
- (void)muteAudioStream:(BOOL)stream;
- (void)muteVideoStream:(BOOL)stream;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MCStudentListView : UIView
@property (nonatomic, weak)id<MCStudentViewDelegate> delegate;
- (void)addStudentModel:(EEBCStudentAttrs *)model;
- (void)removeStudentModel:(EEBCStudentAttrs *)model;
@end

NS_ASSUME_NONNULL_END
