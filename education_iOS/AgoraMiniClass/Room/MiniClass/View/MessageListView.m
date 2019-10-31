//
//  MessageListView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MessageListView.h"
#import "MessageListViewCell.h"
#import "RoomMessageModel.h"

@interface MessageListView ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MessageListView
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.messageArray = [NSMutableArray array];
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset: UIEdgeInsetsZero];
        }
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins: UIEdgeInsetsZero];
        }
    }
    return self;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (!cell) {
        cell = [[MessageListViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"MessageCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.messageModel = self.messageArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RoomMessageModel *content = self.messageArray[indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:12.f]};
    CGSize textRect = CGSizeMake(190, MAXFLOAT);
    CGFloat textHeight = [content.content boundingRectWithSize:textRect
                                               options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                            attributes:attributes
                                               context:nil].size.height;
    return textHeight+30;
}

- (void)setMessageArray:(NSMutableArray *)messageArray {
    _messageArray = messageArray;
    [self reloadData];
    if (messageArray.count > 0) {
        [self scrollToRowAtIndexPath:
         [NSIndexPath indexPathForRow:[self.messageArray count] - 1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
    }
}
@end
