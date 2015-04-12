//
//  BoardModel+Logic.m
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardModel+Logic.h"

@implementation BoardModel (Logic)

- (void)didSelectBlockAtIndex:(NSInteger)index {
    
    if ([self.mineLocations containsObject:[NSNumber numberWithInteger:index]])
    {
        if (self.gameEndBlock)
            self.gameEndBlock(YES);
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
            if (self.reloadBlock)
                self.reloadBlock();
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

#pragma mark Helpers

- (NSArray *)adjescentIndicesInSameAtIndex:(NSInteger)index {
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    
    if (index <0 || index >= (self.gridSize * self.gridSize))
        return retVal;
    
    NSInteger row = floor(index/self.gridSize);
    NSInteger rowMin = floor((self.gridSize * row));
    NSInteger rowMax = rowMin + self.gridSize -1;
    
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
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index-self.gridSize]];
    // Bottom
    [retVal addObjectsFromArray:[self adjescentIndicesInSameAtIndex:index+self.gridSize]];
    
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
