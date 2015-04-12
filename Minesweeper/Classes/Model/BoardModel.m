//
//  BoardModel.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardModel.h"

@interface BoardModel ()

@property NSInteger level;

@end

@implementation BoardModel

- (id)initWithComplexityLevel:(TComplexityLevel)level
{
    self = [super init];
    if (self) {
        
        self.level = level;
        self.gridSize = 8;
        self.mineLocations = [self.class getNRandomNumbers:self.level lessThan:self.gridSize*self.gridSize];
        self.selectedBlocks = [[NSMutableDictionary alloc] init];
        self.indicesToSelect = [[NSMutableArray alloc] init];
    }
    
    return self;
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
