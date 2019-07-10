//
//  MessageListViewCell.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MessageListViewCell.h"

@interface MessageListViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *leftNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightContentLabel;
@end

@implementation MessageListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setMessageModel:(RoomMessageModel *)messageModel {
    _messageModel = messageModel;
    if (messageModel.isTeacther) {
        [self.rightNameLabel setText:messageModel.name];
        [self.rightContentLabel setText:messageModel.content];
        self.leftNameLabel.hidden = YES;
        self.leftContentLabel.hidden = YES;
        self.rightNameLabel.hidden = NO;
        self.rightContentLabel.hidden = NO;
    }else {
        [self.leftNameLabel setText:messageModel.name];
        [self.leftContentLabel setText:messageModel.content];
        self.rightNameLabel.hidden = YES;
        self.rightContentLabel.hidden = YES;
        self.leftNameLabel.hidden = NO;
        self.leftContentLabel.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
