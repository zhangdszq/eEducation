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
#import "RoomMessageModel.h"

@interface RoomManageView ()<UITextFieldDelegate>
@property (nonatomic, weak) UIButton *selectButton;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic, weak) UIButton *unmuteAllButton;
@property (nonatomic, weak) UIButton *muteAllButton;
@end

@implementation RoomManageView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
    UIButton *button = [self viewWithTag:1001];
    [self layoutButton:button selected:NO];


    MessageListView *messageListView = [self viewWithTag:100];
    MemberListView *memberListView = [self viewWithTag:101];
    messageListView.tableFooterView =  [[UIView alloc]init];
    memberListView.tableFooterView =  [[UIView alloc]init];

    self.unmuteAllButton = [self viewWithTag:400];
    self.muteAllButton = [self viewWithTag:401];
    [self.unmuteAllButton.layer setBorderColor:RCColorWithValue(0xCCCCCC, 1.0).CGColor];
    [self.unmuteAllButton.layer setBorderWidth:1.f];
    self.unmuteAllButton.layer.cornerRadius = 2;
    [self.muteAllButton.layer setBorderColor:RCColorWithValue(0xCCCCCC, 1.0).CGColor];
    [self.muteAllButton.layer setBorderWidth:1.f];
    self.muteAllButton.layer.cornerRadius = 2;
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
        self.unmuteAllButton.hidden = YES;
        self.muteAllButton.hidden = YES;
    }else {
        UIButton *button = [self viewWithTag:1000];
         button.selected = sender.selected == YES ? NO : YES;
        [self layoutButton:button selected:button.selected];
        MessageListView *messageListView = [self viewWithTag:100];
        MemberListView *memberListView = [self viewWithTag:101];
        messageListView.hidden = YES;
        memberListView.hidden = NO;
        self.unmuteAllButton.hidden = self.classRoomRole == ClassRoomRoleTeacther ? NO : YES;
        self.muteAllButton.hidden = self.classRoomRole == ClassRoomRoleTeacther ? NO : YES;
    }
    [self layoutButton:sender selected:sender.selected];
    if (self.topButtonType) {
        self.topButtonType(sender);
    }
}

- (void)layoutButton:(UIButton *)button selected:(BOOL)selected{

    if (selected) {
        button.layer.borderWidth = 0;
        [button setTitleColor:RCColorWithValue(0x006EDE, 1.f) forState:(UIControlStateNormal)];
        [button setBackgroundColor:RCColorWithValue(0xFFFFFF, 1.f)];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12 weight:(UIFontWeightMedium)]];
    }else {
        if (button.tag == 1000) {
            [self setBorderWithView:button top:YES left:YES bottom:YES right:NO borderColor:RCColorWithValue(0xA1D0FF, 1.f) borderWidth:1.f];
        }else {
            [self setBorderWithView:button top:YES left:NO bottom:YES right:YES borderColor:RCColorWithValue(0xA1D0FF, 1.f) borderWidth:1.f];
        }
        [button setTitleColor:RCColorWithValue(0xA1D0FF, 1.f) forState:(UIControlStateNormal)];
        [button setBackgroundColor:[UIColor clearColor]];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:12.f]];
        [button.titleLabel setFont:[UIFont systemFontOfSize:12.f weight:(UIFontWeightRegular)]];
    }
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 2.f;
}

- (void)setBorderWithView:(UIButton *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

- (IBAction)unMuteAll:(UIButton *)sender {

}

- (IBAction)MuteAll:(UIButton *)sender {

}

- (void)setClassRoomRole:(ClassRoomRole)classRoomRole {
    _classRoomRole = classRoomRole;
}
@end
