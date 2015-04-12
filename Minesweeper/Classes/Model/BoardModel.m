//
//  BoardModel.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardModel.h"

@interface BoardModel ()

@end


@implementation BoardModel

#pragma mark MTMode

- (id)initWithComplexityLevel:(NSNumber *)level
{
    self = [super init];
    if (self) {
        
        self.level = level;
        self.gridSize = @8;
        self.mineLocations = [self.class getNRandomNumbers:self.level.integerValue lessThan:self.gridSize.floatValue*self.gridSize.floatValue];
        self.selectedBlocks = [[NSMutableDictionary alloc] init];
        self.indicesToSelect = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setGameEndBlock:(void (^)(BOOL mineStepped))block {
    gameEndBlock = [block copy];
}

- (void)setReloadBlock:(void (^)())block {
    reloadBlock = [block copy];
}

#pragma mark Helpers

+ (NSMutableArray *)getNRandomNumbers:(NSInteger)n lessThan:(int)Max {
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

@end
