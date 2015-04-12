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
#define kGridCount 8.0f
#define kInterSpacing 2.0f
#define kEdgeSpacing 4.0f
#define kMinesCount 10

@interface BoardViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property UICollectionView *collectionView;
@property UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic) NSMutableArray *localConstraints;
@property NSArray *mineLocations;
@property NSMutableDictionary *selectedPaths;
@property NSMutableArray *adjescentIndicesToSelect;

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

    self.mineLocations = [self getNRandomNumbers:kMinesCount lessThan:kGridCount*kGridCount];
    self.selectedPaths = [[NSMutableDictionary alloc] init];
    
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
    if ([self.mineLocations containsObject:[NSNumber numberWithInteger:indexPath.row]])
        cell.backgroundColor = [UIColor redColor];
    else
        cell.backgroundColor = [UIColor greenColor];

    
    NSNumber *count = [self.selectedPaths objectForKey:[NSNumber numberWithInteger:indexPath.row]];
    if (count)
    {
        cell.backgroundColor = [UIColor yellowColor];
        if (count.integerValue)
            cell.label.text = [count stringValue];
    }
    
    return cell;
}

#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.mineLocations containsObject:[NSNumber numberWithInteger:indexPath.row]])
    {
        
    }
    else
    {
        NSInteger adjescentCount = [self countOfMinesAdjescentToIndex:indexPath.row];
        [self.selectedPaths setObject:[NSNumber numberWithInteger:adjescentCount] forKey:[NSNumber numberWithInteger:indexPath.row]];
        [self.collectionView reloadData];
        [self.adjescentIndicesToSelect removeObjectsInArray:self.selectedPaths.allKeys];
        
        if (!adjescentCount)
        {
            if (!self.adjescentIndicesToSelect)
                self.adjescentIndicesToSelect = [[NSMutableArray alloc] init];
            NSArray *adjescentIndices = [self adjescentIndicesAtIndex:indexPath.row];
            [self.adjescentIndicesToSelect removeObjectsInArray:adjescentIndices];
            [self.adjescentIndicesToSelect addObjectsFromArray:adjescentIndices];
            [self.adjescentIndicesToSelect removeObjectsInArray:self.selectedPaths.allKeys];
        }
        
        if (self.adjescentIndicesToSelect.count)
        {
            [self collectionView:collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:[self.adjescentIndicesToSelect.firstObject integerValue] inSection:indexPath.section]];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    if ([self.selectedPaths.allKeys containsObject:[NSNumber numberWithInteger:indexPath.row]])
        return  NO;
    else
        return YES;
}

#pragma mark UICollectionView UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = collectionView.bounds.size.width; // Total width/height available
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

#pragma mark Helpers

-(NSMutableArray *)getNRandomNumbers:(NSInteger)n lessThan:(int)Max {
    NSMutableArray *uniques = [[NSMutableArray alloc] init];
    int r;
    while ([uniques count] < n) {
        r = arc4random() % Max;
        if (![uniques containsObject:[NSNumber numberWithInt:r]]) {
            [uniques addObject:[NSNumber numberWithInt:r]];
        }
    }
    return uniques;
}


- (NSArray *)adjescentIndicesInSameAtIndex:(NSInteger)index {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    
    if (index <0 || index >= (kGridCount * kGridCount))
        return retVal;
    
    NSInteger row = floor(index/kGridCount);
    NSInteger rowMin = floor((kGridCount * row));
    NSInteger rowMax = rowMin + kGridCount -1;
    
    // This
    NSInteger currentIndex = index;
    if (currentIndex >= rowMin && currentIndex <= rowMax)
        [retVal addObject:[NSNumber numberWithInteger:currentIndex]];
    currentIndex = index-1;
    if (currentIndex >= rowMin && currentIndex <= rowMax)
        [retVal addObject:[NSNumber numberWithInteger:currentIndex]];
    currentIndex = index+1;
    if (currentIndex >= rowMin && currentIndex <= rowMax)
        [retVal addObject:[NSNumber numberWithInteger:currentIndex]];
    
    return retVal;
}

- (NSArray *)adjescentIndicesAtIndex:(NSInteger)index {
    
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    
    // This
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index]];
    // Top
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index-kGridCount]];
    // Bottom
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index+kGridCount]];
    
    [retVal removeObject:[NSNumber numberWithInteger:index]];
    
    return retVal;
}

- (NSInteger)countOfMinesAdjescentToIndex:(NSInteger)index {
    
    NSInteger adjescentCount= 0;
    NSArray *indices = [self adjescentIndicesAtIndex:index];
    for (NSNumber *i in indices)
    {
        if ([self.mineLocations containsObject:i])
            adjescentCount ++;
    }
    
    return adjescentCount;
}

@end
