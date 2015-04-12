//
//  ViewController.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardCell.h"

#define kCellIdentifier @"b.c"
#define kGridCount 8
#define kInterSpacing 2.0f
#define kEdgeSpacing 4.0f

@interface BoardViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property UICollectionView *collectionView;
@property UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic) NSMutableArray *localConstraints;

@end

@implementation BoardViewController

#pragma mark Autolayout

- (NSMutableArray *)localConstraints {
    if (_localConstraints)
        return  _localConstraints;
    
    _localConstraints = [[NSMutableArray alloc] init];
    return  _localConstraints;
}

- (void)setupConstraints {
    [self.view removeConstraints:self.localConstraints];
    [self.localConstraints removeAllObjects];
    
    NSDictionary *views = @{@"collectionView":self.collectionView};
    NSDictionary *metrics = @{@"boardSize":[NSNumber numberWithFloat:self.view.bounds.size.width]};
    
    [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[collectionView(boardSize)]" options:0 metrics:metrics views:views]];
    [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(boardSize)]|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:self.localConstraints];
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
    self.collectionView.collectionViewLayout = self.collectionViewLayout;
    self.collectionView.dataSource = self, self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor orangeColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.collectionView registerClass:[BoardCell class] forCellWithReuseIdentifier:kCellIdentifier];
    
    [self setupConstraints];
}

#pragma mark UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kGridCount*kGridCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BoardCell *cell = (BoardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];

    return cell;
}

#pragma mark UICollectionView Delegate


#pragma mark UICollectionView UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = 320.0f; // Total width/height available
    width -= (kEdgeSpacing * 2.0f); // Minus size taken by edge spacings on both sides
    width -= (kGridCount -1)*kInterSpacing; // Minus the total size taken by separators
    CGFloat sz = width/kGridCount; // Size available for each individual cell

    return CGSizeMake(sz, sz);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kEdgeSpacing, kEdgeSpacing, kEdgeSpacing, kEdgeSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kInterSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kInterSpacing;
}

@end
