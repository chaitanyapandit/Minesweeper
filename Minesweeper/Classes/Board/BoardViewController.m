//
//  ViewController.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

#import "BoardViewController.h"
#import "BoardCell.h"
#import "BoardModel.h"
#import "BoardModel+Logic.h"

#define kCellIdentifier @"b.c"
#define kInterSpacing 2.0f
#define kEdgeSpacing 4.0f

#define kBackgroundColor [UIColor colorWithRed:142.0/255.0f green:143.0/255.0f blue:147.0/255.0f alpha:1.0f]
#define kMineColor [UIColor colorWithRed:253.0f/255.0f green:50.0f/255.0f blue:89.0f/255.0f alpha:1.0f]
#define kSelectedBlockColor [UIColor colorWithRed:83.0f/255.0f green:216.0f/255.0f blue:106.0f/255.0f alpha:1.0f]
#define kDefaultBlockColor [UIColor colorWithRed:22.0f/255.0f green:127.0f/255.0f blue:252.0f/255.0f alpha:1.0f]
#define kButtonColor [UIColor colorWithRed:22.0f/255.0f green:127.0f/255.0f blue:252.0f/255.0f alpha:1.0f]

@interface BoardViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property UICollectionView *collectionView;
@property UIButton *freshGameButton;
@property UIButton *validateButton;
@property UIButton *cheatButton;
@property UIView *buttonsContainer;
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

- (void)setupConstraintsForSize:(CGSize)size {
    [self.view removeConstraints:self.localConstraints];
    [self.localConstraints removeAllObjects];
    
    NSDictionary *views = @{@"collectionView":self.collectionView,
                            @"buttonsContainer":self.buttonsContainer,
                            @"freshGameButton":self.freshGameButton,
                            @"validateButton":self.validateButton,
                            @"cheatButton":self.cheatButton};
    
    NSDictionary *metrics = @{@"boardSize":[NSNumber numberWithFloat:MIN(size.width, size.height)],
                              @"buttonsContainerSize":[NSNumber numberWithFloat:MAX(size.width, size.height)-MIN(size.width, size.height)-20.0f],
                              @"buttonTopSpacing":@100.0f,
                              @"buttonEdgeSpacing":@20.0f};
    
    if (size.width > size.height)
    {
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView(boardSize)]" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[buttonsContainer(buttonsContainerSize)]|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonsContainer]|" options:0 metrics:metrics views:views]];
        
        // Buttons
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[freshGameButton]-(buttonEdgeSpacing)-|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[validateButton]-(buttonEdgeSpacing)-|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cheatButton]-(buttonEdgeSpacing)-|" options:0 metrics:metrics views:views]];

        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[freshGameButton(40.0)]" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[validateButton(40.0)]" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cheatButton(40.0)]" options:0 metrics:metrics views:views]];
        
        CGFloat buttonSpacing = 20.0f;
        [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.freshGameButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.buttonsContainer attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.validateButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.freshGameButton attribute:NSLayoutAttributeTop multiplier:1.0f constant:-buttonSpacing]];
        [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cheatButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.freshGameButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:buttonSpacing]];
    }
    else
    {
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buttonsContainer]|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[buttonsContainer(buttonsContainerSize)]" options:0 metrics:metrics views:views]];
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(boardSize)]|" options:0 metrics:metrics views:views]];
        
        // Buttons
        [self.localConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[freshGameButton(==validateButton)]-[validateButton(==freshGameButton)]-[cheatButton(==freshGameButton)]-|" options:0 metrics:metrics views:views]];
        [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.freshGameButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.buttonsContainer attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.validateButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.buttonsContainer attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self.localConstraints addObject:[NSLayoutConstraint constraintWithItem:self.cheatButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.buttonsContainer attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    }

    [self.view addConstraints:self.localConstraints];
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Check if we have a previous model saved
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self modelURL].path isDirectory:nil])
    {
        self.model = [NSKeyedUnarchiver unarchiveObjectWithFile:[self modelURL].path];
    }
    else
    {
        self.model = [[BoardModel alloc] initWithGridSize:8 complexityLevel:[NSNumber numberWithInteger:TComplexityLevel_Intermediate]];
        self.model.cheatModeEnabled = @NO;
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.model setGameEndBlock:^(BOOL mineStepped) {
        
        if (mineStepped)
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"game.ended.title", @"") message:NSLocalizedString(@"game.ended.message", @"") cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil tapBlock:nil];
        }
    }];
    
    [self.model setReloadBlock:^{
        [weakSelf.collectionView reloadData];
        [weakSelf.model saveAtURL:[weakSelf modelURL]];
        weakSelf.collectionView.alpha = weakSelf.model.ended.boolValue ? 0.5f : 1.0f;
    }];
    
    // Setup collection view
    self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
    self.collectionView.collectionViewLayout = self.collectionViewLayout;
    self.collectionView.dataSource = self, self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = kBackgroundColor;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerClass:[BoardCell class] forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.alpha = self.model.ended.boolValue ? 0.5f : 1.0f;

    self.buttonsContainer = [[UIView alloc] init];
    self.buttonsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.buttonsContainer];

    self.freshGameButton = [[UIButton alloc] init];
    self.freshGameButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.freshGameButton setTitle:NSLocalizedString(@"new.game", @"") forState:UIControlStateNormal];
    [self.freshGameButton addTarget:self action:@selector(newGameAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsContainer addSubview:self.freshGameButton];
    self.freshGameButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.freshGameButton.backgroundColor = kButtonColor;
    
    self.validateButton = [[UIButton alloc] init];
    self.validateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.validateButton setTitle:NSLocalizedString(@"validate", @"") forState:UIControlStateNormal];
    [self.validateButton addTarget:self action:@selector(validateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsContainer addSubview:self.validateButton];
    self.validateButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.validateButton.backgroundColor = kButtonColor;

    self.cheatButton = [[UIButton alloc] init];
    self.cheatButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cheatButton setTitle:NSLocalizedString(@"cheat", @"") forState:UIControlStateNormal];
    [self.cheatButton addTarget:self action:@selector(cheatAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsContainer addSubview:self.cheatButton];
    self.cheatButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    self.cheatButton.backgroundColor = kButtonColor;

    [self setupConstraintsForSize:self.view.bounds.size];
}

