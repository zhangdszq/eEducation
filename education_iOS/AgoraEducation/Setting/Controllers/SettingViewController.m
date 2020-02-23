//
//  SettingViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/16.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewCell.h"
#import "EyeCareModeUtil.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,SettingCellDelegate>
@property (nonatomic, weak) UITableView *settingTableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"SettingText", nil);
    [self setUpView];
}

- (void)setUpView {
    UITableView *settingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:(UITableViewStylePlain)];
    settingTableView.dataSource = self;
    settingTableView.delegate = self;
    [self.view addSubview:settingTableView];
    self.settingTableView = settingTableView;
    settingTableView.tableFooterView = [[UIView alloc] init];

    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"page-prev"] forState:(UIControlStateNormal)];
    [backButton addTarget:self action:@selector(backBarButton:) forControlEvents:(UIControlEventTouchUpInside)];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem =item;
}

- (void)backBarButton:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (!cell) {
        cell = [[SettingViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"SettingCell"];
    }
    cell.delegate = self;
    [cell switchOn:[[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.f;
}

- (void)settingSwitchCallBack:(UISwitch *)sender {
    [[EyeCareModeUtil sharedUtil] switchEyeCareMode:sender.on];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
