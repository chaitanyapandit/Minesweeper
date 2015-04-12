//
//  BoardModel.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardModel.h"
#import "BoardModel+Logic.h"

@interface BoardModel ()

@end


@implementation BoardModel

#pragma mark MTMode

- (id)initWithGridSize:(NSInteger)gridSize complexityLevel:(NSNumber *)level {
    self = [super init];
    if (self) {
        
        self.level = level;
        self.gridSize = [NSNumber numberWithInteger:gridSize];
        [self restart];
    }
    
    return self;
}

- (void)setGameEndBlock:(void (^)(BOOL mineStepped))block {
    gameEndBlock = [block copy];
}

- (void)setReloadBlock:(void (^)())block {
    reloadBlock = [block copy];
}

@end
