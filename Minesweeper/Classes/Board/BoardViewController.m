//
//  ViewController.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardCell.h"
#import "BoardModel.h"
#import "BoardModel+Logic.h"

#define kCellIdentifier @"b.c"
#define kInterSpacing 2.0f
#define kEdgeSpacing 4.0f

@interface BoardViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property UICollectionView *collectionView;
@property UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic) NSMutableArray *localConstraints;
@property BoardModel *model;

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

    // Check if we have a previous model saved
    NSURL *modelURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    modelURL = [modelURL URLByAppendingPathComponent:@"Minesweeper.db"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:modelURL.path isDirectory:nil])
    {
        self.model = [NSKeyedUnarchiver unarchiveObjectWithFile:modelURL.path];
    }
    else
    {
        self.model = [[BoardModel alloc] initWithComplexityLevel:[NSNumber numberWithInteger:TComplexityLevel_Intermediate]];
        self.model.cheatModeEnabled = @YES;
    }
    
    [self.model setGameEndBlock:^(BOOL mineStepped) {
        
    }];
    
    __weak __typeof(self) weakSelf = self;
    [self.model setReloadBlock:^{
        [weakSelf.collectionView reloadData];
        [weakSelf.model saveAtURL:modelURL];
    }];
    
    // Setup collection view
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
    return self.model.gridSize.floatValue*self.model.gridSize.floatValue;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BoardCell *cell = (BoardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.label.text = nil;

    if (self.model.cheatModeEnabled.boolValue && [self.model minePresentAtIndex:indexPath.row])
    {
        cell.backgroundColor = [UIColor redColor];
    }
    else if ([self.model isBlockSelected:indexPath.row])
    {
        cell.backgroundColor = [UIColor yellowColor];
        NSInteger count = [self.model adjescentMinesCountForBlockAtIndex:indexPath.row];
        if (count)
            cell.label.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
    else
        cell.backgroundColor = [UIColor greenColor];
    
    return cell;
}

#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.model didSelectBlockAtIndex:indexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    if ([self.model isBlockSelected:indexPath.row])
        return  NO;
    else
        return YES;
}

#pragma mark UICollectionView UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = collectionView.bounds.size.width; // Total width/height available
    width -= (kEdgeSpacing * 2.0f); // Minus size taken by edge spacings on both sides
    width -= (self.model.gridSize.floatValue -1)*kInterSpacing; // Minus the total size taken by separators
    CGFloat sz = width/self.model.gridSize.floatValue; // Size available for each individual cell

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
