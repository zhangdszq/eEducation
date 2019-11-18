//
//  OneToOneNavigationView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/12.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EENavigationView : UIView
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (void)startTimer;
- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END
