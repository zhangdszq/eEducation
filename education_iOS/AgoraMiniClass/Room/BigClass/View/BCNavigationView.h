//
//  EENavigationView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/24.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

 

NS_ASSUME_NONNULL_BEGIN

@interface BCNavigationView : UIView
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *wifiSignalImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonBottomConstraint;
@property (strong, nonatomic) IBOutlet UIView *navigationView;

- (void)updateChannelName:(NSString *)name;
- (void)updateSignalImageName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
