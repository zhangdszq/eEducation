//
//  EEMessageView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/11.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEMessageView.h"
#import "EEMessageViewCell.h"


@interface EEMessageView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *messageTableView;
@property (nonatomic, strong) NSMutableArray *messageArray;

@end

@implementation EEMessageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor yellowColor];
    UITableView *messageTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    messageTableView.delegate = self;
    messageTableView.dataSource =self;
    [self addSubview:messageTableView];
    self.messageTableView = messageTableView;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.messageTableView.frame = self.bounds;
}

- (void)updateTableView {
    [self.messageTableView reloadData];
}
- (void)addMessageModel:(AERoomMessageModel *)model {
    [self.messageArray addObject:model];
    [self.messageTableView reloadData];
    if (self.messageArray.count > 0) {
         [self.messageTableView scrollToRowAtIndexPath:
          [NSIndexPath indexPathForRow:[self.messageArray count] - 1 inSection:0] atScrollPosition: UITableViewScrollPositionBottom animated:NO];
     }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EEMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EEMessageViewCell" owner:self options:nil] firstObject];
    }
    cell.cellWidth = self.bounds.size.width;
    cell.messageModel = self.messageArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AERoomMessageModel *messageModel = self.messageArray[indexPath.row];
    CGSize labelSize = [messageModel.content boundingRectWithSize:CGSizeMake(self.messageTableView.frame.size.width - 38, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]} context:nil].size;
    return labelSize.height + 60;
}
@end
