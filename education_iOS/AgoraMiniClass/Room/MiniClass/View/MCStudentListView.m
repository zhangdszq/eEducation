//
//  MCStudentListView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCStudentListView.h"
#import "MCStudentViewCell.h"


@interface MCStudentListView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *studentTableView;
@property (nonatomic, strong) NSMutableArray *studentArray;

@end

@implementation MCStudentListView
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
    UITableView *studentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    studentTableView.delegate = self;
    studentTableView.dataSource =self;
    [self addSubview:studentTableView];
    self.studentTableView = studentTableView;
    studentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.studentArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.studentTableView.frame = self.bounds;
}

- (void)addStudentModel:(EEBCStudentAttrs *)model {
    [self.studentArray addObject:model];
    [self.studentTableView reloadData];
}

- (void)removeStudentModel:(EEBCStudentAttrs *)model {
    [self.studentArray removeObject:model];
    [self.studentTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCStudentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MCStudentViewCell" owner:self options:nil] firstObject];
    }

    cell.studentModel = self.studentArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
@end
