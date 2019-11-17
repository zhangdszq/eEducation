//
//  EESegmentedView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/10/22.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "EESegmentedView.h"
#import "UIView+EEBadge.h"

@interface EESegmentedView ()
@property (nonatomic, copy) NSArray *items;
@end

@implementation EESegmentedView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.items = [NSArray arrayWithObjects:@"教材区",@"Chatroom", nil];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.shadowColor = RCColorWithValue(0x000000, 0.15).CGColor;
    self.layer.shadowOffset = CGSizeMake(0,2);
    self.layer.shadowOpacity = 2;
    self.layer.shadowRadius = 4;
    for (NSInteger i = 0; i < self.items.count; i++) {
        UIButton *itemButton = [[UIButton alloc] init];
        [itemButton setTitle:self.items[i] forState:(UIControlStateNormal)];
        [itemButton setFrame:CGRectMake(i * kScreenWidth / 2, 0, kScreenWidth/2, self.frame.size.height)];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i * kScreenWidth / 2, 42, kScreenWidth/2, 2.f)];
        lineView.backgroundColor = RCColorWithValue(0x44A2FC, 1);
        [self addSubview:lineView];
        lineView.tag = i + 100;
        itemButton.tag = i + 1000; //tag设计不太好，因为如果你封装东西，可能整个加载u页面会有其他的设置
        if (i == 0) {
            [itemButton setSelected:YES];
        }else {
            lineView.hidden = YES;
        }
        [self setSelectedButton:itemButton];
        [self addSubview:itemButton];
        [itemButton addTarget:self action:@selector(selectItem:) forControlEvents:(UIControlEventTouchUpInside)];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)selectItem:(UIButton *)sender {
    for (NSInteger i = 0; i < self.items.count; i++) {
        UIView *lineView = (UIView *)[self viewWithTag:i+100];
        if ((sender.tag - 1000) == i) {
            [sender setSelected:YES];
            [self setSelectedButton:sender];
            lineView.hidden = NO;
        }else {
            UIButton *tempButton = (UIButton *)[self viewWithTag:i+1000];
            [tempButton setSelected:NO];
            [self setSelectedButton:tempButton];
            lineView.hidden = YES;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedItemIndex:)]) {
        [self.delegate selectedItemIndex:sender.tag - 1000];
    }
}

- (void)setSelectedButton:(UIButton *)button {
    if (button.selected) {
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:16.f]];
        [button.titleLabel setFont:[UIFont systemFontOfSize:16.f weight:(UIFontWeightMedium)]];
        [button setTitleColor:RCColorWithValue(0x44A2FC, 1.f) forState:(UIControlStateNormal)];
    }else {
        [button.titleLabel setFont:[UIFont systemFontOfSize:16.f weight:(UIFontWeightRegular)]];
        [button setTitleColor:RCColorWithValue(0x666666, 1.f) forState:(UIControlStateNormal)];
    }
}

- (void)showBadgeWithCount:(NSInteger)count {
    UIButton *tempButton = (UIButton *)[self viewWithTag:1001];
    [tempButton.titleLabel showBadgeWithTopMagin:0];
    [tempButton.titleLabel setBadgeCount:count];

}
- (void)hiddeBadge {
    UIButton *tempButton = (UIButton *)[self viewWithTag:1001];
    [tempButton.titleLabel hidenBadge];
}
@end
