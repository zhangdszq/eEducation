//
//  WhiteBoardToolControl.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/18.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "WhiteBoardToolControl.h"

@interface WhiteBoardToolControl ()
@property(nonatomic, weak)   UIButton *selectItemButton;
@property(nonatomic, strong) NSMutableArray *topConArray;
@end

@implementation WhiteBoardToolControl
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSArray *nomalImages  = [NSArray arrayWithObjects:@"whiteBoardPencil",@"whiteBoardMove",@"whiteBoardSquare",@"whiteBoardEraser",@"whiteBoardText",@"whiteBoardCircle", nil];
         NSArray *selectedImages  = [NSArray arrayWithObjects:@"whiteBoardPencilOn",@"whiteBoardMoveOn",@"whiteBoardSquareOn",@"whiteBoardEraserOn",@"whiteBoardTextOn",@"whiteBoardCircleOn", nil];
        [self setUpViewItems:nomalImages selectItems:selectedImages];
        self.backgroundColor = RCColorWithValue(0x333333, 1);
    }
    return self;
}

- (void)setUpViewItems:(NSArray *)items selectItems:(NSArray *)selectItems {
    self.topConArray = [NSMutableArray array];
    for (NSInteger i = 0 ; i < items.count; i++) {
        UIButton *itemButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        itemButton.backgroundColor = RCColorWithValue(0x565656, 1);
        [self addSubview:itemButton];
        [itemButton setTag:i];
        [itemButton setBackgroundImage:[UIImage imageNamed:items[i]] forState:(UIControlStateNormal)];
        CGRect rect = self.frame;
        float Spacing = (rect.size.height - (6 * rect.size.width))/5;
        itemButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *leftCon = [itemButton.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0];
        NSLayoutConstraint *widthCon = [NSLayoutConstraint constraintWithItem:itemButton attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:1 constant:0];
        NSLayoutConstraint *heithCon = [NSLayoutConstraint constraintWithItem:itemButton attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:1 constant:0];
         NSLayoutConstraint *topCon = [itemButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:(Spacing*i)+(i*rect.size.width)];
        [NSLayoutConstraint activateConstraints:@[topCon,leftCon,heithCon,widthCon]];
        [self.topConArray addObject:topCon];
        [itemButton addTarget:self action:@selector(toolClick:) forControlEvents:(UIControlEventTouchUpInside)];
        if (i == 0) {
            self.selectItemButton = itemButton;
            itemButton.selected = YES;
            itemButton.backgroundColor = RCColorWithValue(0x197CE1, 1.f);
        }
        [itemButton setBackgroundImage:[UIImage imageNamed:selectItems[i]] forState:(UIControlStateSelected)];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    float Spacing = (self.frame.size.height - (6 * self.frame.size.width))/5;
    NSArray *views = self.subviews;
    for (NSInteger i = 0; i < views.count; i++) {
        UIButton *itemButton = views[i];
        NSLayoutConstraint *topCon = self.topConArray[i];
        itemButton.translatesAutoresizingMaskIntoConstraints = NO;
        topCon.constant =(Spacing*i)+(i*self.frame.size.width);
    }
}

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 10, 10);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)toolClick:(UIButton *)item {
    if (item.selected == NO) {
        self.selectItemButton.backgroundColor = RCColorWithValue(0x565656, 1);
        self.selectItemButton.selected = NO;
        item.selected = YES;
        self.selectItemButton = item;
        item.backgroundColor = RCColorWithValue(0x197CE1, 1.f);
    }
    if (self.selectAppliance) {
        self.selectAppliance(item.tag);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
