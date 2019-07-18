//
//  StudentVideoListView.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/6/16.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "StudentVideoListView.h"

@interface StudentVideoListView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *videoListView;
@end

@implementation StudentVideoListView
- (void)setStudentArray:(NSMutableArray *)studentArray {
    _studentArray = studentArray;
    [self.videoListView reloadData];
}
#pragma mark  ----  lazy ------
- (UICollectionView *)videoListView {
    if (!_videoListView) {
        UICollectionViewFlowLayout *listLayout = [[UICollectionViewFlowLayout alloc] init];
        _videoListView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:listLayout];
         [_videoListView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        _videoListView.dataSource = self;
        _videoListView.delegate = self;
        listLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        listLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _videoListView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];

    }
    return _videoListView;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self addSubview:self.videoListView];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        _videoListView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *leftCon = [_videoListView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0];
        NSLayoutConstraint *widthCon = [NSLayoutConstraint constraintWithItem:_videoListView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:1 constant:0];
        NSLayoutConstraint *heithCon = [NSLayoutConstraint constraintWithItem:_videoListView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeHeight) multiplier:1 constant:0];
        NSLayoutConstraint *topCon = [_videoListView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0];
        [NSLayoutConstraint activateConstraints:@[topCon,leftCon,heithCon,widthCon]];
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:backImageView];
    backImageView.image = [UIImage imageNamed:@"videoBackgroundImage"];
    backImageView.backgroundColor = RCColorWithValue(0x666666, 1.0);
    if (self.studentVideoList) {
        self.studentVideoList(backImageView,indexPath);
    }
    UILabel *nameLable = [self addNameLabel];
    [cell addSubview:nameLable];
    [cell bringSubviewToFront:nameLable];
    RoomUserModel *userModel = self.studentArray[indexPath.row];
    nameLable.text = userModel.name;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(75, 75);
}

- (UILabel *)addNameLabel {
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(0, 75-17, 75, 17);
    nameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:10.f];
    nameLabel.layer.cornerRadius = 2;
    return nameLabel;
}
@end
