//
//  MCStudentViewCell.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EEBCStudentAttrs.h"


NS_ASSUME_NONNULL_BEGIN

@interface MCStudentViewCell : UITableViewCell
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) EEBCStudentAttrs *studentModel;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioButton;

@property (weak, nonatomic) IBOutlet UIButton *muteVideoButton;

@end

NS_ASSUME_NONNULL_END
