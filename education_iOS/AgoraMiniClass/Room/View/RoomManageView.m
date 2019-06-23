//
//  RoomManageView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/17.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "RoomManageView.h"
#import "MessageListViewCell.h"
#import "MemberListView.h"
#import "MessageListView.h"
#import "MemberListViewCell.h"

@interface RoomManageView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UIButton *selectButton;
@end

@implementation RoomManageView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        UIButton *button = [self viewWithTag:1001];
        [self layoutButton:button selected:NO];
        MessageListView *messageListView = [self viewWithTag:100];
        MemberListView *memberListView = [self viewWithTag:101];
        messageListView.tableFooterView =  [[UIView alloc]init];
        memberListView.tableFooterView =  [[UIView alloc]init];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)clickButton:(UIButton *)button {
    if (button.selected != YES) {
        button.selected = YES;
        [self selectButton:button];
        self.selectButton.selected = NO;
        [self selectButton:self.selectButton];
        self.selectButton = button;
    }
}

- (void)selectButton:(UIButton *)button {
    if (button.selected == YES) {
        button.layer.borderColor = [UIColor redColor].CGColor;
        button.layer.borderWidth = 10.0f;
        button.backgroundColor = [UIColor whiteColor];
    }else {
        button.backgroundColor = [UIColor blueColor];
        button.layer.borderWidth = 0.f;
    }
}

- (IBAction)manageButton:(UIButton *)sender {
    sender.selected = YES;
    if (sender.tag == 1000) {
        UIButton *button = [self viewWithTag:1001];
        button.selected = sender.selected == YES ? NO : YES;
        [self layoutButton:button selected:button.selected];
        MessageListView *messageListView = [self viewWithTag:100];
        MemberListView *memberListView = [self viewWithTag:101];
        messageListView.hidden = NO;
        memberListView.hidden = YES;
    }else {
        UIButton *button = [self viewWithTag:1000];
         button.selected = sender.selected == YES ? NO : YES;
        [self layoutButton:button selected:button.selected];
        MessageListView *messageListView = [self viewWithTag:100];
        MemberListView *memberListView = [self viewWithTag:101];
        messageListView.hidden = YES;
        memberListView.hidden = NO;
    }
    [self layoutButton:sender selected:sender.selected];

}

- (void)layoutButton:(UIButton *)button selected:(BOOL)selected{
    if (selected) {
        button.layer.borderWidth = 0;
    }else {
        button.layer.borderWidth = 1;
        button.layer.borderColor = RCColorWithValue(0xE8E8E8, 1).CGColor;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([tableView isKindOfClass:[MessageListView class]]) {
        MessageListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        if (!cell) {
            cell = [[MessageListViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"MessageCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else {
        MemberListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
        if (!cell) {
            cell = [[MemberListViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"MemberCell"];
        }


        return cell;
    }

}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"sdajkhasdhklasdlhkasd");
}




@end
