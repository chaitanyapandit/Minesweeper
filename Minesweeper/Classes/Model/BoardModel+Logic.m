//
//  BoardModel+Logic.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardModel+Logic.h"
#import <Mantle/MTLJSONAdapter.h>

@implementation BoardModel (Logic)

- (void)didSelectBlockAtIndex:(NSInteger)index {
    
    if ([self.mineLocations containsObject:[NSNumber numberWithInteger:index]])
    {
        self.ended = @YES;
        [self.selectedBlocks setObject:@0 forKey:[NSNumber numberWithInteger:index]];
        if (reloadBlock)
            reloadBlock();
        if (gameEndBlock)
            gameEndBlock(YES);
    }
    else
    {
        NSInteger adjescentCount = [self countOfMinesAdjescentToIndex:index];
        [self.selectedBlocks setObject:[NSNumber numberWithInteger:adjescentCount] forKey:[NSNumber numberWithInteger:index]];
        [self.indicesToSelect removeObjectsInArray:self.selectedBlocks.allKeys];
        
        if (!adjescentCount)
        {
            if (!self.indicesToSelect)
                self.indicesToSelect = [[NSMutableArray alloc] init];
            NSArray *adjescentIndices = [self adjescentIndicesAtIndex:index];
            [self.indicesToSelect removeObjectsInArray:adjescentIndices];
            [self.indicesToSelect addObjectsFromArray:adjescentIndices];
            [self.indicesToSelect removeObjectsInArray:self.selectedBlocks.allKeys];
        }
        
        if (self.indicesToSelect.count)
        {
            [self didSelectBlockAtIndex:[self.indicesToSelect.firstObject integerValue]];
        }
        else
        {
            if (reloadBlock)
                reloadBlock();
        }
    }
}

- (BOOL)isBlockSelected:(NSInteger)index {
    return [self.selectedBlocks objectForKey:[NSNumber numberWithInteger:index]] ? YES : NO;
}

- (BOOL)minePresentAtIndex:(NSInteger)index {
    return [self.mineLocations containsObject:[NSNumber numberWithInteger:index]];
}

- (NSInteger)adjescentMinesCountForBlockAtIndex:(NSInteger)index {
    return [[self.selectedBlocks objectForKey:[NSNumber numberWithInteger:index]] integerValue];
}

- (void)restart {
    self.ended = @NO;
    self.indicesToSelect = [NSMutableArray array];
    self.selectedBlocks = [NSMutableDictionary dictionary];
    self.mineLocations = [self.class getNRandomNumbers:self.level.integerValue lessThan:self.gridSize.floatValue*self.gridSize.floatValue];
    if (reloadBlock)
        reloadBlock();
}

- (BOOL)finished {

    BOOL retVal = NO;
    
    if (self.selectedBlocks.count + self.mineLocations.count == self.gridSize.integerValue*self.gridSize.integerValue)
        retVal = YES;
    
    return retVal;
}

#pragma mark Helpers

- (NSArray *)adjescentIndicesInSameAtIndex:(NSInteger)index {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    
    if (index <0 || index >= (self.gridSize.floatValue * self.gridSize.floatValue))
        return retVal;
    
    NSInteger row = floor(index/self.gridSize.floatValue);
    NSInteger rowMin = floor((self.gridSize.floatValue * row));
    NSInteger rowMax = rowMin + self.gridSize.floatValue -1;
    
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
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index-self.gridSize.floatValue]];
    // Bottom
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index+self.gridSize.floatValue]];
    
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


- (NSError *)saveAtURL:(NSURL *)URL {
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [data writeToURL:URL atomically:YES];
    return nil;
}

@end
