//
//  BoardModel.h
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TComplexityLevel) {
    TComplexityLevel_Simple = 5,
    TComplexityLevel_Intermediate = 10,
    TComplexityLevel_Difficult = 15 // For now directly corresponds to the number of mines
};

@interface BoardModel : NSObject

- (id)initWithComplexityLevel:(TComplexityLevel)level;

@property CGFloat gridSize;
@property NSMutableDictionary *selectedBlocks;
@property NSArray *mineLocations;
@property NSMutableArray *indicesToSelect;
@property (nonatomic, copy) void (^gameEndBlock)(BOOL mineStepped);
@property (nonatomic, copy) void (^reloadBlock)();
@property BOOL cheatModeEnabled;

@end
