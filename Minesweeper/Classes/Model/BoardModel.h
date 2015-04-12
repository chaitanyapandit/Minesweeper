//
//  BoardModel.h
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mantle/Mantle.h>

typedef NS_ENUM(NSUInteger, TComplexityLevel) {
    TComplexityLevel_Simple = 5,
    TComplexityLevel_Intermediate = 10,
    TComplexityLevel_Difficult = 15 // For now directly corresponds to the number of mines
};

@interface BoardModel : MTLModel <MTLJSONSerializing>
{
    void (^gameEndBlock)(BOOL mineStepped);
    void (^reloadBlock)();
    
}

- (id)initWithComplexityLevel:(NSNumber *)level;

@property NSNumber *gridSize;
@property NSNumber *level;
@property NSMutableDictionary *selectedBlocks;
@property NSArray *mineLocations;
@property NSMutableArray *indicesToSelect;
@property NSNumber *cheatModeEnabled;

- (void)setGameEndBlock:(void (^)(BOOL mineStepped))block;
- (void)setReloadBlock:(void (^)())block;

@end
