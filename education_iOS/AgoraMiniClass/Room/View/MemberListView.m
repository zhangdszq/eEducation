//
//  MemberListView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MemberListView.h"
#import "MemberListViewCell.h"
#import "RoomUserModel.h"

@interface MemberListView ()<UITableViewDelegate,UITableViewDataSource,MemberListViewCellDelegate>

@end

@implementation MemberListView
- (void)setMemberArray:(NSMutableArray *)memberArray {
    _memberArray = memberArray;
    [self reloadData];
}
- (void)setIsTeacther:(BOOL)isTeacther{
    _isTeacther = isTeacther;
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
    MemberListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    if (!cell) {
        cell = [[MemberListViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"MemberCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.roomUserModel = self.memberArray[indexPath.row];
    cell.delegate = self;
    cell.isTeacther = _isTeacther;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
}

- (void)selectCellCameraIsMute:(BOOL)mute userModel:(RoomUserModel * _Nullable)userModel {
    if (self.muteCamera) {
        self.muteCamera(mute, userModel);
    }
}

- (void)selectCellMicIsMute:(BOOL)mute userModel:(RoomUserModel * _Nullable)userModel {
    if (self.muteMic) {
        self.muteMic(mute, userModel);
    }
}

@end
