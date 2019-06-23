//
//  RoomChatView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/19.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "RoomChatListView.h"

@interface RoomChatListView ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
@property (nonatomic, weak) UITableView *chatTableView;
@property (nonatomic, weak) UITextView *chatTextView;
@end

@implementation RoomChatListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViewFrame:frame];
    }
    return self;
}

- (void)setUpViewFrame:(CGRect)frame {
    UITableView *chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:(UITableViewStylePlain)];
    chatTableView.delegate = self;
    chatTableView.dataSource = self;
    [self addSubview:chatTableView];
    self.chatTableView = chatTableView;

    UITextView *chatTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 200 - 30, frame.size.width, 30)];
    chatTextView.delegate = self;
    [self addSubview:chatTextView];
    self.chatTextView = chatTextView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"ChatCell"];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


@end