#pragma mark Actions

- (void)newGameAction:(UIButton *)button {
    [self.model restart];
}

- (void)validateAction:(UIButton *)button {
    BOOL success = [self.model finished];
    if (success)
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"validate.success.title", @"") message:NSLocalizedString(@"validate.success.message", @"") cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:@[NSLocalizedString(@"restart", @"")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                [self newGameAction:nil];
            }
        }];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"validate.failure.title", @"") message:NSLocalizedString(@"validate.failure.message", @"") cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil tapBlock:nil];
    }
}

- (void)cheatAction:(UIButton *)button {
    self.model.cheatModeEnabled = [NSNumber numberWithBool:!self.model.cheatModeEnabled.boolValue];
    [self.collectionView reloadData];
    [self.model saveAtURL:[self modelURL]];
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
        cell.backgroundColor = kMineColor;
    }
    else if ([self.model isBlockSelected:indexPath.row])
    {
        cell.backgroundColor = kSelectedBlockColor;
        NSInteger count = [self.model adjescentMinesCountForBlockAtIndex:indexPath.row];
        if (count)
            cell.label.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
    else
        cell.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:127.0f/255.0f blue:252.0f/255.0f alpha:1.0f];
    
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
    
    CGFloat width = MIN(collectionView.bounds.size.width, collectionView.bounds.size.height); // Total width/height available
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

#pragma mark Autorotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [self setupConstraintsForSize:size];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    [self.collectionView reloadData];
}

#pragma mark Helpers

- (NSURL *)modelURL {
    NSURL *modelURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    modelURL = [modelURL URLByAppendingPathComponent:@"Minesweeper.db"];
    return modelURL;
}

@end
