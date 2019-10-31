//
//  EEClassRoomTypeView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/28.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EEClassRoomTypeView.h"


@interface EEClassRoomTypeView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *typeTableView;
@property (nonatomic, strong) NSMutableArray *roomNameArray;
@end

@implementation EEClassRoomTypeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)initWithXib:(CGRect)frame {
    EEClassRoomTypeView *classRoomTypeView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;

    classRoomTypeView.frame = frame;
    [classRoomTypeView awakeFromNib];
    return classRoomTypeView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.roomNameArray = [NSMutableArray arrayWithObjects:@"一对一",@"小班课",@"大班课", nil];
    [self addSubview:self.typeTableView];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"typeCell"];
    if (!tableViewCell) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"typeCell"];
    }
    [tableViewCell.textLabel setText:self.roomNameArray[indexPath.row]];
    return tableViewCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectRoomTypeName:)]) {
        [self.delegate selectRoomTypeName:self.roomNameArray[indexPath.row]];
    }
}

- (UITableView *)typeTableView {
    if (!_typeTableView) {
        _typeTableView =  [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 60, 150) style:(UITableViewStylePlain)];
        _typeTableView.delegate = self;
        _typeTableView.dataSource = self;
        _typeTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 9.f)];
        _typeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 9.f)];
        _typeTableView.rowHeight = 44;
        _typeTableView.scrollEnabled = NO;
    }
    return _typeTableView;
}



@end
