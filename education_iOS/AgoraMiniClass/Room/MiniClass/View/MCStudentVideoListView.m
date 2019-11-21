//
//  MCStudentVideoListView.m
//  AgoraMiniClass
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 yangmoumou. All rights reserved.
//

#import "MCStudentVideoListView.h"
#import "MCStudentVideoCell.h"

@interface MCStudentVideoListView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *videoListView;
@property (nonatomic, strong) NSLayoutConstraint *collectionViewLeftCon;
@property (nonatomic, strong) NSMutableArray *studentArray;
@end

@implementation MCStudentVideoListView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpView];
    self.studentArray = [NSMutableArray array];
}

- (void)setUpView {
    [self addSubview:self.videoListView];
    self.layer.masksToBounds = YES;
    _videoListView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionViewLeftCon = [_videoListView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0];
      NSLayoutConstraint *rightCon = [_videoListView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0];
    NSLayoutConstraint *heightCon = [NSLayoutConstraint constraintWithItem:_videoListView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeHeight) multiplier:1 constant:0];
    NSLayoutConstraint *topCon = [_videoListView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0];
    [NSLayoutConstraint activateConstraints:@[topCon,self.collectionViewLeftCon,rightCon,heightCon]];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 1, 0, 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MCStudentVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
    cell.userModel = self.studentArray[indexPath.row];
    if (self.studentVideoList) {
        self.studentVideoList(cell.videoCanvasView,indexPath);
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(95, 70);
}

- (void)updateStudentArray:(NSMutableArray *)studentArray {
    NSMutableArray *tempArray = [NSMutableArray  arrayWithArray:self.studentArray];
    for (NSInteger i = 0; i < studentArray.count; i ++) {
        if (i >= tempArray.count) {
            [self.studentArray addObject:studentArray[i]];
            [self.videoListView reloadData];
        }else {
            EEBCStudentAttrs *studentModel = studentArray[i];
            EEBCStudentAttrs *tempStudentModel = self.studentArray[i];
            if (studentModel.video != tempStudentModel.video || studentModel.audio != tempStudentModel.audio) {
                [self.studentArray replaceObjectAtIndex:i withObject:studentModel];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.videoListView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
}

- (void)removeStudentModel:(EEBCStudentAttrs *)model {
    [self.studentArray removeObject:model];
    [self.videoListView reloadData];
}
#pragma mark  ----  lazy ------
- (UICollectionView *)videoListView {
    if (!_videoListView) {
        UICollectionViewFlowLayout *listLayout = [[UICollectionViewFlowLayout alloc] init];
        _videoListView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:listLayout];
        _videoListView.dataSource = self;
        _videoListView.delegate = self;
        listLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        listLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _videoListView.backgroundColor = [UIColor whiteColor];
        [_videoListView registerClass:[MCStudentVideoCell class] forCellWithReuseIdentifier:@"VideoCell"];
    }
    return _videoListView;
}
@end
