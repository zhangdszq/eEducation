//
//  EEChatContentTableView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/23.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEChatContentTableView.h"
#import "EEChatContentViewCell.h"

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
        self.delegate = self;
        self.dataSource = self;
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
    return 10;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EEChatContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BCChatCell"];
    if (!cell) {
        cell = [[EEChatContentViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"BCChatCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.messageModel = self.messageArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
