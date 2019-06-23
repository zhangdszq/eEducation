//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MainViewController.h"
#import "CameraMicTestViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *teactherButton;
@property (weak, nonatomic) IBOutlet UIButton *studentButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setAllButtonStyle];
    UITapGestureRecognizer *touchedControl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBegan:)];
    [self.baseView addGestureRecognizer:touchedControl];
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)setAllButtonStyle {
    [self setButtonStyle:self.teactherButton];
    [self setButtonStyle:self.studentButton];
     [self setButtonStyle:self.audienceButton];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height - 208;
    self.textViewBottomConstraint.constant = bottom;
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    self.textViewBottomConstraint.constant = 48;
}

- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    NSLog(@"");
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mainToCamera"]) {
    }
}

- (void)setButtonStyle:(UIButton *)button {
    if (button.selected == YES) {
        [button setBackgroundColor:RCColorWithValue(0x006EDE, 1)];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];

    }else {
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.borderColor = RCColorWithValue(0xCCCCCC, 1).CGColor;
        button.layer.borderWidth = 1;
        [button setTitleColor:RCColorWithValue(0xCCCCCC,1) forState:(UIControlStateNormal)];
        }
}
- (IBAction)selectRole:(id)sender {
    if (sender == self.teactherButton) {
        self.teactherButton.selected = YES;
        self.studentButton.selected = NO;
        self.audienceButton.selected = NO;
    }else if (sender == self.studentButton) {
        self.teactherButton.selected = NO;
        self.studentButton.selected = YES;
        self.audienceButton.selected = NO;
    }else {
        self.teactherButton.selected = NO;
        self.studentButton.selected = NO;
        self.audienceButton.selected = YES;
    }
    [self setAllButtonStyle];
}

- (IBAction)joinRoom:(UIButton *)sender {
    if (self.classNameTextFiled.text.length <= 0 || self.userNameTextFiled.text.length <= 0) {

        NSLog(@"join room error");
    }else {
        if (self.teactherButton.selected || self.studentButton.selected || self.audienceButton.selected) {
            NSLog(@"join channel");

        }else {
            NSLog(@"join room error");
        }
    }
}

@end
