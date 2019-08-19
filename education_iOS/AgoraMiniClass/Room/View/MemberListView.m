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
- (instancetype)initWithCoder:(NSCoder *)coder {
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

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MemberListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
    if (!cell) {
        cell = [[MemberListViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"MemberCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.roomUserModel = self.studentArray[indexPath.row];
    cell.delegate = self;
    cell.isTeacther = _isTeacther;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentArray.count;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setStudentArray:(NSMutableArray *)studentArray {
    _studentArray = studentArray;
     [self reloadData];
}

- (void)setIsTeacther:(BOOL)isTeacther{
    _isTeacther = isTeacther;
    [self reloadData];
}
@end
