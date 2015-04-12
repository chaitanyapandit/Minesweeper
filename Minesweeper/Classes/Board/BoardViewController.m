//
//  ViewController.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardViewController.h"

@interface BoardViewController ()

@property UICollectionView *collectionView;
@property UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic) NSMutableArray *localConstraints;

@end

@implementation BoardViewController

- (NSMutableArray *)localConstraints {
    if (_localConstraints)
        return  _localConstraints;
    
    _localConstraints = [[NSMutableArray alloc] init];
    return  _localConstraints;
}

- (void)setupConstraints{
    [self.view removeConstraints:self.localConstraints];
    [self.localConstraints removeAllObjects];
    
    NSDictionary *views = @{@"collectionView":self.collectionView};
    NSDictionary *metrics = @{@"boardSize":[NSNumber numberWithFloat:self.view.bounds.size.width]};
    
    [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[collectionView(boardSize)]" options:0 metrics:metrics views:views]];
    [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(boardSize)]|" options:0 metrics:metrics views:views]];
    
    [self.view addConstraints:self.localConstraints];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
    self.collectionView.collectionViewLayout = self.collectionViewLayout;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor orangeColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setupConstraints];
}

@end
