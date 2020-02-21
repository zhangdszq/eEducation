//
//  MCStudentVideoListView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/14.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentVideoListView.h"
#import "MCStudentVideoCell.h"

@interface MCStudentVideoListView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *videoListView;
@property (nonatomic, strong) NSLayoutConstraint *collectionViewLeftCon;
@property (nonatomic, strong) NSArray<RolesStudentInfoModel*> *studentArray;
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
    self.studentArray = [NSArray array];
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
    
    StudentModel *currentModel = self.studentArray[indexPath.row].studentModel;
    cell.userModel = currentModel;
    if (self.studentVideoList) {
        self.studentVideoList(cell, [currentModel uid]);
    }

    return cell;
}


- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(95, 70);
}

- (void)updateStudentArray:(NSArray<RolesStudentInfoModel*> *)studentArray {
    
    if(studentArray.count == 0 || self.studentArray.count != studentArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.studentArray = [NSArray arrayWithArray:studentArray];
            [self.videoListView reloadData];
        });
    } else {

        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];

        NSInteger count = studentArray.count;
        for(NSInteger i = 0; i < count; i++) {
            RolesStudentInfoModel *sourceModel = [self.studentArray objectAtIndex:i];
            RolesStudentInfoModel *currentModel = [studentArray objectAtIndex:i];
            if(![sourceModel.attrKey isEqualToString:currentModel.attrKey] || ![sourceModel.studentModel isEqual:currentModel.studentModel]) {

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
        }

        self.studentArray = [NSArray arrayWithArray:studentArray];
        [self.videoListView reloadItemsAtIndexPaths:indexPaths];
    }
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
