//
//  EEChatContentTableView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEChatContentTableView.h"
#import "EEChatContentViewCell.h"
#import "RoomMessageModel.h"

@interface EEChatContentTableView ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation EEChatContentTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.messageArray = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;

        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset: UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins: UIEdgeInsetsZero];
        }
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messageArray.count;

}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EEChatContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BCChatCell"];
    if (!cell) {
        cell = [[EEChatContentViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"BCChatCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.messageModel = self.messageArray[indexPath.row];

    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomMessageModel *content = self.messageArray[indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13.f]};
    CGSize textRect = CGSizeMake(kScreenWidth - 30, MAXFLOAT);
    CGFloat textHeight = [content.content boundingRectWithSize:textRect
                                               options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                            attributes:attributes
                                               context:nil].size.height;
    return textHeight+40;
}


- (void)setMessageArray:(NSMutableArray *)messageArray {
    _messageArray = messageArray;
    [self reloadData];
}
@end
