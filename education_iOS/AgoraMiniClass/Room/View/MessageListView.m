//
//  MessageListView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/20.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MessageListView.h"

@interface MessageListView ()

@end

@implementation MessageListView
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld",indexPath.row);
}

@end
