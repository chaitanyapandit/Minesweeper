//
//  BoardModel+Logic.h
//  Minesweeper
//
//  Created by Chaitanya Pandit on 12/04/15.
//  Copyright (c) 2015 Chaitanya Pandit. All rights reserved.
//

#import "BoardModel.h"

@interface BoardModel (Logic)

- (void)didSelectBlockAtIndex:(NSInteger)index;
- (BOOL)isBlockSelected:(NSInteger)index;
- (BOOL)minePresentAtIndex:(NSInteger)index;
- (NSInteger)adjescentMinesCountForBlockAtIndex:(NSInteger)index;
- (NSError *)saveAtURL:(NSURL *)URL;

@end
