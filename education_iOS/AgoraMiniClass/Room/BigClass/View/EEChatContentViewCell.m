//
//  EEChatContentViewCell.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEChatContentViewCell.h"

@interface EEChatContentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightContentLabel;

@end

@implementation EEChatContentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.nameLabel.backgroundColor = [UIColor yellowColor];
    self.leftContentLabel.layer.borderWidth = 1.f;
    self.leftContentLabel.layer.borderColor = RCColorWithValue(0xDBE2E5, 1.f).CGColor;
    self.leftContentLabel.layer.cornerRadius = 4.f;
    self.leftContentLabel.layer.masksToBounds = YES;

    self.rightContentLabel.layer.borderWidth = 1.f;
    self.rightContentLabel.layer.borderColor = RCColorWithValue(0xDBE2E5, 1.f).CGColor;
    self.rightContentLabel.layer.cornerRadius = 4.f;
    self.rightContentLabel.layer.masksToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
