//
//  MCStudentViewCell.h
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StudentModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface MCStudentViewCell : UITableViewCell
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) StudentModel *studentModel;
@property (weak, nonatomic) IBOutlet UIButton *muteAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *muteVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *muteWhiteButton;
@end

NS_ASSUME_NONNULL_END
