//
//  EEChatContentViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEChatContentViewCell.h"

@interface EEChatContentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidthCon;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *leftView;

@end

@implementation EEChatContentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.nameLabel.backgroundColor = [UIColor whiteColor];
    self.leftView.layer.borderWidth = 1.f;
    self.leftView.layer.borderColor = RCColorWithValue(0xDBE2E5, 1.f).CGColor;
    self.leftView.layer.cornerRadius = 4.f;
    self.leftView.layer.masksToBounds = YES;

    self.rightView.layer.borderWidth = 1.f;
    self.rightView.layer.borderColor = RCColorWithValue(0xDBE2E5, 1.f).CGColor;
    self.rightView.layer.cornerRadius = 4.f;
    self.rightView.layer.masksToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageModel:(RoomMessageModel *)messageModel {
    _messageModel = messageModel;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.f]};
     CGSize textRect = CGSizeMake(kScreenWidth - 30, MAXFLOAT);
     CGFloat textWidth = [messageModel.content boundingRectWithSize:textRect
                                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:attributes
                                                context:nil].size.width;
    if (messageModel.isSelfSend) {
        self.nameLabel.textAlignment = NSTextAlignmentRight;
        self.rightContentLabel.hidden = NO;
        self.rightView.hidden = NO;
        self.leftContentLabel.hidden = YES;
        self.leftView.hidden = YES;
        [self.rightContentLabel setText:messageModel.content];
        self.rightViewWidthCon.constant = textWidth + 11 > kScreenWidth - 30 ? kScreenWidth - 30: textWidth + 11;

    }else {
         self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.leftContentLabel.hidden = NO;
        self.leftView.hidden = YES;
         self.rightContentLabel.hidden = YES;
        self.rightView.hidden = YES;
        [self.leftContentLabel setText:messageModel.content];
        self.leftViewWidthCon.constant = textWidth + 20 > kScreenWidth - 30 ? kScreenWidth - 30 : textWidth + 20;
    }
    [self.nameLabel setText:messageModel.name];


}
@end
