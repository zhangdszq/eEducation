//
//  OTOStudentView.h
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/13.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^MuteMic)(BOOL isMute);
typedef void(^MuteVideo)(BOOL isMute);
NS_ASSUME_NONNULL_BEGIN

@interface OTOStudentView : UIView
@property (strong, nonatomic) IBOutlet UIView *studentView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

@property (nonatomic, copy) MuteMic muteMic;
@property (nonatomic, copy) MuteMic muteVideo;
@end

NS_ASSUME_NONNULL_END
