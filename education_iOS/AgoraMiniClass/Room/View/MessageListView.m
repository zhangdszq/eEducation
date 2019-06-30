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
- (void)setMessageArray:(NSMutableArray *)messageArray {
    _messageArray = messageArray;
    [self reloadData];
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
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

@end
